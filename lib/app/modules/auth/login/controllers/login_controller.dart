import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/network/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginController(this._authService);

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  Future<void> login() async {
    try {
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

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
