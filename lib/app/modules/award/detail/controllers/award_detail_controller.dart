import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/network/award_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class AwardDetailController extends GetxController {
  AwardDetailController(this._awardService, {required this.awardId});

  final AwardService _awardService;
  final String awardId;

  final award = Rxn<Award>();
  final isLoading = false.obs;
  final isDeleting = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAward();
  }

  void goBack() {
    Get.find<NavigationController>().onPop();
  }

  Future<void> fetchAward() async {
    if (awardId.trim().isEmpty) {
      errorMessage.value = 'Award ID tidak ditemukan';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      award.value = await _awardService.getAwardById(awardId);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openEdit() async {
    final nav = Get.find<NavigationController>().keyForTab(2)?.currentState;
    final result = await nav?.pushNamed('/award/edit', arguments: award.value ?? awardId);

    if (result != null) {
      await fetchAward();
    }
  }

  Future<void> confirmDeleteAward() async {
    if (isDeleting.value) return;

    await Get.dialog<void>(
      Dialog(
        backgroundColor: AppColors.whiteColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_outline_rounded, color: AppColors.errorColor, size: 44),
                18.0.sh,
                Text(
                  'Confirm Delete',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textHeadingColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                16.0.sh,
                Text(
                  'Are you sure you want to delete this\naward ?',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor, height: 1.5),
                ),
                32.0.sh,
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isDeleting.value ? null : deleteAward,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3F46),
                      disabledBackgroundColor: const Color(0xFFFF3F46).withValues(alpha: 0.72),
                      foregroundColor: AppColors.textWhiteColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
                      elevation: 0,
                    ),
                    child: Text(
                      isDeleting.value ? 'Deleting...' : 'Delete Award',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textWhiteColor, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                12.0.sh,
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isDeleting.value ? null : () => Get.back<void>(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8F7F6),
                      disabledBackgroundColor: const Color(0xFFF8F7F6),
                      foregroundColor: AppColors.textBodyColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTypography.bodySmall.copyWith(color: const Color(0xFF475569), fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> deleteAward() async {
    final id = award.value?.id ?? awardId;
    if (id.trim().isEmpty || isDeleting.value) return;

    try {
      isDeleting.value = true;
      await _awardService.deleteAward(id);
      if (Get.isDialogOpen == true) {
        Get.back<void>();
      }
      Get.find<NavigationController>().onPop();
    } catch (e) {
      Get.snackbar('Delete gagal', e.toString());
    } finally {
      isDeleting.value = false;
    }
  }
}
