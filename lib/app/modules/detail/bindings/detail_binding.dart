import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/catalog_service.dart';

import '../controllers/detail_controller.dart';

class DetailBinding extends Bindings {
  final String catalogId;

  DetailBinding({this.catalogId = ''});

  @override
  void dependencies() {
    if (!Get.isRegistered<CatalogService>()) {
      Get.lazyPut<CatalogService>(() => CatalogService(Get.find<ApiClient>()));
    }

    Get.lazyPut<DetailController>(() => DetailController(Get.find<CatalogService>(),
        catalogId: catalogId,));
  }
}
