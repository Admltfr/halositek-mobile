import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controllers/design_controller.dart';

class DesignView extends GetView<DesignController> {
  const DesignView({super.key});

  static const String _dummyImage = 'assets/images/bg-image.png';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchCatalogs(reset: true),
          child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.01),
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBarSection(),
                  AppDimensions.spacing2XLarge.sh,
                  _searchSection(size),
                  _styleFilterPanel(size),
                  _architectInfo(size),
                  AppDimensions.spacing2XLarge.sh,
                  controller.isArchitect.value ? _listHeader() : const SizedBox.shrink(),
                  AppDimensions.spacingLarge.sh,
                  _catalogSection(size),
                  AppDimensions.spacingSemibold.sh,
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _topBarSection() {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          InkWell(
            onTap: controller.goBack,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.arrow_back_ios_new_rounded, size: 15)),
          ),
          Expanded(
            child: Text(
              'Design Gallery',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _searchSection(Size size) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: size.height * 0.062,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.20)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.primaryColor, size: size.width * 0.055),
                SizedBox(width: size.width * 0.025),
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Search Design',
                      hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.55)),
                    ),
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textHeadingColor),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: size.width * 0.035),
        Obx(
          () => SizedBox(
            height: size.height * 0.062,
            child: ElevatedButton(
              onPressed: controller.toggleStyleFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.textWhiteColor,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.selectedStyleLabel,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textWhiteColor, fontWeight: FontWeight.w700),
                  ),
                  6.0.sw,
                  const Icon(Icons.filter_list_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _styleFilterPanel(Size size) {
    return Obx(() {
      if (!controller.isStyleFilterOpen.value) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(top: size.height * 0.014),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.20)),
            boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: Column(
            children:
                DesignController.styleFilters.map((style) {
                  final selected = controller.selectedStyle.value == style;
                  final label = style == 'all' ? 'All Design' : '${style[0].toUpperCase()}${style.substring(1)}';
                  return InkWell(
                    onTap: () => controller.changeStyle(style),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: selected ? AppColors.secondaryColor.withValues(alpha: 0.16) : Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: AppTypography.bodySmall.copyWith(
                                color: selected ? AppColors.primaryColor : AppColors.textHeadingColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primaryColor, size: 16),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      );
    });
  }

  Widget _architectInfo(Size size) {
    return Obx(() {
      if (!controller.isArchitect.value) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(top: size.height * 0.03),
        child: Row(
          children: [
            Container(
              width: size.width * 0.29,
              padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.12)),
                boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.designCount.toString(),
                    style: AppTypography.headingMedium.copyWith(color: AppColors.primaryColor, fontSize: 20),
                  ),
                  3.0.sh,
                  Text(
                    'DESIGN',
                    style: AppTypography.captionLarge.copyWith(color: AppColors.textBodyColor, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            10.0.sw,
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.openUploadDesign,
                icon: const Icon(Icons.add_circle_rounded, size: 21),
                label: Text(
                  'UPLOAD NEW DESIGN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textWhiteColor, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingLarge,
                    horizontal: AppDimensions.spacingMedium,
                  ),
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textWhiteColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _listHeader() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Text(
              controller.isArchitect.value ? 'Your Design' : 'Design Gallery',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
            ),
          ),
          if (controller.isArchitect.value) _statusFilter(),
        ],
      ),
    );
  }

  Widget _statusFilter() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.22)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedStatus.value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primaryColor),
          style: AppTypography.captionLarge.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w800),
          items: const [
            DropdownMenuItem(value: 'approved', child: Text('APPROVED')),
            DropdownMenuItem(value: 'rejected', child: Text('REJECTED')),
            DropdownMenuItem(value: 'pending', child: Text('PENDING')),
          ],
          onChanged: (value) {
            if (value != null) controller.changeStatus(value);
          },
        ),
      ),
    );
  }

  Widget _catalogSection(Size size) {
    return Obx(() {
      final isLoading = controller.isLoadingCatalog.value;
      final isLoadingMore = controller.isLoadingMore.value;
      final hasError = controller.catalogError.value.isNotEmpty;
      final hasData = controller.catalogs.isNotEmpty;

      if (hasError && !hasData) {
        return Column(
          children: [
            Text(controller.catalogError.value, style: AppTypography.bodySmall.copyWith(color: AppColors.errorColor)),
            TextButton(onPressed: () => controller.fetchCatalogs(reset: true), child: const Text('Coba Lagi')),
          ],
        );
      }

      final catalogs = hasData ? controller.catalogs : List.generate(3, (_) => Catalog.dummy());

      if (!isLoading && !hasData) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.24)),
          ),
          child: Column(
            children: [
              const Icon(Icons.inbox_rounded, size: 42, color: AppColors.textBodyColor),
              10.0.sh,
              Text(
                'Belum ada design tersedia.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeletonizer(
            enabled: isLoading && !hasData,
            child: Column(
              children: List.generate(catalogs.length, (index) {
                final isLast = index == catalogs.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.spacingXLarge),
                  child: _catalogItem(
                    size: size,
                    catalog: catalogs[index],
                    onTap: hasData ? () => controller.openDetailsFromDesign(catalogs[index].id) : null,
                  ),
                );
              }),
            ),
          ),
          if (isLoadingMore)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacingXLarge),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primaryColor),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _catalogItem({required Size size, required Catalog catalog, VoidCallback? onTap}) {
    final String label = catalog.style.toUpperCase();
    final String specs = '${catalog.area.toStringAsFixed(catalog.area % 1 == 0 ? 0 : 1)}m² • ${catalog.estimatedCost}';
    final String title = catalog.name;
    final String likesCount = catalog.likesCount.toString();
    final images = catalog.imageUrls.isNotEmpty ? catalog.imageUrls : catalog.images;
    final activeIndex = controller.getImageIndex(catalog.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(AppDimensions.radius2XLarge),
          boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radius3XLarge)),
                  child: AspectRatio(
                    aspectRatio: 1.50,
                    child:
                        images.isNotEmpty
                            ? PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (index) {
                                controller.setImageIndex(catalog.id, index);
                              },
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
                ),
                Obx(
                  () =>
                      controller.isArchitect.value && catalog.id.isNotEmpty
                          ? Positioned(
                            top: size.width * 0.025,
                            right: size.width * 0.025,
                            child: GestureDetector(
                              onTap: () => controller.openEditDesign(catalog.id),
                              child: Container(
                                width: size.width * 0.085,
                                height: size.width * 0.085,
                                decoration: const BoxDecoration(color: AppColors.whiteColor, shape: BoxShape.circle),
                                child: Icon(Icons.edit_rounded, size: size.width * 0.045, color: AppColors.primaryColor),
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
                Positioned(
                  bottom: size.width * 0.03,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.isEmpty ? 1 : images.length, (index) {
                      final isActive = index == activeIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingTiny),
                        width: isActive ? AppDimensions.spacingMedium : AppDimensions.spacingSmall,
                        height: isActive ? AppDimensions.spacingMedium : AppDimensions.spacingSmall,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryColor : AppColors.whiteColor,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(size.width * 0.03, size.height * 0.010, size.width * 0.03, size.height * 0.012),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.018, vertical: size.height * 0.0035),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: Text(
                          label,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: AppTypography.caption.fontSize,
                          ),
                        ),
                      ),
                      8.0.sw,
                      Text(
                        specs,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textBodyColor,
                          fontSize: AppTypography.captionLarge.fontSize,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => controller.isArchitect.value ? null : controller.toggleCatalogLike(catalog.id),
                        child: Icon(
                          catalog.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: catalog.liked ? AppColors.errorColor : AppColors.formBorderColor,
                          size: AppDimensions.iconSizeLarge,
                        ),
                      ),
                    ],
                  ),
                  8.0.sh,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textHeadingColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        likesCount,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.75)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
