import 'package:flutter/material.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_enums.dart';
import 'package:halositek/app/core/constants/app_typography.dart';

class FormTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool isObscure;
  final String? Function(String?)? validator;
  final FormFieldType fieldType;

  const FormTextField({
    super.key,
    required this.controller,
    required this.isObscure,
    this.validator,
    this.fieldType = FormFieldType.text,
  });

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscure;
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }

    if (widget.fieldType == FormFieldType.email) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    } else if (widget.fieldType == FormFieldType.password) {
      if (value.length < 6) {
        return 'Password must be at least 6 characters long';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator ?? _defaultValidator,
      style: AppTypography.bodySmall.copyWith(
        letterSpacing: 1,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.blackColor,
      ),

      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing2XLarge,
          vertical: AppDimensions.spacing2XLarge,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusNone),
          borderSide: const BorderSide(color: AppColors.formBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusNone),
          borderSide: const BorderSide(color: AppColors.formBorderColor),
        ),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor, width: 1.4)),
        suffixIcon:
            widget.fieldType == FormFieldType.password
                ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                )
                : null,
      ),
    );
  }
}
