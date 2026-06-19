import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/chat_service.dart';

import '../controllers/chat_detail_controller.dart';

class ChatDetailBinding extends Bindings {
  final String conversationId;
  final String consultationId;
  final String title;
  final int durationHours;
  final String conversationStatus;
  final String? avatarUrl;

  ChatDetailBinding({
    this.conversationId = '',
    this.consultationId = '',
    this.title = '',
    this.durationHours = 0,
    this.conversationStatus = '',
    this.avatarUrl,
  });

  @override
  void dependencies() {
    Get.lazyPut<ChatService>(() => ChatService(Get.find<ApiClient>()));

    Get.lazyPut<ChatDetailController>(
      () => ChatDetailController(
        Get.find<ChatService>(),
        conversationId: conversationId,
        consultationId: consultationId,
        title: title,
        durationHours: durationHours,
        avatarUrl: avatarUrl,
        conversationStatus: conversationStatus,
      ),
    );
  }
}
