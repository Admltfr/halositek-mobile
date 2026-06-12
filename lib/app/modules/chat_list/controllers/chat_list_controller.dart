import 'package:get/get.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/modules/chat_detail/bindings/chat_detail_binding.dart';
import 'package:halositek/app/modules/chat_detail/views/chat_detail_view.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class ChatListController extends GetxController {
  final ChatService _chatService;

  ChatListController(this._chatService);

  final conversations = <ChatConversation>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  final statusFilter = ''.obs;

  static const _filterCycle = ['', 'approved', 'declined', 'new'];

  void cycleStatusFilter() {
    final current = statusFilter.value;
    final idx = _filterCycle.indexOf(current);
    final next = (idx + 1) % _filterCycle.length;
    statusFilter.value = _filterCycle[next];
  }

  List<ChatConversation> get filteredConversations {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = statusFilter.value.toLowerCase();

    return conversations.where((c) {
      final matchesSearch =
          query.isEmpty ||
          c.displayName.toLowerCase().contains(query) ||
          c.lastMessagePreview.toLowerCase().contains(query);

      final matchesFilter = filter.isEmpty || c.status.toLowerCase() == filter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  void goBack() {
    final nav = Get.find<NavigationController>();
    nav.onPop();
  }

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
