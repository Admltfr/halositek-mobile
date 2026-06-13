import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_enums.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/core/widgets/custom_text_button.dart';
import 'package:halositek/app/modules/auth/widgets/form_label.dart';
import 'package:halositek/app/modules/auth/widgets/form_text_field.dart';
import 'package:halositek/app/modules/auth/widgets/hero_bg.dart';

import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Stack(children: [HeroBg(size: size), _trailingIcon(size), _overlayText(size), _formSheet(size)]),
    );
  }

  Widget _trailingIcon(Size size) {
    return Positioned(
      top: size.width * 0.05,
      right: size.width * 0.05,
      child: Image.asset('assets/images/logo.png', width: size.width * 0.20, height: size.width * 0.20),
    );
  }

  Widget _overlayText(Size size) {
    return Positioned(
      left: size.width * 0.05,
      top: size.height * 0.25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HaloSitek', style: AppTypography.headingLarge.copyWith(color: AppColors.primaryColor)),
          AppDimensions.spacingXSmall.sh,
          Text('Please enter your details', style: AppTypography.bodyMedium.copyWith(color: AppColors.whiteColor)),
        ],
      ),
    );
  }

  Widget _formSheet(Size size) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: size.height * 0.65,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.075, vertical: size.height * 0.04),
        decoration: const BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusPill),
            topRight: Radius.circular(AppDimensions.radiusPill),
          ),
        ),
        child: SingleChildScrollView(
          child: Obx(() {
            switch (controller.currentStep.value) {
              case ForgotPasswordStep.email:
                return _emailStep();
              case ForgotPasswordStep.verification:
                return _verificationStep();
              case ForgotPasswordStep.resetPassword:
                return _resetPasswordStep();
            }
          }),
        ),
      ),
    );
  }

  Widget _emailStep() {
    return Form(
      key: controller.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Forgot Password'),
          AppDimensions.spacing2XLarge.sh,
          const FormLabel(text: 'Email'),
          AppDimensions.spacingMedium.sh,
          FormTextField(controller: controller.emailController, isObscure: false, fieldType: FormFieldType.email),
          AppDimensions.spacingSmall.sh,
          GestureDetector(
            onTap: controller.gotoLogin,
            child: Text(
              "Back to login?",
              style: AppTypography.bodySmall.copyWith(color: AppColors.accentColor, fontWeight: FontWeight.w600),
            ),
          ),
          AppDimensions.spacingXLarge.sh,
          _primaryButton(text: 'Send Verification Code', onPressed: controller.requestOtp),
          AppDimensions.spacing2XLarge.sh,
        ],
      ),
    );
  }

  Widget _verificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Verification'),
        AppDimensions.spacing2XLarge.sh,
        Center(
          child: Text(
            'Verification Code',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textBodyColor,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
            ),
          ),
        ),
        AppDimensions.spacingMedium.sh,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            controller.otpControllers.length,
            (index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: _otpField(index)),
          ),
        ),
        AppDimensions.spacing4XLarge.sh,
        _primaryButton(text: 'Verify', onPressed: controller.verifyOtp),
        AppDimensions.spacingSmall.sh,
        Center(
          child: Obx(() {
            if (controller.resendSeconds.value > 0) {
              return Text(
                'Resend code in ${controller.resendSeconds.value}s',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor),
              );
            }

            return CustomTextButton(text: 'Resend Code', onPressed: controller.resendOtp, color: AppColors.infoColor);
          }),
        ),
      ],
    );
  }

  Widget _resetPasswordStep() {
    return Form(
      key: controller.resetFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Create New Password'),
          AppDimensions.spacing2XLarge.sh,
          const FormLabel(text: 'New Password'),
          AppDimensions.spacingMedium.sh,
          FormTextField(controller: controller.passwordController, isObscure: true, fieldType: FormFieldType.password),
          AppDimensions.spacing3XLarge.sh,
          const FormLabel(text: 'Confirm Password'),
          AppDimensions.spacingMedium.sh,
          FormTextField(
            controller: controller.passwordConfirmationController,
            isObscure: true,
            fieldType: FormFieldType.password,
            validator: controller.confirmPasswordValidator,
          ),
          AppDimensions.spacing5XLarge.sh,
          _primaryButton(text: 'Submit', onPressed: controller.resetPassword),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.bodySmall.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w800, letterSpacing: 3),
    );
  }

  Widget _otpField(int index) {
    return SizedBox(
      width: 44,
      height: 50,
      child: TextField(
        controller: controller.otpControllers[index],
        focusNode: controller.otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTypography.headingSmall.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColors.whiteColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            borderSide: const BorderSide(color: AppColors.formBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.4),
          ),
        ),
        onChanged: (value) => controller.onOtpChanged(value, index),
      ),
    );
  }

  Widget _primaryButton({required String text, required Future<void> Function() onPressed}) {
    return Center(
      child: Obx(
        () => SizedBox(
          width: 220,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              disabledBackgroundColor: AppColors.formBorderColor,
              foregroundColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              elevation: 0,
            ),
            child:
                controller.isLoading.value
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
                      ),
                    )
                    : Text(
                      text,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.whiteColor, fontWeight: FontWeight.w500),
                    ),
          ),
        ),
      ),
    );
  }
}
