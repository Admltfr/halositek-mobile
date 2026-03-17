import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/widgets/custom_text_button.dart';
import 'package:halositek/app/modules/auth/widgets/form_button.dart';
import 'package:halositek/app/modules/auth/widgets/form_label.dart';
import 'package:halositek/app/modules/auth/widgets/form_text_field.dart';
import 'package:halositek/app/modules/auth/widgets/hero_bg.dart';
import '../controllers/login_controller.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Stack(
        children: [
          HeroBg(size: size),

          _trailingIcon(size),

          _overlayText(size),

          _loginForm(size, controller),
        ],
      ),
    );
  }

  Widget _trailingIcon(Size size) {
    return Positioned(
      top: size.width * 0.05,
      right: size.width * 0.05,
      child: Image.asset(
        'assets/images/logo.png',
        width: size.width * 0.20,
        height: size.width * 0.20,
      ),
    );
  }

  Widget _overlayText(Size size) {
    return Positioned(
      left: size.width * 0.05,
      top: size.height * 0.25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HaloSitek',
            style: AppTypography.headingLarge.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          4.0.sh,
          Text(
            'Please enter your details',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginForm(Size size, LoginController controller) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: size.height * 0.65,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.035,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(44),
            topRight: Radius.circular(44),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: AppTypography.headingMedium.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              8.0.sh,
              Text(
                'Please proceed with the exploration',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textBodyColor,
                ),
              ),
              28.0.sh,

              FormLabel(text: 'Email Address'),
              8.0.sh,
              FormTextField(
                controller: controller.emailController,
                isObscure: false,
              ),
              18.0.sh,

              FormLabel(text: 'Password'),
              8.0.sh,
              FormTextField(
                controller: controller.passwordController,
                isObscure: true,
              ),
              10.0.sh,

              CustomTextButton(text: 'Forgot Password', onPressed: () {}),
              20.0.sh,

              FormButton(text: 'LOGIN', onPressed: controller.login),
              16.0.sh,

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Don't have any account? ",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textBodyColor,
                      ),
                    ),
                    CustomTextButton(
                      text: "Register now",
                      onPressed: controller.gotoRegister,
                      color: AppColors.infoColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
