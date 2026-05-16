import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/auth_service.dart';
import 'package:halositek/app/data/network/token_service.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(
      () => AuthService(Get.find<ApiClient>(), Get.find<TokenService>()),
    );
    Get.lazyPut<TokenService>(() => TokenService());
    Get.lazyPut<SplashController>(
      () => SplashController(Get.find<AuthService>(), Get.find<TokenService>()),
    );
  }
}
