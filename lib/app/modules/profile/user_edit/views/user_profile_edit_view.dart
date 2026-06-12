import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/modules/profile/widgets/profile_common_widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controllers/user_profile_edit_controller.dart';

class UserProfileEditView extends GetView<UserProfileEditController> {
  const UserProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Obx(
          () => Skeletonizer(
            enabled: controller.isLoading.value,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),
                  12.0.sh,
                  _avatar(),
                  24.0.sh,
                  Center(
                    child: Text(
                      controller.nameController.text.trim().isNotEmpty
                          ? controller.nameController.text.trim()
                          : '-',
                      textAlign: TextAlign.center,
                      style: AppTypography.headingMedium.copyWith(
                        fontSize: 20,
                        color: AppColors.textHeadingColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  36.0.sh,
                  _sectionTitle('Personal Information'),
                  18.0.sh,
                  _label('Username'),
                  _input(controller.nameController, errorKey: 'name'),
                  16.0.sh,
                  _label('Email'),
                  _input(
                    controller.emailController,
                    errorKey: 'email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  16.0.sh,
                  _passwordCard(),
                  52.0.sh,
                  _actions(),
                  28.0.sh,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          InkWell(
            onTap: controller.goBack,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 15),
            ),
          ),
          Expanded(
            child: Text(
              'Your Profile',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHeadingColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Center(
      child: Obx(() {
        final photo = controller.selectedPhoto.value;
        final photoError = controller.fieldErrors['photo_profile'];
        final url = controller.user.value?.photoProfileUrl ?? '';

        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 138,
                  height: 138,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondaryColor.withValues(alpha: 0.28),
                      width: 4,
                    ),
                  ),
                  child: ClipOval(child: _avatarImage(url, photo: photo)),
                ),
                Positioned(
                  right: 4,
                  bottom: 6,
                  child: InkWell(
                    onTap: controller.pickPhoto,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium,
                        ),
                        border: Border.all(
                          color: AppColors.whiteColor,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.whiteColor,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                if (photo != null)
                  Positioned(
                    left: 4,
                    bottom: 6,
                    child: InkWell(
                      onTap: controller.removePhoto,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.errorColor,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                          border: Border.all(
                            color: AppColors.whiteColor,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.whiteColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (photoError != null) ...[
              8.0.sh,
              Text(
                photoError,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.errorColor,
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _avatarImage(String url, {PlatformFile? photo}) {
    if (photo != null) {
      return Image.file(
        File(photo.path!),
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) =>
                Image.asset(profileFallbackImage, fit: BoxFit.cover),
      );
    }
    if (url.isNotEmpty) {
      return Image.network(
        "${dotenv.env['BASEURL']}$url",
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) =>
                Image.asset(profileFallbackImage, fit: BoxFit.cover),
      );
    }
    return Image.asset(profileFallbackImage, fit: BoxFit.cover);
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 5),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textBodyColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController textController, {
    TextInputType? keyboardType,
    String? errorKey,
  }) {
    return Obx(() {
      final error = errorKey == null ? null : controller.fieldErrors[errorKey];
      return TextField(
        controller: textController,
        keyboardType: keyboardType,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textHeadingColor,
          fontSize: 12,
          height: 1.55,
        ),
        decoration: InputDecoration(
          errorText: error,
          errorMaxLines: 3,
          errorStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.errorColor,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: _border(
            error == null
                ? AppColors.textBodyColor.withValues(alpha: 0.62)
                : AppColors.errorColor,
          ),
          focusedBorder: _border(
            error == null ? AppColors.primaryColor : AppColors.errorColor,
          ),
          errorBorder: _border(AppColors.errorColor),
          focusedErrorBorder: _border(AppColors.errorColor),
          border: _border(AppColors.textBodyColor.withValues(alpha: 0.62)),
        ),
      );
    });
  }

  Widget _passwordCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Password'),
        TextField(
          controller: controller.passwordController,
          readOnly: true,
          obscureText: true,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHeadingColor,
            fontSize: 12,
            height: 1.55,
          ),
          decoration: InputDecoration(
            suffixIcon: TextButton(
              onPressed: controller.openChangePasswordDialog,
              child: Text(
                'CHANGE',
                style: AppTypography.captionLarge.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: _border(
              AppColors.textBodyColor.withValues(alpha: 0.62),
            ),
            focusedBorder: _border(AppColors.primaryColor),
            border: _border(AppColors.textBodyColor.withValues(alpha: 0.62)),
          ),
        ),
      ],
    );
  }

  Widget _actions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: OutlinedButton(
              onPressed: controller.goBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorColor,
                side: BorderSide(
                  color: AppColors.errorColor.withValues(alpha: 0.28),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
              ),
              child: Text(
                'Cancel Changes',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        12.0.sw,
        Expanded(
          child: SizedBox(
            height: 42,
            child: Obx(
              () => ElevatedButton.icon(
                onPressed:
                    controller.isSubmitting.value ? null : controller.submit,
                icon:
                    controller.isSubmitting.value
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.whiteColor,
                          ),
                        )
                        : const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  'Save Changes',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  disabledBackgroundColor: AppColors.primaryColor.withValues(
                    alpha: 0.55,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
      borderSide: BorderSide(color: color, width: 1),
    );
  }
}
