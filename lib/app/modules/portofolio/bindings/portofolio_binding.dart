import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/architect_service.dart';
import 'package:halositek/app/data/network/award_service.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/data/network/payment_service.dart';

import '../controllers/portofolio_controller.dart';

class PortofolioBinding extends Bindings {
  final String architectId;

  PortofolioBinding({this.architectId = ''});
  @override
  void dependencies() {
    Get.lazyPut<CatalogService>(() => CatalogService(Get.find<ApiClient>()));
    Get.lazyPut<AwardService>(() => AwardService(Get.find<ApiClient>()));
    Get.lazyPut<PaymentService>(() => PaymentService(Get.find<ApiClient>()));
    Get.lazyPut<ChatService>(() => ChatService(Get.find<ApiClient>()));
    Get.lazyPut<ArchitectService>(
      () => ArchitectService(Get.find<ApiClient>()),
    );
    Get.lazyPut<PortofolioController>(
      () => PortofolioController(
        Get.find<CatalogService>(),
        Get.find<AwardService>(),
        Get.find<PaymentService>(),
        Get.find<ChatService>(),
        Get.find<ArchitectService>(),
        architectId: architectId,
      ),
    );
  }
}
