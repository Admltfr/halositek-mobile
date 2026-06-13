import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/modules/design/controllers/design_form_controller.dart';
import 'package:halositek/app/modules/design/widgets/design_form.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controllers/design_edit_controller.dart';

class DesignEditView extends GetView<DesignEditController> {
  const DesignEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              22.0.sh,
              Obx(
                () => Skeletonizer(
                  enabled: controller.isLoading.value,
                  child: DesignForm(
                    nameController: controller.nameController,
                    descriptionController: controller.descriptionController,
                    estimatedCostController: controller.estimatedCostController,
                    areaController: controller.areaController,
                    highlightFeaturesController:
                        controller.highlightFeaturesController,
                    selectedStyle: controller.selectedStyle.value,
                    styles: DesignFormController.styles,
                    mediaFiles: controller.mediaFiles.toList(),
                    layoutFiles: controller.layoutFiles.toList(),
                    onStyleChanged: controller.changeStyle,
                    onPickMedia: controller.pickMediaDesign,
                    onPickLayout: controller.pickLayoutDesign,
                    onRemoveMedia: controller.removeMediaFile,
                    onRemoveLayout: controller.removeLayoutFile,
                    onCancel: controller.goBack,
                    onSubmit: controller.submit,
                    isSubmitting: controller.isSubmitting.value,
                    submitLabel: controller.submitLabel,
                    cancelLabel: controller.cancelLabel,
                  ),
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
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 15),
            ),
          ),
          Expanded(
            child: Text(
              controller.title,
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
