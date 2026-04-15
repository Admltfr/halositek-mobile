import 'package:get/get.dart';

import '../controllers/architect_controller.dart';

class ArchitectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArchitectController>(
      () => ArchitectController(),
    );
  }
}
