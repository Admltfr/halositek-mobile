import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/award_service.dart';

import '../controllers/award_detail_controller.dart';

class AwardDetailBinding extends Bindings {
  AwardDetailBinding({this.awardId = ''});

  final String awardId;

  @override
  void dependencies() {
    if (!Get.isRegistered<AwardService>()) {
      Get.lazyPut<AwardService>(() => AwardService(Get.find<ApiClient>()));
    }

    final arg = Get.arguments;
    final resolvedId =
        awardId.isNotEmpty ? awardId : (arg is String ? arg : '');

    Get.lazyPut<AwardDetailController>(
      () =>
          AwardDetailController(Get.find<AwardService>(), awardId: resolvedId),
    );
  }
}
