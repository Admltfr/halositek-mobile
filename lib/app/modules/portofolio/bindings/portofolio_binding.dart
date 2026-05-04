import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/award_service.dart';
import 'package:halositek/app/data/network/catalog_service.dart';

import '../controllers/portofolio_controller.dart';

class PortofolioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatalogService>(() => CatalogService(Get.find<ApiClient>()));
    Get.lazyPut<AwardService>(() => AwardService(Get.find<ApiClient>()));
    Get.lazyPut<PortofolioController>(
      () => PortofolioController(
        Get.find<CatalogService>(),
        Get.find<AwardService>(),
      ),
    );
  }
}
