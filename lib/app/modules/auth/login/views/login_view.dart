import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_enums.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
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

          _loginForm(size),
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
          AppDimensions.spacingXSmall.sh,
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

  Widget _loginForm(Size size) {
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
            topLeft: Radius.circular(AppDimensions.radiusPill),
            topRight: Radius.circular(AppDimensions.radiusPill),
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
              AppDimensions.spacingMedium.sh,
              Text(
                'Please proceed with the exploration',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textBodyColor,
                ),
              ),
              AppDimensions.spacing5XLarge.sh,

              Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormLabel(text: 'Email Address'),
                    AppDimensions.spacingMedium.sh,
                    FormTextField(
                      controller: controller.emailController,
                      isObscure: false,
                      fieldType: FormFieldType.email,
                    ),
                    AppDimensions.spacing3XLarge.sh,

                    FormLabel(text: 'Password'),
                    AppDimensions.spacingMedium.sh,
                    FormTextField(
                      controller: controller.passwordController,
                      isObscure: true,
                      fieldType: FormFieldType.password,
                    ),
                    AppDimensions.spacingSemibold.sh,
                  ],
                ),
              ),

              CustomTextButton(text: 'Forgot Password', onPressed: () {}),
              AppDimensions.spacing2XLarge.sh,

              FormButton(text: 'LOGIN', onPressed: controller.login),
              AppDimensions.spacing2XLarge.sh,

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
