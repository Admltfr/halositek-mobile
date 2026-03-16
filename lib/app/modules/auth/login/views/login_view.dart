import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/modules/auth/login/widgets/hero_bg.dart';
import '../controllers/login_controller.dart';
import 'package:halositek/app/constants/app_dimensions.dart';
import 'package:halositek/app/constants/app_colors.dart';
import 'package:halositek/app/constants/app_extensions.dart';
import 'package:halositek/app/constants/app_typography.dart';

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

              Text(
                'Username',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textLabelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.0.sh,
              TextField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(
                      color: AppColors.formBorderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(
                      color: AppColors.formBorderColor,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
              18.0.sh,

              Text(
                'Password',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textBlackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.0.sh,
              TextField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(
                      color: AppColors.formBorderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(
                      color: AppColors.formBorderColor,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.4,
                    ),
                  ),
                  suffixIcon: Icon(
                    Icons.remove_red_eye_outlined,
                    color: AppColors.formBorderColor,
                    size: 20,
                  ),
                ),
              ),
              10.0.sh,

              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot Password?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              20.0.sh,

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                  ),
                  child: Text(
                    'LOGIN',
                    style: AppTypography.bodyMedium.copyWith(
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
              16.0.sh,

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Don't have any account? ",
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textBodyColor,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.gotoRegister,
                      child: Text(
                        'Register now',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.infoColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
