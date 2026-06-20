import 'package:flutter/material.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_typography.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final TextStyle? style;

  const CustomTextButton({super.key, required this.text, required this.onPressed, this.color, this.style});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      child: Text(
        text,
        style:
            style ?? AppTypography.bodyMedium.copyWith(color: color ?? AppColors.primaryColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
