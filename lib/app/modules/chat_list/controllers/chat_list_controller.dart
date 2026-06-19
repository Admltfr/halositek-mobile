import 'package:get/get.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/data/network/token_service.dart';
import 'package:halositek/app/modules/chat_detail/bindings/chat_detail_binding.dart';
import 'package:halositek/app/modules/chat_detail/views/chat_detail_view.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class ChatListController extends GetxController {
  final ChatService _chatService;
  final TokenService _tokenService;

  ChatListController(this._chatService, this._tokenService);

  // ── Tab / dropdown state ───────────────────────────────────────────
  static const String tabConsultation = 'consultation';
  static const String tabReport = 'report';

  final selectedTab = tabConsultation.obs;
  final isDropdownOpen = false.obs;

  // ── Consultation data ──────────────────────────────────────────────
  final conversations = <ChatConversation>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ── Report data ────────────────────────────────────────────────────
  final reports = <ChatReport>[].obs;
  final isLoadingReports = false.obs;
  final errorReports = ''.obs;

  // ── Search ─────────────────────────────────────────────────────────
  final searchQuery = ''.obs;

  // ── Deprecated filter kept for compatibility (unused now) ──────────
  final statusFilter = ''.obs;

  void cycleStatusFilter() {}

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

    if (tab == tabReport && reports.isEmpty) {
      fetchReports();
    } else if (tab == tabConsultation && conversations.isEmpty) {
      fetchConversations();
    }
  }

  // ── Filtered lists ─────────────────────────────────────────────────
  List<ChatConversation> get filteredConversations {
    final query = searchQuery.value.trim().toLowerCase();
    return conversations.where((c) {
      return query.isEmpty ||
          c.displayName.toLowerCase().contains(query) ||
          c.lastMessagePreview.toLowerCase().contains(query);
    }).toList();
  }

  List<ChatReport> get filteredReports {
    final query = searchQuery.value.trim().toLowerCase();
    return reports.where((r) {
      return query.isEmpty ||
          r.displayName.toLowerCase().contains(query) ||
          r.reason.toLowerCase().contains(query);
    }).toList();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  void goBack() {
    final nav = Get.find<NavigationController>();
    nav.onPop();
  }

  // ── Fetch conversations ────────────────────────────────────────────
  Future<void> fetchConversations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _chatService.getConversations();
      conversations.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Fetch reports ──────────────────────────────────────────────────
  Future<void> fetchReports() async {
    try {
      isLoadingReports.value = true;
      errorReports.value = '';
      final userId = await _tokenService.getUserId();
      if (userId == null || userId.trim().isEmpty) {
        errorReports.value = 'User ID not found';
        return;
      }
      final result = await _chatService.getReports(userId);
      reports.assignAll(result);
    } catch (e) {
      errorReports.value = e.toString();
    } finally {
      isLoadingReports.value = false;
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────
  void openConversation(ChatConversation conversation) {
    Get.to(
      () => const ChatDetailView(),
      binding: ChatDetailBinding(
        conversationId: conversation.id,
        consultationId: conversation.consultationId,
        title: conversation.displayName,
        durationHours: conversation.durationHours,
        conversationStatus: conversation.status,
      ),
    );
  }
}
