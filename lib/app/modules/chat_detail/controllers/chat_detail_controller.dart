import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:halositek/app/data/models/conversation_detail.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/data/network/token_service.dart';
import 'package:halositek/app/data/network/websocket_service.dart';

class ChatDetailController extends GetxController {
  final ChatService _chatService;
  final TokenService _tokenService;
  final String conversationId;
  final String consultationId;
  final String title;
  final int durationHours;
  final String? avatarUrl;
  final String conversationStatus;

  ChatDetailController(
    this._chatService,
    this._tokenService, {
    required this.conversationId,
    required this.consultationId,
    required this.title,
    this.avatarUrl,
    this.durationHours = 0,
    this.conversationStatus = '',
  });

  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final errorMessage = ''.obs;
  final isSessionExpired = false.obs;
  final sessionExpiredAt = Rxn<DateTime>();
  final remainingSeconds = 0.obs;
  final reports = <ChatReport>[].obs;
  final isSubmittingReport = false.obs;

  int _currentPage = 1;
  int _lastPage = 1;
  final hasMoreMessages = true.obs;
  final isLoadingMore = false.obs;

  final conversationDetail = Rxn<ConversationDetailModel>();
  final otherUserName = ''.obs;
  final otherUserRole = ''.obs;
  final otherUserAvatar = ''.obs;

  final selectedImagePath = Rxn<String>();

  // ── Typing indicator (WebSocket) ───────────────────────────────────
  final isOtherTyping = false.obs;
  final otherTypingName = ''.obs;
  Timer? _otherTypingResetTimer;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController reportController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Timer? _expiryTimer;
  Timer? _typingTimer;
  bool _lastTypingStatus = false;

  String? _currentUserId;

  String get displayTitle =>
      otherUserName.value.trim().isNotEmpty ? otherUserName.value : (title.trim().isNotEmpty ? title : 'Chat');
  String get displayRole => otherUserRole.value;
  String? get displayAvatar => otherUserAvatar.value.trim().isNotEmpty ? otherUserAvatar.value : avatarUrl;

  String get currentStatus => conversationStatus.toLowerCase();

  bool get hasApproved => currentStatus == 'approved';
  bool get hasDeclined => currentStatus == 'declined';
  bool get hasReported => currentStatus == 'new';

  // ── WebSocket channel name ─────────────────────────────────────────
  String get _wsChannel => 'private-chat.conversation.$conversationId';

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(_onMessageTextChanged);
    scrollController.addListener(_onScroll);
    fetchMessages();
    _subscribeWebSocket();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels <= 150) {
      loadMoreMessages();
    }
  }

  @override
  void onClose() {
    _expiryTimer?.cancel();
    _typingTimer?.cancel();
    _otherTypingResetTimer?.cancel();
    messageController.removeListener(_onMessageTextChanged);
    messageController.dispose();
    reportController.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _unsubscribeWebSocket();
    super.onClose();
  }

  // ────────────────────────────────────────────────────────────────────
  //  WEBSOCKET INTEGRATION
  // ────────────────────────────────────────────────────────────────────

  void _subscribeWebSocket() {
    try {
      final ws = Get.find<WebSocketService>();

      // Subscribe to the conversation channel
      ws.subscribe(_wsChannel);

      // Listen for new messages
      ws.on(_wsChannel, 'chat.message.sent', _onWsMessageReceived);

      // Listen for typing events
      ws.on(_wsChannel, 'chat.typing', _onWsTypingReceived);

      debugPrint('[ChatDetail] 📡 Subscribed to $_wsChannel');
    } catch (e) {
      debugPrint('[ChatDetail] ❌ WebSocket subscribe error: $e');
    }
  }

  void _unsubscribeWebSocket() {
    try {
      final ws = Get.find<WebSocketService>();
      // Only remove listeners for this controller; don't unsubscribe the
      // channel itself because ChatListController may still be listening.
      ws.off(_wsChannel, 'chat.message.sent', _onWsMessageReceived);
      ws.off(_wsChannel, 'chat.typing', _onWsTypingReceived);
      debugPrint('[ChatDetail] 🔕 Removed listeners from $_wsChannel');
    } catch (e) {
      debugPrint('[ChatDetail] ❌ WebSocket unsubscribe error: $e');
    }
  }

  void _onWsMessageReceived(Map<String, dynamic> data) {
    try {
      final messageData = data['message'];
      if (messageData == null || messageData is! Map) return;

      final message = ChatMessage.fromJson(Map<String, dynamic>.from(messageData));

      // Prevent duplicates – skip if we already have this message
      if (messages.any((m) => m.id == message.id)) return;

      // Skip messages from the current user (we already added them
      // optimistically when sent via the API)
      if (message.userId == _currentUserId) return;

      final editedMessage = message.copyWith(isMine: message.userId == _currentUserId);
      messages.add(editedMessage);
      _scrollToBottom();

      // Mark as read since the user is viewing this conversation
      _chatService.markAsRead(conversationId).catchError((_) {});

      debugPrint('[ChatDetail] 📨 New message received via WS: ${message.id}');
    } catch (e) {
      debugPrint('[ChatDetail] ❌ Error handling WS message: $e');
    }
  }

  void _onWsTypingReceived(Map<String, dynamic> data) {
    try {
      final userId = data['user_id']?.toString() ?? '';
      final isTyping = data['is_typing'] == true;

      // Ignore own typing events
      if (userId == _currentUserId) return;

      isOtherTyping.value = isTyping;

      // Auto-reset typing after 4 seconds if no update received
      _otherTypingResetTimer?.cancel();
      if (isTyping) {
        _otherTypingResetTimer = Timer(const Duration(seconds: 4), () {
          isOtherTyping.value = false;
        });
      }
    } catch (e) {
      debugPrint('[ChatDetail] ❌ Error handling WS typing: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  SESSION EXPIRY
  // ────────────────────────────────────────────────────────────────────

  void _initSessionExpiry() {
    if (remainingSeconds.value <= 0) {
      isSessionExpired.value = true;
      return;
    }

    _scheduleExpiryCheck();
  }

  void _scheduleExpiryCheck() {
    _expiryTimer?.cancel();
    if (remainingSeconds.value <= 0) {
      isSessionExpired.value = true;
      return;
    }

    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkExpiry();
    });
  }

  void _checkExpiry() {
    if (remainingSeconds.value > 0) {
      remainingSeconds.value--;
    } else {
      isSessionExpired.value = true;
      _expiryTimer?.cancel();
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  TYPING STATUS (outgoing)
  // ────────────────────────────────────────────────────────────────────

  void _onMessageTextChanged() {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      if (!_lastTypingStatus) {
        _setTypingStatus(true);
      }
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _setTypingStatus(false);
      });
    } else {
      if (_lastTypingStatus) {
        _typingTimer?.cancel();
        _setTypingStatus(false);
      }
    }
  }

  Future<void> _setTypingStatus(bool isTyping) async {
    if (_lastTypingStatus == isTyping) return;
    _lastTypingStatus = isTyping;
    try {
      await _chatService.sendTypingStatus(conversationId, isTyping);
    } catch (e) {
      debugPrint('Failed to send typing status: $e');
    }
  }

  void goBack() {
    Get.back();
  }

  // ────────────────────────────────────────────────────────────────────
  //  FETCH MESSAGES
  // ────────────────────────────────────────────────────────────────────

  Future<void> loadMoreMessages() async {
    if (isLoadingMore.value || !hasMoreMessages.value || isLoading.value) return;

    isLoadingMore.value = true;
    _currentPage++;

    try {
      final messagesPage = await _chatService.getMessages(conversationId, page: _currentPage, perPage: 10);
      final newMsgs = messagesPage.messages.reversed.toList();

      if (newMsgs.isNotEmpty) {
        final double currentScrollOffset = scrollController.offset;
        final double currentMaxScrollExtent = scrollController.position.maxScrollExtent;

        messages.insertAll(0, newMsgs);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            final double newMaxScrollExtent = scrollController.position.maxScrollExtent;
            scrollController.jumpTo(currentScrollOffset + (newMaxScrollExtent - currentMaxScrollExtent));
          }
        });
      }

      _lastPage = messagesPage.meta.lastPage;
      hasMoreMessages.value = _currentPage < _lastPage;
    } catch (e) {
      _currentPage--;
      Get.snackbar('Gagal', 'Tidak dapat memuat pesan lama', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchMessages() async {
    if (conversationId.trim().isEmpty) {
      errorMessage.value = 'Conversation ID tidak ditemukan';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      _currentPage = 1;
      hasMoreMessages.value = true;

      final results = await Future.wait([
        _chatService.getMessages(conversationId, page: _currentPage, perPage: 10),
        _chatService.getConversationDetail(conversationId),
      ]);

      final messagesPage = results[0] as MessagesPage;
      final detail = results[1] as ConversationDetailModel;

      messages.assignAll(messagesPage.messages.reversed.toList());
      conversationDetail.value = detail;

      _lastPage = messagesPage.meta.lastPage;
      hasMoreMessages.value = _currentPage < _lastPage;

      _currentUserId = await _tokenService.getUserId() ?? '';

      if (detail.architect?.id == _currentUserId) {
        otherUserName.value = detail.user?.name ?? '';
        otherUserRole.value = 'USER';
        otherUserAvatar.value = detail.user?.photoProfile != null ? '/storage/${detail.user?.photoProfile}' : '';
      } else {
        otherUserName.value = detail.architect?.name ?? '';
        otherUserRole.value = 'ARCHITECT';
        otherUserAvatar.value =
            detail.architect?.profilePicture != null ? '/storage/${detail.architect?.profilePicture}' : '';
      }

      // Set typing display name to the other user's name
      otherTypingName.value = otherUserName.value;

      final session = detail.consultationSession;
      if (session != null) {
        remainingSeconds.value = session.remainingSeconds ?? 0;
        isSessionExpired.value = remainingSeconds.value <= 0;
        if (!isSessionExpired.value) {
          _initSessionExpiry();
        }
      }

      _scrollToBottom();

      try {
        await _chatService.markAsRead(conversationId);
      } catch (e) {
        debugPrint('Failed to mark as read: $e');
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  SEND MESSAGE
  // ────────────────────────────────────────────────────────────────────

  Future<void> sendMessage() async {
    if (isSending.value) return;
    if (isSessionExpired.value) return;

    final text = messageController.text.trim();
    final imagePath = selectedImagePath.value;

    if (text.isEmpty && imagePath == null) return;

    isSending.value = true;
    messageController.clear();
    _typingTimer?.cancel();
    _setTypingStatus(false);

    try {
      if (imagePath != null) {
        final message = await _chatService.sendImage(conversationId: conversationId, imageFile: File(imagePath), body: text);
        messages.add(message);
        selectedImagePath.value = null;
      } else {
        final message = await _chatService.sendMessage(conversationId: conversationId, body: text);
        messages.add(message);
      }
      _scrollToBottom();
    } catch (e) {
      messageController.text = text; // restore text if failed
      Get.snackbar(
        'Gagal mengirim',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  PICK IMAGE
  // ────────────────────────────────────────────────────────────────────

  Future<void> pickImage() async {
    if (isSending.value) return;
    if (isSessionExpired.value) return;

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);

      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;

      selectedImagePath.value = path;
    } catch (e) {
      Get.snackbar('Gagal memilih gambar', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removeSelectedImage() {
    selectedImagePath.value = null;
  }

  // ────────────────────────────────────────────────────────────────────
  //  REPORT
  // ────────────────────────────────────────────────────────────────────

  Future<void> submitReport() async {
    final reason = reportController.text.trim();
    if (reason.isEmpty) return;
    if (isSubmittingReport.value) return;

    isSubmittingReport.value = true;

    try {
      await _chatService.submitReport(consultationId: consultationId, reason: reason);
      reportController.clear();
      Get.back(); // Close modal
      Get.snackbar(
        'Laporan Terkirim',
        'Laporan konsultasi Anda telah berhasil dikirim.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Gagal Mengirim Laporan', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmittingReport.value = false;
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  SCROLL
  // ────────────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
