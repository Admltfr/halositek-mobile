import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import '../controllers/ai_chat_controller.dart';

class AiChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatService>(() => ChatService(Get.find<ApiClient>()));
    Get.lazyPut<AiChatController>(
      () => AiChatController(Get.find<ChatService>()),
    );
  }
}
