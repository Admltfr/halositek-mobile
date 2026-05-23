import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/modules/award/widgets/award_form.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controllers/award_edit_controller.dart';

class AwardEditView extends GetView<AwardEditController> {
  const AwardEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Obx(
          () => Skeletonizer(
            enabled: controller.isLoading.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(38, 8, 36, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),
                  22.0.sh,
                  AwardForm(
                    nameController: controller.nameController,
                    projectController: controller.projectController,
                    dateController: controller.dateController,
                    roleController: controller.roleController,
                    descriptionController: controller.descriptionController,
                    onPickDate: () => controller.pickDate(context),
                    onCancel: controller.goBack,
                    onSubmit: controller.submit,
                    submitLabel: 'Submit Changes',
                    cancelLabel: 'Cancel Changes',
                    isSubmitting: controller.isSubmitting.value,
                    fileName: controller.fileName,
                  ),
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
      height: 40,
      child: Row(
        children: [
          InkWell(
            onTap: controller.goBack,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 15),
            ),
          ),
          Expanded(
            child: Text(
              'Edit Award',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHeadingColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}
