import 'package:get/get.dart';
import 'package:halositek/app/data/network/auth_service.dart';

class RegisterController extends GetxController {
  final AuthService _authService;

  RegisterController(this._authService);

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      Get.offNamed('/home');
    } catch (e) {
      Get.snackbar('Registration Failed', e.toString());
    }
  }

  void gotoLogin() {
    Get.toNamed('/login');
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
