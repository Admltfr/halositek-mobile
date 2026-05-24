import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controllers/award_detail_controller.dart';

class AwardDetailView extends GetView<AwardDetailController> {
  const AwardDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Obx(() {
          final hasError = controller.errorMessage.value.isNotEmpty;
          final hasData = controller.award.value != null;

          if (hasError && !hasData) {
            return Center(child: TextButton(onPressed: controller.fetchAward, child: const Text('Coba Lagi')));
          }

          final award = controller.award.value ?? Award.dummy();

          return Skeletonizer(
            enabled: controller.isLoading.value,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.01),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),
                  24.0.sh,
                  Text(
                    'Verification Proof',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
                  ),
                  14.0.sh,
                  _proofImage(award),
                  24.0.sh,
                  Text(
                    award.name,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
                  ),
                  18.0.sh,
                  _infoCard(award),
                  18.0.sh,
                  Text(
                    'Award Description',
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
                  ),
                  12.0.sh,
                  Text(
                    award.description.isEmpty ? '-' : award.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textBodyColor,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  36.0.sh,
                  _actionButtons(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _topBar() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          InkWell(
            onTap: controller.goBack,
            borderRadius: BorderRadius.circular(18),
            child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.arrow_back_ios_new_rounded, size: 16)),
          ),
          Expanded(
            child: Text(
              'Award Details',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _proofImage(Award award) {
    final url = award.verificationFileUrl.trim();

    return Container(
      width: double.infinity,
      height: 194,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          url.isNotEmpty
              ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _proofFallback())
              : _proofFallback(),
    );
  }

  Widget _proofFallback() {
    return Container(
      color: AppColors.subtleSurfaceColor,
      alignment: Alignment.center,
      child: const Icon(Icons.workspace_premium_outlined, size: 52, color: AppColors.primaryColor),
    );
  }

  Widget _infoCard(Award award) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          _infoRow('PROJECT NAME', award.projectName),
          _divider(),
          _infoRow('ROLE', award.role),
          _divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 17, 20, 18),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATUS',
                    style: AppTypography.captionLarge.copyWith(
                      color: AppColors.textBodyColor.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  8.0.sh,
                  Row(
                    children: [
                      const Icon(Icons.verified, color: AppColors.successColor, size: 18),
                      6.0.sw,
                      Text(
                        award.isApproved ? 'Verified' : 'Submission',
                        style: AppTypography.bodyMedium.copyWith(
                          color: award.isApproved ? AppColors.successColor : AppColors.warningColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 18),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.captionLarge.copyWith(
                color: AppColors.textBodyColor.withValues(alpha: 0.86),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            8.0.sh,
            Text(
              value.trim().isEmpty ? '-' : value,
              textAlign: TextAlign.left,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHeadingColor,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: AppColors.formBorderColor.withValues(alpha: 0.18));
  }

  Widget _actionButtons() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            flex: 5,
            child: OutlinedButton(
              onPressed: controller.isDeleting.value ? null : controller.deleteAward,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.errorColor.withValues(alpha: 0.35)),
                foregroundColor: AppColors.errorColor,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
              ),
              child: Text(
                controller.isDeleting.value ? 'Deleting...' : 'Delete Design',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          12.0.sw,
          Expanded(
            flex: 5,
            child: ElevatedButton.icon(
              onPressed: controller.openEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(
                'Edit Design',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textWhiteColor, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.textWhiteColor,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
