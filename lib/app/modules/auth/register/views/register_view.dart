import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_enums.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/core/widgets/custom_text_button.dart';
import 'package:halositek/app/modules/auth/widgets/form_button.dart';
import 'package:halositek/app/modules/auth/widgets/form_label.dart';
import 'package:halositek/app/modules/auth/widgets/form_text_field.dart';
import 'package:halositek/app/modules/auth/widgets/hero_bg.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          HeroBg(size: size),
          _overlayText(size),
          _registerForm(size, controller),
        ],
      ),
    );
  }

  Widget _overlayText(Size size) {
    return Positioned(
      left: size.width * 0.05,
      top: size.height * 0.05,
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
            'Create Your Dream Home with Experts',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerForm(Size size, RegisterController controller) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: size.height * 0.85,
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
                'Create Your Account Here !',
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
              16.0.sh,

              Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormLabel(text: 'Email Address'),
                    8.0.sh,
                    FormTextField(
                      controller: controller.emailController,
                      isObscure: false,
                      fieldType: FormFieldType.email,
                    ),
                    18.0.sh,

                    FormLabel(text: 'Username'),
                    8.0.sh,
                    FormTextField(
                      controller: controller.nameController,
                      isObscure: false,
                      fieldType: FormFieldType.text,
                    ),
                    18.0.sh,

                    FormLabel(text: 'Password'),
                    8.0.sh,
                    FormTextField(
                      controller: controller.passwordController,
                      isObscure: true,
                      fieldType: FormFieldType.password,
                    ),
                    18.0.sh,

                    FormLabel(text: 'Password Confirmation'),
                    8.0.sh,
                    FormTextField(
                      controller: controller.passwordConfirmationController,
                      isObscure: true,
                      fieldType: FormFieldType.password,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field cannot be empty';
                        }
                        if (value != controller.passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    18.0.sh,

                    FormLabel(text: 'Role'),
                    8.0.sh,
                    _dropdown(),
                    10.0.sh,
                  ],
                ),
              ),

              FormButton(text: 'REGISTER', onPressed: controller.register),
              8.0.sh,

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textBodyColor,
                      ),
                    ),
                    CustomTextButton(
                      text: "Login now",
                      onPressed: controller.gotoLogin,
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

  Widget _dropdown() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.role.value,
        items: [
          DropdownMenuItem(value: UserRole.user.text, child: Text('User')),
          DropdownMenuItem(
            value: UserRole.architect.text,
            child: Text('Architect'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.role.value = value;
          }
        },
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: const BorderSide(color: AppColors.formBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: const BorderSide(color: AppColors.formBorderColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor, width: 1.4),
          ),
        ),
      ),
    );
  }
}
