import 'package:get/get.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/award_service.dart';

import '../controllers/award_edit_controller.dart';

class AwardEditBinding extends Bindings {
  AwardEditBinding({this.awardId = '', this.initialAward});

  final String awardId;
  final Award? initialAward;

  @override
  void dependencies() {
    if (!Get.isRegistered<AwardService>()) {
      Get.lazyPut<AwardService>(() => AwardService(Get.find<ApiClient>()));
    }

    final arg = Get.arguments;
    final resolvedAward = initialAward ?? (arg is Award ? arg : null);
    final resolvedId =
        awardId.isNotEmpty
            ? awardId
            : (arg is String ? arg : resolvedAward?.id ?? '');

    Get.lazyPut<AwardEditController>(
      () => AwardEditController(
        Get.find<AwardService>(),
        awardId: resolvedId,
        initialAward: resolvedAward,
      ),
    );
  }
}
