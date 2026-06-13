import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';

class DesignForm extends StatelessWidget {
  const DesignForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.estimatedCostController,
    required this.areaController,
    required this.highlightFeaturesController,
    required this.selectedStyle,
    required this.styles,
    required this.mediaFiles,
    required this.layoutFiles,
    required this.onStyleChanged,
    required this.onPickMedia,
    required this.onPickLayout,
    required this.onRemoveMedia,
    required this.onRemoveLayout,
    required this.onCancel,
    required this.onSubmit,
    required this.isSubmitting,
    required this.submitLabel,
    required this.cancelLabel,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController estimatedCostController;
  final TextEditingController areaController;
  final TextEditingController highlightFeaturesController;
  final String selectedStyle;
  final List<String> styles;
  final List<PlatformFile> mediaFiles;
  final List<PlatformFile> layoutFiles;
  final ValueChanged<String?> onStyleChanged;
  final VoidCallback onPickMedia;
  final VoidCallback onPickLayout;
  final ValueChanged<PlatformFile> onRemoveMedia;
  final ValueChanged<PlatformFile> onRemoveLayout;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final String submitLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.image_outlined, 'MEDIA DESIGN'),
        18.0.sh,
        _uploadBox(files: mediaFiles, onPick: onPickMedia, onRemove: onRemoveMedia),
        24.0.sh,
        _sectionTitle(Icons.image_outlined, 'LAYOUT DESIGN'),
        18.0.sh,
        _uploadBox(files: layoutFiles, onPick: onPickLayout, onRemove: onRemoveLayout),
        24.0.sh,
        _sectionTitle(Icons.format_list_bulleted_rounded, 'DESIGN INFORMATIONS'),
        18.0.sh,
        _field(label: 'DESIGN TITLE', controller: nameController, hint: 'e.g, Modern Glass House', maxLines: 3),
        18.0.sh,
        _field(label: 'DESCRIPTIONS', controller: descriptionController, hint: 'Describe the architectural..', maxLines: 3),
        24.0.sh,
        _sectionTitle(Icons.straighten_rounded, 'SPECIFICATIONS'),
        18.0.sh,
        Row(
          children: [
            Expanded(child: _styleField()),
            12.0.sw,
            Expanded(
              child: _field(
                label: 'AREA ( M²)',
                controller: areaController,
                hint: '450',
                keyboardType: TextInputType.number,
                compact: true,
              ),
            ),
          ],
        ),
        12.0.sh,
        Row(
          children: [
            Expanded(
              child: _field(label: 'HIGHLIGHT FEATURES', controller: highlightFeaturesController, hint: '2', compact: true),
            ),
            12.0.sw,
            Expanded(
              child: _field(
                label: 'ESTIMATED COST (RP)',
                controller: estimatedCostController,
                hint: '800',
                keyboardType: TextInputType.number,
                compact: true,
              ),
            ),
          ],
        ),
        40.0.sh,
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
                child: Text(cancelLabel, style: AppTypography.bodySmall.copyWith(color: AppColors.errorColor)),
              ),
            ),
            12.0.sw,
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                icon:
                    isSubmitting
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline_rounded, size: 16),
                label: Text(submitLabel, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
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
        44.0.sh,
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        6.0.sw,
        Text(
          title,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }

  Widget _uploadBox({
    required List<PlatformFile> files,
    required VoidCallback onPick,
    required ValueChanged<PlatformFile> onRemove,
  }) {
    return InkWell(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        height: 264,
        color: AppColors.formBorderColor.withValues(alpha: 0.24),
        padding: const EdgeInsets.all(14),
        child:
            files.isEmpty
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 28, color: AppColors.textBodyColor),
                    Text(
                      'ADD',
                      style: AppTypography.caption.copyWith(color: AppColors.textBodyColor, fontWeight: FontWeight.w800),
                    ),
                  ],
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: files.length > 4 ? 4 : files.length,
                        separatorBuilder: (_, __) => 8.0.sh,
                        itemBuilder: (_, index) => _fileChip(files[index], onRemove),
                      ),
                    ),
                    Center(
                      child: Text(
                        '+ ADD MORE',
                        style: AppTypography.caption.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _fileChip(PlatformFile file, ValueChanged<PlatformFile> onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
      child: Row(
        children: [
          const Icon(Icons.image_outlined, size: 18, color: AppColors.primaryColor),
          8.0.sw,
          Expanded(
            child: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.captionLarge.copyWith(color: AppColors.textHeadingColor),
            ),
          ),
          InkWell(
            onTap: () => onRemove(file),
            child: const Icon(Icons.close_rounded, size: 18, color: AppColors.errorColor),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool compact = false,
  }) {
    return Container(
      padding: compact ? EdgeInsets.all(16) : null,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: compact ? Border.all(color: AppColors.primaryColor.withValues(alpha: 0.08)) : null,
        boxShadow: compact ? const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 8, offset: Offset(0, 4))] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          8.0.sh,
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: _inputDecoration(hint),
            style: AppTypography.bodySmall.copyWith(color: AppColors.textHeadingColor),
          ),
        ],
      ),
    );
  }

  Widget _styleField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.08)),
        boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('ARCHITECTURAL STYLE'),
          8.0.sh,
          DropdownButtonFormField<String>(
            value: selectedStyle,
            items: styles.map((style) => DropdownMenuItem(value: style, child: Text(_labelForStyle(style)))).toList(),
            onChanged: onStyleChanged,
            decoration: _inputDecoration('Style'),
            style: AppTypography.bodySmall.copyWith(color: AppColors.textHeadingColor),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHeadingColor),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: AppTypography.captionLarge.copyWith(color: AppColors.textBodyColor, fontWeight: FontWeight.w800),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.50)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        borderSide: BorderSide(color: AppColors.textBodyColor.withValues(alpha: 0.55)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
    );
  }

  String _labelForStyle(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
