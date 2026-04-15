import 'package:get/get.dart';

import '../controllers/design_controller.dart';

class DesignBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DesignController>(
      () => DesignController(),
    );
  }
}
