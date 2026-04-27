import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBarSection(size),
              14.0.sh,
              _searchSection(size),
              14.0.sh,
              _catalogSection(size),
              10.0.sh,
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBarSection(Size size) {
    return SizedBox(
      height: size.height * 0.03,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Design Gallery',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHeadingColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.05),
        ],
      ),
    );
  }

  Widget _searchSection(Size size) {
    return Container(
      height: size.height * 0.062,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.formBorderColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppColors.primaryColor,
            size: size.width * 0.055,
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search Architects',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textBodyColor.withValues(alpha: 0.55),
                ),
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHeadingColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _catalogSection(Size size) {
    return Obx(() {
      final isLoading = controller.isLoadingCatalog.value;
      final hasError = controller.catalogError.value.isNotEmpty;
      final hasData = controller.catalogs.isNotEmpty;

      if (hasError && !hasData) {
        return Column(
          children: [
            Text(
              controller.catalogError.value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.errorColor,
              ),
            ),
            TextButton(
              onPressed: controller.fetchCatalogs,
              child: const Text('Coba Lagi'),
            ),
          ],
        );
      }

      final catalogs =
          hasData
              ? controller.catalogs.take(3).toList()
              : List.generate(3, (_) => Catalog.dummy());

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeletonizer(
            enabled: isLoading,
            child: Column(
              children: List.generate(catalogs.length, (index) {
                final isLast = index == catalogs.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 15),
                  child: _catalogItem(
                    size: size,
                    catalog: catalogs[index],
                    onTap:
                        hasData
                            ? () => controller.openDetailsFromDesign(
                              catalogs[index].id,
                            )
                            : null,
                  ),
                );
              }),
            ),
          ),

          if (!isLoading && !hasData)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'Belum ada katalog',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textBodyColor,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _catalogItem({
    required Size size,
    required Catalog catalog,
    VoidCallback? onTap,
  }) {
    final String label = catalog.style.toUpperCase();
    final String specs =
        '${catalog.area.toStringAsFixed(catalog.area % 1 == 0 ? 0 : 1)}m² • ${catalog.estimatedCost}';
    final String title = catalog.name;
    final String likesCount = catalog.likesCount.toString();
    final images =
        catalog.imageUrls.isNotEmpty ? catalog.imageUrls : catalog.images;
    final activeIndex = controller.getImageIndex(catalog.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
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
                                  errorBuilder:
                                      (_, __, ___) => Image.asset(
                                        _dummyImage,
                                        fit: BoxFit.cover,
                                      ),
                                );
                              },
                            )
                            : Image.asset(_dummyImage, fit: BoxFit.cover),
                  ),
                ),
                // Positioned(
                //   top: size.width * 0.02,
                //   right: size.width * 0.02,
                //   child: Container(
                //     width: size.width * 0.085,
                //     height: size.width * 0.085,
                //     decoration: const BoxDecoration(
                //       color: AppColors.whiteColor,
                //       shape: BoxShape.circle,
                //     ),
                //     child: Icon(
                //       Icons.bookmark_border_rounded,
                //       size: size.width * 0.05,
                //       color: AppColors.accentColor,
                //     ),
                //   ),
                // ),
                Positioned(
                  bottom: size.width * 0.03,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.isEmpty ? 1 : images.length,
                      (index) {
                        final isActive = index == activeIndex;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 8 : 6,
                          height: isActive ? 8 : 6,
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? AppColors.primaryColor
                                    : AppColors.whiteColor,
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                size.width * 0.03,
                size.height * 0.010,
                size.width * 0.03,
                size.height * 0.012,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.018,
                          vertical: size.height * 0.0035,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor.withValues(
                            alpha: 0.18,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          label,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      8.0.sw,
                      Text(
                        specs,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textBodyColor,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => controller.toggleCatalogLike(catalog.id),
                        child: Icon(
                          catalog.liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color:
                              catalog.liked
                                  ? AppColors.errorColor
                                  : AppColors.formBorderColor,
                          size: 19,
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
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textBodyColor.withValues(
                            alpha: 0.75,
                          ),
                        ),
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
