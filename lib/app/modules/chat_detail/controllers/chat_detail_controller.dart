import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:halositek/app/data/models/conversation_detail.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/data/network/token_service.dart';

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

  final conversationDetail = Rxn<ConversationDetailModel>();
  final otherUserName = ''.obs;
  final otherUserRole = ''.obs;
  final otherUserAvatar = ''.obs;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController reportController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Timer? _expiryTimer;
  Timer? _typingTimer;
  bool _lastTypingStatus = false;

  String get displayTitle =>
      otherUserName.value.trim().isNotEmpty ? otherUserName.value : (title.trim().isNotEmpty ? title : 'Chat');
  String get displayRole => otherUserRole.value;
  String? get displayAvatar => otherUserAvatar.value.trim().isNotEmpty ? otherUserAvatar.value : avatarUrl;

  String get currentStatus => conversationStatus.toLowerCase();

  bool get hasApproved => currentStatus == 'approved';
  bool get hasDeclined => currentStatus == 'declined';
  bool get hasReported => currentStatus == 'new';

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(_onMessageTextChanged);
    fetchMessages();
  }

  @override
  void onClose() {
    _expiryTimer?.cancel();
    _typingTimer?.cancel();
    messageController.removeListener(_onMessageTextChanged);
    messageController.dispose();
    reportController.dispose();
    scrollController.dispose();
    super.onClose();
  }

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

  Future<void> fetchMessages() async {
    if (conversationId.trim().isEmpty) {
      errorMessage.value = 'Conversation ID tidak ditemukan';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await Future.wait([
        _chatService.getMessages(conversationId),
        _chatService.getConversationDetail(conversationId),
      ]);

      final msgs = results[0] as List<ChatMessage>;
      final detail = results[1] as ConversationDetailModel;

      messages.assignAll(msgs.reversed.toList());
      conversationDetail.value = detail;

      final currentUserId = await _tokenService.getUserId() ?? '';

      if (detail.architect?.id == currentUserId) {
        otherUserName.value = detail.user?.name ?? '';
        otherUserRole.value = 'USER';
        otherUserAvatar.value = detail.user?.photoProfileUrl ?? detail.user?.photoProfile ?? '';
      } else {
        otherUserName.value = detail.architect?.name ?? '';
        otherUserRole.value = 'ARCHITECT';
        otherUserAvatar.value = '/storage/${detail.architect?.profilePicture}';
      }

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

  Future<void> sendMessage() async {
    if (isSending.value) return;
    if (isSessionExpired.value) return;

    final text = messageController.text.trim();
    if (text.isEmpty) return;

    isSending.value = true;
    messageController.clear();
    _typingTimer?.cancel();
    _setTypingStatus(false);

    try {
      final message = await _chatService.sendMessage(conversationId: conversationId, body: text);
      messages.add(message);
      _scrollToBottom();
    } catch (e) {
      messageController.text = text;
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

  Future<void> pickAndSendImage() async {
    if (isSending.value) return;
    if (isSessionExpired.value) return;

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);

      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;

      await sendImage(File(path));
    } catch (e) {
      Get.snackbar('Gagal memilih gambar', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> sendImage(File imageFile) async {
    if (isSending.value) return;

    isSending.value = true;

    try {
      final message = await _chatService.sendImage(conversationId: conversationId, imageFile: imageFile);
      messages.add(message);
      _scrollToBottom();
    } catch (e) {
      Get.snackbar('Gagal mengirim gambar', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSending.value = false;
    }
  }

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
