import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/modules/award/widgets/award_form.dart';

import '../controllers/award_add_controller.dart';

class AwardAddView extends GetView<AwardAddController> {
  const AwardAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(38, 8, 36, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              22.0.sh,
              Obx(
                () => AwardForm(
                  nameController: controller.nameController,
                  projectController: controller.projectController,
                  dateController: controller.dateController,
                  roleController: controller.roleController,
                  descriptionController: controller.descriptionController,
                  onPickDate: () => controller.pickDate(context),
                  onCancel: controller.goBack,
                  onSubmit: controller.submit,
                  submitLabel: 'Submit Award',
                  cancelLabel: 'Cancel Award',
                  isSubmitting: controller.isSubmitting.value,
                ),
              ),
            ],
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
              'New Award',
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
