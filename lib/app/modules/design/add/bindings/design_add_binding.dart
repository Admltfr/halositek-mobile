import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/catalog_service.dart';

import '../controllers/design_add_controller.dart';

class DesignAddBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CatalogService>()) {
      Get.lazyPut<CatalogService>(() => CatalogService(Get.find<ApiClient>()));
    }

    Get.lazyPut<DesignAddController>(
      () => DesignAddController(Get.find<CatalogService>()),
    );
  }
}
