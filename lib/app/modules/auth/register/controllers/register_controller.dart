import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_enums.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/data/network/auth_service.dart';

class RegisterController extends GetxController {
  final AuthService _authService;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();
  final RxString role = (UserRole.user.text).obs;

  RegisterController(this._authService);

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> register() async {
    try {
      await _authService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        passwordConfirmation: passwordConfirmationController.text,
        role: role.value,
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
  }
}
