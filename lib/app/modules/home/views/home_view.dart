import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/core/widgets/custom_text_button.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const String _dummyImage = 'assets/images/bg-image.png';
  static const String _dummyAvatar = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      floatingActionButton: _floatingActionButton(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerSection(size),
              AppDimensions.spacingXLarge.sh,
              _searchSection(size),
              AppDimensions.spacing2XLarge.sh,
              _galleryHeaderSection(),
              AppDimensions.spacingSemibold.sh,
              _catalogSection(size),
              AppDimensions.spacingXLarge.sh,
              _aiAssistantSection(size),
              AppDimensions.spacing2XLarge.sh,
              _architectHeaderSection(),
              AppDimensions.spacingLarge.sh,
              _architectSection(size),
              AppDimensions.spacingSemibold.sh,
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerSection(Size size) {
    return Row(
      children: [
        SizedBox(width: size.width * 0.12),
        Expanded(
          child: Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Halo',
                    style: AppTypography.headingMedium.copyWith(
                      color: AppColors.textHeadingColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'Sitek',
                    style: AppTypography.headingMedium.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _floatingActionButton() {
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton(
            onPressed: controller.openChatListFromHome,
            backgroundColor: AppColors.primaryColor,
            elevation: 4,
            child: const Icon(
              Icons.chat_bubble_rounded,
              color: AppColors.whiteColor,
            ),
          ),

          if (controller.totalUnread.value > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    controller.totalUnread.value > 99
                        ? '15+'
                        : '${controller.totalUnread.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
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
                hintText: 'Search Design or Architects',
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

  Widget _galleryHeaderSection() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Design Gallery',
            style: AppTypography.headingSmall.copyWith(
              color: AppColors.textHeadingColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        CustomTextButton(
          text: 'See all',
          onPressed: () => controller.openDesignFromHome(),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : AppDimensions.spacingXLarge,
                  ),
                  child: _catalogItem(
                    size: size,
                    catalog: catalogs[index],
                    onTap:
                        hasData
                            ? () => controller.openDetailsFromHome(
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
              padding: const EdgeInsets.only(top: AppDimensions.spacingXLarge),
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
          borderRadius: BorderRadius.circular(AppDimensions.radius2XLarge),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSoftColor,
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
                    top: Radius.circular(AppDimensions.radius3XLarge),
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
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingTiny,
                          ),
                          width:
                              isActive
                                  ? AppDimensions.spacingMedium
                                  : AppDimensions.spacingSmall,
                          height:
                              isActive
                                  ? AppDimensions.spacingMedium
                                  : AppDimensions.spacingSmall,
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
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSmall,
                          ),
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
                  AppDimensions.spacingMedium.sh,
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

  Widget _aiAssistantSection(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.018,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(AppDimensions.radius2XLarge),
      ),
      child: Row(
        children: [
          Container(
            width: size.width * 0.12,
            height: size.width * 0.12,
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              color: AppColors.whiteColor,
              size: size.width * 0.058,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Architecture\nAssistant',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                  ),
                ),
                AppDimensions.spacingXSmall.sh,
                Text(
                  'Describe your dream home and let AI\n'
                  'generate a concept for you.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.whiteColor.withValues(alpha: 0.88),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.whiteColor,
              foregroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.045,
                vertical: size.height * 0.012,
              ),
            ),
            child: Text(
              'Chat Now',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _architectHeaderSection() {
    return Text(
      'Top Architects',
      style: AppTypography.headingSmall.copyWith(
        color: AppColors.textHeadingColor,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _architectSection(Size size) {
    return Obx(() {
      final isLoading = controller.isLoadingArchitect.value;
      final hasError = controller.architectError.value.isNotEmpty;
      final hasData = controller.architects.isNotEmpty;

      if (hasError && !hasData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.architectError.value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.errorColor,
              ),
            ),
            TextButton(
              onPressed: controller.fetchArchitects,
              child: const Text('Coba Lagi'),
            ),
          ],
        );
      }

      final sourceArchitects =
          hasData ? controller.architects.take(3).toList() : <Architect>[];

      final architects = List<Architect>.generate(
        3,
        (index) =>
            index < sourceArchitects.length
                ? sourceArchitects[index]
                : Architect.dummy(),
      );

      return Skeletonizer(
        enabled: isLoading && !hasData,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...List.generate(3, (index) {
              final a = architects[index];
              return _architectItem(
                size: size,
                name: a.name,
                avatarUrl: a.profilePicture,
                onTap: () {
                  if (isLoading && !hasData) return;
                },
              );
            }),
            _architectItem(
              size: size,
              name: 'More',
              isMore: true,
              onTap: () => controller.openPortofolioFromHome(),
            ),
          ],
        ),
      );
    });
  }

  Widget _architectItem({
    required Size size,
    required String name,
    String? avatarUrl,
    bool isMore = false,
    VoidCallback? onTap,
  }) {
    final imageSize = size.width * 0.116;

    return SizedBox(
      width: size.width * 0.19,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
            onTap: onTap,
            child: CircleAvatar(
              radius: size.width * 0.058,
              backgroundColor:
                  isMore
                      ? AppColors.secondaryColor.withValues(alpha: 0.22)
                      : AppColors.whiteColor,
              child: ClipOval(
                child:
                    isMore
                        ? Icon(
                          Icons.add,
                          color: AppColors.primaryColor,
                          size: size.width * 0.055,
                        )
                        : (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? Image.network(
                          avatarUrl,
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Image.asset(
                                _dummyAvatar,
                                width: imageSize,
                                height: imageSize,
                                fit: BoxFit.cover,
                              ),
                        )
                        : Image.asset(
                          _dummyAvatar,
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                        ),
              ),
            ),
          ),
          AppDimensions.spacingSmall.sh,
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color:
                  isMore ? AppColors.textBodyColor : AppColors.textHeadingColor,
            ),
          ),
        ],
      ),
    );
  }
}
