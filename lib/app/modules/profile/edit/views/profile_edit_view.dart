import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controllers/profile_edit_controller.dart';

class ProfileEditView extends GetView<ProfileEditController> {
  const ProfileEditView({super.key});

  static const String _fallbackImage = 'assets/images/bg-image.png';

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
                  58.0.sh,
                  _sectionTitle('Personal Information'),
                  18.0.sh,
                  _label('Full Name'),
                  _input(controller.nameController),
                  16.0.sh,
                  _label('Professional Title'),
                  _input(controller.headlineController),
                  16.0.sh,
                  _label('Bio'),
                  _input(controller.bioController, maxLines: 4),
                  8.0.sh,
                  _passwordCard(),
                  8.0.sh,
                  _label('Years of Experience'),
                  SizedBox(
                    width: 106,
                    child: _input(
                      controller.experienceController,
                      keyboardType: TextInputType.number,
                      suffixIcon: const Icon(Icons.unfold_more_rounded, size: 18),
                    ),
                  ),
                  30.0.sh,
                  _sectionTitle('Contact Details'),
                  15.0.sh,
                  _label('Email Address'),
                  _input(controller.emailController, keyboardType: TextInputType.emailAddress),
                  38.0.sh,
                  _sectionTitleRow('Fee (Rp)', 'Per Session (Hour)'),
                  15.0.sh,
                  Row(
                    children: [
                      Expanded(
                        child: _input(controller.feeController, keyboardType: TextInputType.number, prefixText: 'Rp. '),
                      ),
                      12.0.sw,
                      Expanded(
                        child: _input(controller.durationController, keyboardType: TextInputType.number, prefixText: ''),
                      ),
                    ],
                  ),
                  78.0.sh,
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
            child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.arrow_back_ios_new_rounded, size: 15)),
          ),
          Expanded(
            child: Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
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
        final url = controller.architect.value?.profilePicture ?? '';
        return Container(
          width: 138,
          height: 138,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondaryColor.withValues(alpha: 0.28), width: 4),
          ),
          child: ClipOval(
            child:
                url.isNotEmpty
                    ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(_fallbackImage, fit: BoxFit.cover),
                    )
                    : Image.asset(_fallbackImage, fit: BoxFit.cover),
          ),
        );
      }),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.bodySmall.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w800, letterSpacing: 1),
    );
  }

  Widget _sectionTitleRow(String left, String right) {
    return Row(children: [Expanded(child: _sectionTitle(left)), 12.0.sw, Expanded(child: _sectionTitle(right))]);
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 5),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _input(
    TextEditingController textController, {
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return TextField(
      controller: textController,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontSize: 15, height: 1.55),
      decoration: InputDecoration(
        prefixText: prefixText,
        prefixStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontSize: 15),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: _border(AppColors.textBodyColor.withValues(alpha: 0.62)),
        focusedBorder: _border(AppColors.primaryColor),
        border: _border(AppColors.textBodyColor.withValues(alpha: 0.62)),
      ),
    );
  }

  Widget _passwordCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 12, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Password'),
          TextField(
            controller: controller.passwordController,
            readOnly: true,
            obscureText: true,
            decoration: InputDecoration(
              suffixIcon: TextButton(
                onPressed: () {
                  Get.snackbar('Password', 'Perubahan password belum tersedia di endpoint profile.');
                },
                child: Text(
                  'CHANGE',
                  style: AppTypography.captionLarge.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: _border(AppColors.textBodyColor.withValues(alpha: 0.62)),
              focusedBorder: _border(AppColors.primaryColor),
              border: _border(AppColors.textBodyColor.withValues(alpha: 0.62)),
            ),
          ),
        ],
      ),
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
                side: BorderSide(color: AppColors.errorColor.withValues(alpha: 0.28)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
              ),
              child: Text('Cancel Changes', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
        12.0.sw,
        Expanded(
          child: SizedBox(
            height: 42,
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isSubmitting.value ? null : controller.submit,
                icon:
                    controller.isSubmitting.value
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteColor),
                        )
                        : const Icon(Icons.save_outlined, size: 18),
                label: Text('Save Changes', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
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
