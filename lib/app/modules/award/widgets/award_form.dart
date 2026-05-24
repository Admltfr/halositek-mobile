import 'package:flutter/material.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';

class AwardForm extends StatelessWidget {
  const AwardForm({
    super.key,
    required this.nameController,
    required this.projectController,
    required this.dateController,
    required this.roleController,
    required this.descriptionController,
    required this.onPickDate,
    required this.onCancel,
    required this.onSubmit,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.submitLabel,
    required this.cancelLabel,
    this.isSubmitting = false,
    this.fileName = '',
    this.fileSizeLabel = '',
    this.hasNewFile = false,
    this.canRemoveFile = true,
  });

  final TextEditingController nameController;
  final TextEditingController projectController;
  final TextEditingController dateController;
  final TextEditingController roleController;
  final TextEditingController descriptionController;
  final VoidCallback onPickDate;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  final String submitLabel;
  final String cancelLabel;
  final bool isSubmitting;
  final String fileName;
  final String fileSizeLabel;
  final bool hasNewFile;
  final bool canRemoveFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(),
        28.0.sh,
        _field('Award name', 'Name of the award...', nameController, maxLines: 3, maxWords: 12),
        18.0.sh,
        _field('Project name', 'Name of project award', projectController, maxLines: 3, maxWords: 12),
        18.0.sh,
        _field(
          'Award Date',
          'MM/DD/YYYY',
          dateController,
          readOnly: true,
          suffix: IconButton(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_month_outlined, size: 20),
            color: AppColors.primaryColor,
          ),
          onTap: onPickDate,
        ),
        18.0.sh,
        _field('Role', 'Lead Architect', roleController),
        18.0.sh,
        _field('award description', 'Describe the award..', descriptionController, maxLines: 7, maxWords: 30),
        28.0.sh,
        _verificationBox(),
        48.0.sh,
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isSubmitting ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  side: BorderSide(color: AppColors.errorColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                ),
                child: Text(cancelLabel, style: AppTypography.bodyMedium.copyWith(color: AppColors.errorColor)),
              ),
            ),
            12.0.sw,
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                icon:
                    isSubmitting
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add_rounded, size: 16),
                label: Text(submitLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textWhiteColor,
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle() {
    return Row(
      children: [
        const Icon(Icons.workspace_premium_outlined, size: 20, color: AppColors.primaryColor),
        8.0.sw,
        Text(
          'AWARD INFORMATIONS',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    int? maxWords,
    bool readOnly = false,
    Widget? suffix,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textLabelColor,
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (maxWords != null)
              AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  final count = _wordCount(controller.text);
                  final isOver = count > maxWords;
                  return Text(
                    '$count/$maxWords',
                    style: AppTypography.bodySmall.copyWith(
                      color: isOver ? AppColors.errorColor : AppColors.textBodyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
          ],
        ),
        6.0.sh,
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.whiteColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            enabledBorder: _border(),
            focusedBorder: _border(color: AppColors.primaryColor),
            errorBorder: _border(color: AppColors.errorColor),
            focusedErrorBorder: _border(color: AppColors.errorColor),
          ),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor),
        ),
      ],
    );
  }

  OutlineInputBorder _border({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      borderSide: BorderSide(color: (color ?? AppColors.formBorderColor).withValues(alpha: 0.35)),
    );
  }

  Widget _verificationBox() {
    final hasFile = fileName.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.accentColor.withValues(alpha: 0.45), style: BorderStyle.solid),
      ),
      child:
          hasFile
              ? Column(
                children: [
                  Text(
                    'Verification Proof',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w800),
                  ),
                  12.0.sh,
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                      border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.18)),
                      boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 16, offset: Offset(0, 8))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primaryColor),
                        ),
                        12.0.sw,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textHeadingColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              3.0.sh,
                              Text(
                                [
                                  if (fileSizeLabel.isNotEmpty) fileSizeLabel,
                                  hasNewFile ? 'READY TO UPLOAD' : 'UPLOADED',
                                ].join('  •  '),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textBodyColor,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canRemoveFile)
                          IconButton(
                            onPressed: onRemoveFile,
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            color: AppColors.errorColor,
                            tooltip: 'Remove file',
                          ),
                      ],
                    ),
                  ),
                  12.0.sh,
                  TextButton.icon(
                    onPressed: onPickFile,
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: Text(hasNewFile ? 'Choose another file' : 'Replace file'),
                  ),
                ],
              )
              : InkWell(
                onTap: onPickFile,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryColor),
                    ),
                    12.0.sh,
                    Text(
                      'Verification Proof',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textHeadingColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    4.0.sh,
                    Text(
                      'Upload PDF, JPG, JPEG, or PNG (Max 5 MB)',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor),
                    ),
                    12.0.sh,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                      ),
                      child: Text(
                        'Choose File',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  int _wordCount(String value) {
    return value.trim().isEmpty ? 0 : value.trim().split(RegExp(r'\s+')).length;
  }
}
