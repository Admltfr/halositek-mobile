import 'package:get/get.dart';
import 'package:halositek/app/data/network/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService;

  ProfileController(this._authService);

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  Future<void> logout() async {
    try {
      await _authService.logout();

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Log out Failed', e.toString());
    }
  }
}
