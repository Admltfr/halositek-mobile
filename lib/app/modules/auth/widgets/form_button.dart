import 'package:flutter/material.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_typography.dart';

class FormButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const FormButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          elevation: 2,
        ),
        child: Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
