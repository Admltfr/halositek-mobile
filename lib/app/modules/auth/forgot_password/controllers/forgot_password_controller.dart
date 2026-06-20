import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/network/auth_service.dart';

enum ForgotPasswordStep { email, verification, resetPassword }

class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._authService);

  final AuthService _authService;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final otpControllers = List.generate(4, (_) => TextEditingController());
  final otpFocusNodes = List.generate(4, (_) => FocusNode());

  final formKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();
  final currentStep = ForgotPasswordStep.email.obs;
  final isLoading = false.obs;
  final resendSeconds = 0.obs;

  Timer? _timer;
  String _verifiedOtp = '';

  String get email => emailController.text.trim();
  String get otp => otpControllers.map((controller) => controller.text).join();
  bool get canResend => resendSeconds.value == 0 && !isLoading.value;

  Future<void> requestOtp() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    await _run(() async {
      await _authService.requestPasswordOtp(email: email);
      _clearOtp();
      currentStep.value = ForgotPasswordStep.verification;
      _startCountdown(2 * 60);
      Get.snackbar('Kode OTP Terkirim', 'Silakan cek email kamu.');
    }, title: 'Gagal Mengirim OTP');
  }

  Future<void> resendOtp() async {
    if (!canResend) return;

    await _run(() async {
      await _authService.requestPasswordOtp(email: email);
      _clearOtp();
      _startCountdown(2 * 60);
      Get.snackbar('Kode OTP Terkirim', 'Kode baru sudah dikirim ke email.');
    }, title: 'Gagal Mengirim OTP');
  }

  Future<void> verifyOtp() async {
    if (otp.length < 4) {
      Get.snackbar('OTP Belum Lengkap', 'Masukkan 4 digit kode OTP.');
      return;
    }

    await _run(() async {
      await _authService.verifyPasswordOtp(email: email, otp: otp);
      _verifiedOtp = otp;
      currentStep.value = ForgotPasswordStep.resetPassword;
      Get.snackbar('OTP Valid', 'Silakan buat password baru.');
    }, title: 'Verifikasi Gagal');
  }

  Future<void> resetPassword() async {
    if (!(resetFormKey.currentState?.validate() ?? false)) return;

    await _run(() async {
      await _authService.resetPassword(
        email: email,
        otp: _verifiedOtp,
        password: passwordController.text,
        passwordConfirmation: passwordConfirmationController.text,
      );
      Get.snackbar('Berhasil', 'Password berhasil direset.');
      Get.until((route) => route.settings.name == '/login');
    }, title: 'Reset Password Gagal');
  }

  void gotoLogin() {
    Get.back();
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < otpFocusNodes.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }

    if (value != passwordController.text) {
      return 'Password confirmation does not match';
    }

    return null;
  }

  Future<void> _run(Future<void> Function() action, {required String title}) async {
    try {
      isLoading.value = true;
      await action();
    } catch (e) {
      Get.snackbar(title, e.toString());
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    resendSeconds.value = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value <= 1) {
        timer.cancel();
        resendSeconds.value = 0;
      } else {
        resendSeconds.value--;
      }
    });
  }

  void _clearOtp() {
    for (final controller in otpControllers) {
      controller.clear();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }
}
