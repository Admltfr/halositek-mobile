import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/catalog_service.dart';

import '../controllers/design_controller.dart';

class DesignBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatalogService>(() => CatalogService(Get.find<ApiClient>()));

    Get.lazyPut<DesignController>(
      () => DesignController(Get.find<CatalogService>()),
    );
  }
}
