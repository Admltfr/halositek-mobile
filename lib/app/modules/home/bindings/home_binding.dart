import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/data/network/architect_service.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatalogService>(() => CatalogService(Get.find<ApiClient>()));
    Get.lazyPut<ArchitectService>(() => ArchitectService(Get.find<ApiClient>()));

    Get.lazyPut<HomeController>(() => HomeController(Get.find<CatalogService>(), Get.find<ArchitectService>()));
  }
}
