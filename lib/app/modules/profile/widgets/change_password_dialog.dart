import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/network/auth_service.dart';

typedef ChangePasswordSubmit =
    Future<void> Function({
      required String currentPassword,
      required String newPassword,
      required String newPasswordConfirmation,
    });

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key, required this.onSubmit});

  final ChangePasswordSubmit onSubmit;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _errors = <String, String>{};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    Expanded(child: _sectionTitle('Password Change')),
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
                _label('Current Password'),
                _input(
                  _currentPasswordController,
                  errorKey: 'current_password',
                ),
                16.0.sh,
                _label('New Password'),
                _input(_newPasswordController, errorKey: 'new_password'),
                16.0.sh,
                _label('Confirm Password'),
                _input(
                  _confirmPasswordController,
                  errorKey: 'new_password_confirmation',
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 7),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textBodyColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, {required String errorKey}) {
    final error = _errors[errorKey];

    return TextField(
      controller: controller,
      obscureText: true,
      enabled: !_isSubmitting,
      onChanged: (_) {
        if (!_errors.containsKey(errorKey)) return;
        setState(() => _errors.remove(errorKey));
      },
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textHeadingColor,
        fontSize: 12,
        height: 1.55,
      ),
      decoration: InputDecoration(
        errorText: error,
        errorMaxLines: 3,
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.errorColor,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: _border(
          error == null
              ? AppColors.textBodyColor.withValues(alpha: 0.62)
              : AppColors.errorColor,
        ),
        focusedBorder: _border(
          error == null ? AppColors.primaryColor : AppColors.errorColor,
        ),
        disabledBorder: _border(
          AppColors.textBodyColor.withValues(alpha: 0.35),
        ),
        errorBorder: _border(AppColors.errorColor),
        focusedErrorBorder: _border(AppColors.errorColor),
        border: _border(AppColors.textBodyColor.withValues(alpha: 0.62)),
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
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
              ),
              child: Text(
                'Cancel Changes',
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
              icon:
                  _isSubmitting
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.whiteColor,
                        ),
                      )
                      : const Icon(Icons.save_outlined, size: 18),
              label: Text(
                'Save Changes',
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
                disabledBackgroundColor: AppColors.primaryColor.withValues(
                  alpha: 0.55,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    try {
      setState(() => _isSubmitting = true);
      await widget.onSubmit(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );
      Get.back();
      Get.snackbar('Password tersimpan', 'Password berhasil diperbarui.');
    } on UserValidationException catch (e) {
      setState(() => _errors.addAll(e.errors));
      Get.snackbar('Password gagal disimpan', e.message);
    } catch (e) {
      Get.snackbar('Password gagal disimpan', e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _validate() {
    final errors = <String, String>{};

    if (_currentPasswordController.text.isEmpty) {
      errors['current_password'] = 'Current password wajib diisi.';
    }
    if (_newPasswordController.text.length < 8) {
      errors['new_password'] = 'New password minimal 8 karakter.';
    }
    if (_confirmPasswordController.text != _newPasswordController.text) {
      errors['new_password_confirmation'] = 'Confirm password tidak sama.';
    }

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    return errors.isEmpty;
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
      borderSide: BorderSide(color: color, width: 1),
    );
  }
}
