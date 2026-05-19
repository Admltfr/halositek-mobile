import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/chat_service.dart';

import '../controllers/chat_detail_controller.dart';

class ChatDetailBinding extends Bindings {
  final String conversationId;
  final String title;

  ChatDetailBinding({this.conversationId = '', this.title = ''});

  @override
  void dependencies() {
    Get.lazyPut<ChatService>(() => ChatService(Get.find<ApiClient>()));

    Get.lazyPut<ChatDetailController>(
      () => ChatDetailController(
        Get.find<ChatService>(),
        conversationId: conversationId,
        title: title,
      ),
    );
  }
}
