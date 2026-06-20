import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';

typedef ClearChatSubmit = Future<void> Function();

class ClearChatDialog extends StatefulWidget {
  const ClearChatDialog({super.key, required this.onSubmit});

  final ClearChatSubmit onSubmit;

  @override
  State<ClearChatDialog> createState() => _ClearChatDialogState();
}

class _ClearChatDialogState extends State<ClearChatDialog> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 356),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _sectionTitle('Clear Chat')),
                    InkWell(
                      onTap: _isSubmitting ? null : Get.back,
                      borderRadius: BorderRadius.circular(18),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: AppColors.textHeadingColor,
                        ),
                      ),
                    ),
                  ],
                ),
                16.0.sh,
                Text(
                  'Apakah Anda yakin ingin menghapus semua riwayat pesan chat AI ini? Tindakan ini tidak dapat dibatalkan.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textBodyColor,
                    height: 1.5,
                  ),
                ),
                40.0.sh,
                _actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
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
              onPressed: _isSubmitting ? null : Get.back,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMedium,
                  vertical: AppDimensions.spacingSemibold,
                ),
                foregroundColor: AppColors.errorColor,
                side: BorderSide(
                  color: AppColors.errorColor.withValues(alpha: 0.28),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
              child: Text(
                'Cancel',
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
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.whiteColor,
                      ),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(
                'Clear',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMedium,
                  vertical: AppDimensions.spacingSemibold,
                ),
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.whiteColor,
                disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    try {
      setState(() => _isSubmitting = true);
      await widget.onSubmit();
      Get.back();
    } catch (e) {
      Get.snackbar('Failed', e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
