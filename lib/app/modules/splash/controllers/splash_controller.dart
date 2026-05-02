import 'package:get/get.dart';
import 'package:halositek/app/data/network/token_service.dart';

class SplashController extends GetxController {
  final TokenService _tokenService = Get.find<TokenService>();

  final isLoading = true.obs;

  final token = 0.obs;
  @override
  void onInit() {
    super.onInit();
    checkToken();
  }

  Future<void> checkToken() async {
    try {
      final accessToken = await _tokenService.getAccessToken();
      final refreshToken = await _tokenService.getRefreshToken();
      isLoading.value = false;
      if (accessToken != null && refreshToken != null) {
        Get.offAllNamed('/navigation', arguments: 0);
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      isLoading.value = false;
      Get.offAllNamed('/login');
    }
  }
}
