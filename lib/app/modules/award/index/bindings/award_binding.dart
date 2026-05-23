import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/award_service.dart';

import '../controllers/award_controller.dart';

class AwardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AwardService>()) {
      Get.lazyPut<AwardService>(() => AwardService(Get.find<ApiClient>()));
    }

    Get.lazyPut<AwardController>(
      () => AwardController(Get.find<AwardService>()),
    );
  }
}
