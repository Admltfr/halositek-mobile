import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/architect_service.dart';

import '../controllers/architect_controller.dart';

class ArchitectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArchitectService>(
      () => ArchitectService(Get.find<ApiClient>()),
    );
    Get.lazyPut<ArchitectController>(
      () => ArchitectController(Get.find<ArchitectService>()),
    );
  }
}
