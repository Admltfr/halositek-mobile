import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/data/network/token_service.dart';

import '../controllers/chat_list_controller.dart';

class ChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatService>(() => ChatService(Get.find<ApiClient>()));
    Get.lazyPut<ChatListController>(
      () => ChatListController(
        Get.find<ChatService>(),
        Get.find<TokenService>(),
      ),
    );
  }
}
