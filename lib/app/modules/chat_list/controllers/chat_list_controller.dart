import 'package:get/get.dart';
import 'package:halositek/app/data/models/chat_conversation.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class ChatListController extends GetxController {
  final ChatService _chatService;

  ChatListController(this._chatService);

  final conversations = <ChatConversation>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  List<ChatConversation> get filteredConversations {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return conversations;

    return conversations.where((c) {
      final name = c.displayName.toLowerCase();
      final lastMessage = c.lastMessagePreview.toLowerCase();
      return name.contains(query) || lastMessage.contains(query);
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
    final nav = Get.find<NavigationController>();
    nav.navigateTo(
      tabIndex: 0,
      route: '/chat',
      arguments: {
        'conversationId': conversation.id,
        'title': conversation.displayName,
      },
    );
  }
}
