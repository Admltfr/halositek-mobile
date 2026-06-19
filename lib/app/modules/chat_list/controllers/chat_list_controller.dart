import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/data/network/token_service.dart';
import 'package:halositek/app/data/network/websocket_service.dart';
import 'package:halositek/app/modules/chat_detail/bindings/chat_detail_binding.dart';
import 'package:halositek/app/modules/chat_detail/views/chat_detail_view.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class ChatListController extends GetxController {
  final ChatService _chatService;
  final TokenService _tokenService;

  ChatListController(this._chatService, this._tokenService);

  final isArchitect = false.obs;

  // ── Tab / dropdown state ───────────────────────────────────────────
  static const String tabConsultation = 'consultation';
  static const String tabReport = 'report';

  final selectedTab = tabConsultation.obs;
  final isDropdownOpen = false.obs;

  // ── Consultation data ──────────────────────────────────────────────
  final conversations = <ChatConversation>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isLoadingMoreConversations = false.obs;
  int _conversationsPage = 1;
  int _conversationsLastPage = 1;

  // ── Report data ────────────────────────────────────────────────────
  final reports = <ChatReport>[].obs;
  final isLoadingReports = false.obs;
  final errorReports = ''.obs;
  final isLoadingMoreReports = false.obs;
  int _reportsPage = 1;
  int _reportsLastPage = 1;

  // ── Search ─────────────────────────────────────────────────────────
  final searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Scroll controllers for infinite scroll
  final ScrollController conversationsScrollController = ScrollController();
  final ScrollController reportsScrollController = ScrollController();

  // ── WebSocket channel tracking ─────────────────────────────────────
  final Set<String> _subscribedConversationIds = {};

  // ── Lifecycle ──────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    // Setup debounce for search
    debounce(searchQuery, (_) => refreshData(), time: const Duration(milliseconds: 500));

    // Setup infinite scroll listeners
    conversationsScrollController.addListener(() {
      if (conversationsScrollController.position.pixels >= conversationsScrollController.position.maxScrollExtent - 200) {
        loadMoreConversations();
      }
    });

    reportsScrollController.addListener(() {
      if (reportsScrollController.position.pixels >= reportsScrollController.position.maxScrollExtent - 200) {
        loadMoreReports();
      }
    });

    _bootstrap();
  }

  @override
  void onClose() {
    searchController.dispose();
    conversationsScrollController.dispose();
    reportsScrollController.dispose();
    _unsubscribeAllConversations();
    super.onClose();
  }

  void goBack() {
    final nav = Get.find<NavigationController>();
    nav.onPop();
  }

  Future<void> _bootstrap() async {
    final tokenService = Get.find<TokenService>();
    final role = (await tokenService.getRole() ?? '').trim().toLowerCase();
    isArchitect.value = role == 'architect';
    await fetchConversations();
  }

  // ────────────────────────────────────────────────────────────────────
  //  WEBSOCKET – subscribe/unsubscribe all conversations
  // ────────────────────────────────────────────────────────────────────

  void _subscribeConversations(List<ChatConversation> convos) {
    try {
      final ws = Get.find<WebSocketService>();

      for (final c in convos) {
        if (_subscribedConversationIds.contains(c.id)) continue;

        final channel = 'private-chat.conversation.${c.id}';
        ws.subscribe(channel);
        ws.on(channel, 'chat.message.sent', (data) => _onWsNewMessage(c.id, data));
        _subscribedConversationIds.add(c.id);
      }

      debugPrint('[ChatList] 📡 Subscribed to ${_subscribedConversationIds.length} conversation channels');
    } catch (e) {
      debugPrint('[ChatList] ❌ WebSocket subscribe error: $e');
    }
  }

  void _unsubscribeAllConversations() {
    try {
      final ws = Get.find<WebSocketService>();

      for (final id in _subscribedConversationIds) {
        final channel = 'private-chat.conversation.$id';
        ws.unsubscribe(channel);
      }
      _subscribedConversationIds.clear();

      debugPrint('[ChatList] 🔕 Unsubscribed from all conversation channels');
    } catch (e) {
      debugPrint('[ChatList] ❌ WebSocket unsubscribe error: $e');
    }
  }

  void _onWsNewMessage(String conversationId, Map<String, dynamic> data) {
    try {
      final messageData = data['message'];
      if (messageData == null || messageData is! Map) return;

      final message = ChatMessage.fromJson(Map<String, dynamic>.from(messageData));

      // Find the conversation in the list
      final index = conversations.indexWhere((c) => c.id == conversationId);
      if (index == -1) return;

      final existing = conversations[index];

      // Create updated conversation with new last message and incremented
      // unread count (only if the message is NOT from the current user)
      final newUnread = message.isMine ? existing.unreadCount : existing.unreadCount + 1;

      final updated = ChatConversation(
        id: existing.id,
        name: existing.name,
        isGroup: existing.isGroup,
        participantIds: existing.participantIds,
        lastReadAt: existing.lastReadAt,
        unreadCount: newUnread,
        lastMessage: message,
        updatedAt: DateTime.now(),
        createdAt: existing.createdAt,
        durationHours: existing.durationHours,
        status: existing.status,
        consultationId: existing.consultationId,
        user: existing.user,
        architect: existing.architect,
        session: existing.session,
      );

      // Replace in list and move to top
      conversations.removeAt(index);
      conversations.insert(0, updated);

      debugPrint('[ChatList] 📨 Updated conversation $conversationId with new message');
    } catch (e) {
      debugPrint('[ChatList] ❌ Error handling WS message: $e');
    }
  }

  // ── Tab switching ──────────────────────────────────────────────────
  void toggleDropdown() {
    isDropdownOpen.value = !isDropdownOpen.value;
  }

  void changeTab(String tab) {
    if (selectedTab.value == tab) {
      isDropdownOpen.value = false;
      return;
    }
    selectedTab.value = tab;
    isDropdownOpen.value = false;

    // Reset search when switching tabs? Let's keep it, but trigger refresh
    refreshData();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  Future<void> refreshData() async {
    if (selectedTab.value == tabConsultation) {
      _conversationsPage = 1;
      await fetchConversations();
    } else {
      _reportsPage = 1;
      await fetchReports();
    }
  }

  // ── Fetch conversations ────────────────────────────────────────────
  Future<void> fetchConversations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      if (_conversationsPage == 1) {
        conversations.clear();
      }
      final result = await _chatService.getConversations(page: _conversationsPage, perPage: 10, search: searchQuery.value);
      conversations.assignAll(result.conversations);
      _conversationsLastPage = result.meta.lastPage;

      // Subscribe to WebSocket channels for all loaded conversations
      _subscribeConversations(result.conversations);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreConversations() async {
    if (isLoading.value || isLoadingMoreConversations.value || _conversationsPage >= _conversationsLastPage) {
      return;
    }

    try {
      isLoadingMoreConversations.value = true;
      _conversationsPage++;
      final result = await _chatService.getConversations(page: _conversationsPage, perPage: 10, search: searchQuery.value);
      conversations.addAll(result.conversations);
      _conversationsLastPage = result.meta.lastPage;

      // Subscribe to newly loaded conversations
      _subscribeConversations(result.conversations);
    } catch (e) {
      _conversationsPage--;
      Get.snackbar('Error', 'Failed to load more conversations: $e');
    } finally {
      isLoadingMoreConversations.value = false;
    }
  }

  // ── Fetch reports ──────────────────────────────────────────────────
  Future<void> fetchReports() async {
    try {
      isLoadingReports.value = true;
      errorReports.value = '';
      if (_reportsPage == 1) {
        reports.clear();
      }
      final userId = await _tokenService.getUserId();
      if (userId == null || userId.trim().isEmpty) {
        errorReports.value = 'User ID not found';
        return;
      }
      final result = await _chatService.getReports(userId, page: _reportsPage, perPage: 10, search: searchQuery.value);
      reports.assignAll(result.reports);
      _reportsLastPage = result.meta.lastPage;
    } catch (e) {
      errorReports.value = e.toString();
    } finally {
      isLoadingReports.value = false;
    }
  }

  Future<void> loadMoreReports() async {
    if (isLoadingReports.value || isLoadingMoreReports.value || _reportsPage >= _reportsLastPage) {
      return;
    }

    try {
      isLoadingMoreReports.value = true;
      final userId = await _tokenService.getUserId();
      if (userId == null || userId.trim().isEmpty) return;

      _reportsPage++;
      final result = await _chatService.getReports(userId, page: _reportsPage, perPage: 10, search: searchQuery.value);
      reports.addAll(result.reports);
      _reportsLastPage = result.meta.lastPage;
    } catch (e) {
      _reportsPage--;
      Get.snackbar('Error', 'Failed to load more reports: $e');
    } finally {
      isLoadingMoreReports.value = false;
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────
  void openConversation(ChatConversation conversation) {
    String? avatarUrl;

    if (isArchitect.value) {
      if (conversation.user?.profilePicture != null && conversation.user!.profilePicture!.isNotEmpty) {
        if (conversation.user!.profilePicture!.startsWith('http')) {
          avatarUrl = conversation.user!.profilePicture;
        } else {
          final base = ApiClient.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? '';
          avatarUrl = '$base/storage/${conversation.user!.profilePicture}';
        }
      }
    } else {
      if (conversation.architect?.profilePicture != null && conversation.architect!.profilePicture!.isNotEmpty) {
        if (conversation.architect!.profilePicture!.startsWith('http')) {
          avatarUrl = conversation.architect!.profilePicture;
        } else {
          final base = ApiClient.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? '';
          avatarUrl = '$base/storage/${conversation.architect!.profilePicture}';
        }
      }
    }

    Get.to(
      () => const ChatDetailView(),
      binding: ChatDetailBinding(
        conversationId: conversation.id,
        consultationId: conversation.consultationId,
        title: conversation.displayName,
        durationHours: conversation.durationHours,
        conversationStatus: conversation.status,
        avatarUrl: avatarUrl,
      ),
    );
  }
}
