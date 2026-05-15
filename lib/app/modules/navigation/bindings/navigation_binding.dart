import 'package:get/get.dart';
import 'package:halositek/app/data/network/token_service.dart';

import '../controllers/navigation_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TokenService>(() => TokenService());

    Get.lazyPut<NavigationController>(
      () => NavigationController(Get.find<TokenService>()),
    );
  }
}
