import 'package:flutter/material.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_typography.dart';

class FormButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const FormButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
          disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.6),
          disabledForegroundColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing2XLarge),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.whiteColor,
                ),
              )
            : Text(
                text,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 13,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.whiteColor,
                ),
              ),
      ),
    );
  }
}
