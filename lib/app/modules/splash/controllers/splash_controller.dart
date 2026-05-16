import 'package:get/get.dart';
import 'package:halositek/app/data/network/auth_service.dart';
import 'package:halositek/app/data/network/token_service.dart';

class SplashController extends GetxController {
  final TokenService _tokenService;
  final AuthService _authService;

  SplashController(this._authService, this._tokenService);

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
      if (accessToken != null && accessToken.isNotEmpty) {
        await _authService.validateSession();
        isLoading.value = false;
        Get.offAllNamed('/navigation', arguments: 0);
        return;
      }

      if (refreshToken != null && refreshToken.isNotEmpty) {
        final newAccessToken = await _authService.refreshToken(refreshToken);
        if (newAccessToken != null) {
          await _authService.validateSession();
          isLoading.value = false;
          Get.offAllNamed('/navigation', arguments: 0);
          return;
        }
      }

      isLoading.value = false;
      Get.offAllNamed('/login');
    } catch (_) {
      isLoading.value = false;
      Get.offAllNamed('/login');
    }
  }
}
