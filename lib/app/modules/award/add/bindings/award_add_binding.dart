import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/award_service.dart';

import '../controllers/award_add_controller.dart';

class AwardAddBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AwardService>()) {
      Get.lazyPut<AwardService>(() => AwardService(Get.find<ApiClient>()));
    }

    Get.lazyPut<AwardAddController>(
      () => AwardAddController(Get.find<AwardService>()),
    );
  }
}
