import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/modules/profile/widgets/profile_formatters.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/detail_controller.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  static const String _dummyImage = 'assets/images/bg-image.png';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          final hasError = controller.errorMessage.value.isNotEmpty;
          final hasData = controller.catalog.value != null;

          if (hasError && !hasData) {
            return Column(
              children: [
                Text('Detail gagal dimuat', style: AppTypography.bodySmall.copyWith(color: AppColors.errorColor)),
                TextButton(onPressed: controller.fetchCatalogDetail, child: const Text('Coba Lagi')),
              ],
            );
          }

          final project = controller.catalog.value ?? Catalog.dummy();

          return Skeletonizer(
            enabled: isLoading,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  8.0.sh,
                  Padding(padding: EdgeInsets.symmetric(horizontal: size.width * 0.05), child: _topBar(size)),
                  8.0.sh,
                  _heroImage(size),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.0.sh,
                        _mainInfo(size, project),

                        if (!controller.isArchitectRole.value) ...[
                          Divider(color: AppColors.formBorderColor.withValues(alpha: 0.25)),
                          12.0.sh,
                          _architectChatRow(size),
                          16.0.sh,
                        ],

                        _priceSection(size),
                        AppDimensions.spacingXLarge.sh,
                        _descriptionSection(project),
                        AppDimensions.spacingXLarge.sh,
                        _layoutSection(size),
                        AppDimensions.spacing4XLarge.sh,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _topBar(size) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          InkWell(
            onTap: controller.goBack,
            child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.arrow_back_ios_new_rounded, size: 15)),
          ),
          Expanded(
            child: Text(
              'Details',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _heroImage(Size size) {
    final images = controller.projectImages;
    final active = controller.activeImageIndex.value;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: size.height * 0.475,
          child:
              images.isNotEmpty
                  ? PageView.builder(
                    itemCount: images.length,
                    onPageChanged: controller.setActiveImageIndex,
                    itemBuilder: (_, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(_dummyImage, fit: BoxFit.cover),
                      );
                    },
                  )
                  : Image.asset(_dummyImage, fit: BoxFit.cover),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isActive = index == active;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingTiny),
                  width: isActive ? AppDimensions.spacingMedium : AppDimensions.spacingSmall,
                  height: isActive ? AppDimensions.spacingMedium : AppDimensions.spacingSmall,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primaryColor : AppColors.whiteColor,
                  ),
                );
              }),
            ),
          ),
        Obx(() {
          if (controller.isArchitectRole.value) return const SizedBox.shrink();

          final project = controller.catalog.value;
          final isSaved = project?.saved == true;
          final isSaving = controller.isSaving.value;

          return Positioned(
            right: size.width * 0.035,
            bottom: 12,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isSaving ? null : controller.toggleSave,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.whiteColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child:
                    isSaving
                        ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                        )
                        : Icon(
                          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isSaved ? AppColors.primaryColor : AppColors.textHeadingColor,
                          size: 23,
                        ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _mainInfo(Size size, Catalog p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingSmall, vertical: AppDimensions.spacingTiny),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
              ),
              child: Text(
                p.style.toUpperCase(),
                style: AppTypography.bodySmall.copyWith(
                  fontSize: AppTypography.captionSmall.fontSize,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            8.0.sw,
            Text(
              '${controller.areaDisplay}  •  4 Bedrooms',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textBodyColor,
                fontSize: AppTypography.caption.fontSize,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: controller.isArchitectRole.value ? null : controller.toggleLike,
              child: Icon(
                p.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: AppDimensions.iconSizeMedium,
                color: p.liked ? AppColors.errorColor : AppColors.textBodyColor,
              ),
            ),
          ],
        ),
        6.0.sh,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                p.name,
                style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textHeadingColor),
              ),
            ),
            12.0.sw,
            Text(
              p.likesCount.toString(),
              style: AppTypography.bodySmall.copyWith(
                fontSize: AppTypography.caption.fontSize,
                color: AppColors.textBodyColor.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
        18.0.sh,
      ],
    );
  }

  Widget _architectChatRow(Size size) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.formBorderColor.withValues(alpha: 0.2),
          backgroundImage: controller.architectPhoto.isNotEmpty ? NetworkImage(controller.architectPhoto) : null,
          child:
              controller.architectPhoto.isEmpty
                  ? Icon(Icons.person, size: size.width * 0.045, color: AppColors.accentColor)
                  : null,
        ),
        12.0.sw,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.architectName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w800),
              ),
              2.0.sh,
              Text(
                '${formatCurrency(controller.consultationFee)} / ${controller.consultationDuration} hours',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.successColor,
                  fontSize: AppTypography.caption.fontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        12.0.sw,
        Obx(
          () => InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            onTap: controller.isStartingChat.value ? null : controller.startConsultationChat,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  controller.isStartingChat.value
                      ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteColor),
                      )
                      : const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.whiteColor, size: 18),
                  8.0.sw,
                  Text(
                    controller.isStartingChat.value ? 'Loading...' : 'Chat Now',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.whiteColor, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceSection(Size size) {
    return Row(
      children: [
        Expanded(
          child: _priceBox(
            title: 'ESTIMATED COST',
            value: controller.estimatedCostDisplay,
            valueColor: AppColors.primaryColor,
          ),
        ),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: _priceBox(title: 'ESTIMATED AREA', value: controller.areaDisplay, valueColor: AppColors.textHeadingColor),
        ),
      ],
    );
  }

  Widget _priceBox({required String title, required String value, required Color valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLarge, vertical: AppDimensions.spacingLarge),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textBodyColor,
              fontSize: AppTypography.captionSmall.fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          4.0.sh,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTypography.bodyMedium.copyWith(color: valueColor, fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _descriptionSection(Catalog p) {
    final hasHighlight = p.highlightFeatures.trim().isNotEmpty;
    final desc = hasHighlight ? '${p.description}\n\nHighlight Features: ${p.highlightFeatures}' : p.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
        ),
        8.0.sh,
        Text(
          desc.trim().isEmpty ? '-' : desc,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor, height: 1.45),
        ),
      ],
    );
  }

  Widget _layoutSection(Size size) {
    final layouts = controller.projectLayoutImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layout',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
        ),
        8.0.sh,
        if (layouts.isEmpty)
          Container(
            width: double.infinity,
            height: size.height * 0.285,
            decoration: BoxDecoration(
              color: AppColors.subtleSurfaceColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.25)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.grid_4x4_rounded, color: AppColors.formBorderColor, size: size.width * 0.12),
          )
        else
          SizedBox(
            height: size.height * 0.285,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: layouts.length,
              separatorBuilder: (_, __) => SizedBox(width: AppDimensions.spacingSmall),
              itemBuilder: (_, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  child: Image.network(
                    layouts[index],
                    width: size.width * 0.86,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(_dummyImage, width: size.width * 0.7, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
