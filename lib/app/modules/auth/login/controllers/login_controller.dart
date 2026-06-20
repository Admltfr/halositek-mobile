import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/network/auth_service.dart';
import 'package:halositek/app/data/network/websocket_service.dart';

class LoginController extends GetxController {
  final AuthService _authService;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;

  LoginController(this._authService);

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    
    try {
      isLoading.value = true;
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Connect WebSocket after successful login
      Get.find<WebSocketService>().connect();

      Get.offAllNamed('/navigation', arguments: 0);
    } catch (e) {
      Get.snackbar('Login Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void gotoRegister() {
    Get.toNamed('/register');
  }

  void gotoForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    emailController.dispose();
    passwordController.dispose();
  }
}
