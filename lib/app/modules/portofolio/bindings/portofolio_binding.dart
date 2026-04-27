import 'package:get/get.dart';

import '../controllers/portofolio_controller.dart';

class PortofolioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PortofolioController>(
      () => PortofolioController(),
    );
  }
}
