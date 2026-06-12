import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/data/network/payment_service.dart';
import 'package:halositek/app/data/network/token_service.dart';

import '../controllers/detail_controller.dart';

class DetailBinding extends Bindings {
  final String catalogId;

  DetailBinding({this.catalogId = ''});

  @override
  void dependencies() {
    if (!Get.isRegistered<CatalogService>()) {
      Get.lazyPut<CatalogService>(() => CatalogService(Get.find<ApiClient>()));
    }

    if (!Get.isRegistered<PaymentService>()) {
      Get.lazyPut<PaymentService>(() => PaymentService(Get.find<ApiClient>()));
    }

    if (!Get.isRegistered<ChatService>()) {
      Get.lazyPut<ChatService>(() => ChatService(Get.find<ApiClient>()));
    }

    if (!Get.isRegistered<TokenService>()) {
      Get.lazyPut<TokenService>(() => TokenService());
    }

    Get.lazyPut<DetailController>(
      () => DetailController(
        Get.find<CatalogService>(),
        Get.find<PaymentService>(),
        Get.find<ChatService>(),
        Get.find<TokenService>(),
        catalogId: catalogId,
      ),
    );
  }
}
