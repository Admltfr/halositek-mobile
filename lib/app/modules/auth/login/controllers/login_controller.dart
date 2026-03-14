import 'package:get/get.dart';
import 'package:halositek/app/data/network/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService;

  LoginController(this._authService);

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email: email, password: password);

      Get.offNamed('/home');
    } catch (e) {
      Get.snackbar('Login Failed', e.toString());
    }
  }

  void gotoRegister() {
    Get.toNamed('/register');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
