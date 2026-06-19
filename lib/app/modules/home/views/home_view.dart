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
        child: Obx(() {
          final isArchitect = controller.isArchitect.value;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerSection(size),
                AppDimensions.spacingXLarge.sh,
                _searchSection(size, hintText: 'Search Design or Architects'),
                AppDimensions.spacing2XLarge.sh,
                if (isArchitect) ...[
                  Obx(() {
                    if (controller.isSearchMode) {
                      return _searchResultSection(size);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _performanceHeaderSection(),
                        AppDimensions.spacingSemibold.sh,
                        _performanceSection(size),
                        AppDimensions.spacingXLarge.sh,
                        _activeProjectsHeaderSection(),
                        AppDimensions.spacingSemibold.sh,
                        _activeProjectSection(size),
                      ],
                    );
                  }),
                ] else ...[
                  Obx(() {
                    final isSearchMode = controller.isSearchMode;

                    if (isSearchMode) {
                      return _searchResultSection(size);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _galleryHeaderSection(),
                        AppDimensions.spacingSemibold.sh,
                        _catalogSection(size),
                        AppDimensions.spacingXLarge.sh,
                        _aiAssistantSection(size),
                        AppDimensions.spacing2XLarge.sh,
                        _architectHeaderSection(),
                        AppDimensions.spacingLarge.sh,
                        _architectSection(size),
                      ],
                    );
                  }),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _headerSection(Size size) {
    return Row(
      children: [
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
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (controller.isArchitect.value == false) ...[
            FloatingActionButton(
              heroTag: 'ai_chat_fab',
              onPressed: controller.openAiChatFromHome,
              backgroundColor: AppColors.primaryColor,
              elevation: 4,
              child: ImageIcon(
                AssetImage('assets/icons/ai-bot.png'),
                size: 24,
                color: AppColors.whiteColor,
              ),
            ),
            const SizedBox(height: 12),
          ],

          Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                heroTag: 'chat_fab',
                onPressed: controller.openChatListFromHome,
                backgroundColor: AppColors.primaryColor,
                elevation: 4,
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: AppColors.whiteColor,
                ),
              ),

              // if (controller.totalUnread.value > 0)
              //   Positioned(
              //     right: -3,
              //     top: -3,
              //     child: Container(
              //       padding: const EdgeInsets.all(5),
              //       constraints: const BoxConstraints(
              //         minWidth: 20,
              //         minHeight: 20,
              //       ),
              //       decoration: const BoxDecoration(
              //         color: Colors.red,
              //         shape: BoxShape.circle,
              //       ),
              //       child: Center(
              //         child: Text(
              //           controller.totalUnread.value > 99
              //               ? '15+'
              //               : '${controller.totalUnread.value}',
              //           style: const TextStyle(
              //             color: Colors.white,
              //             fontSize: 10,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ],
      );
    });
  }

  Widget _searchSection(Size size, {required String hintText}) {
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
              controller: controller.searchController,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textBodyColor.withValues(alpha: 0.55),
                ),
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHeadingColor,
              ),
            ),
          ),

          Obx(() {
            if (controller.searchQuery.value.trim().isEmpty) {
              return const SizedBox.shrink();
            }

            return GestureDetector(
              onTap: () {
                controller.searchController.clear();

                controller.searchQuery.value = '';

                controller.searchedArchitects.clear();
                controller.searchedCatalogs.clear();
              },
              child: Icon(
                Icons.close_rounded,
                color: AppColors.textBodyColor,
                size: size.width * 0.05,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _searchResultSection(Size size) {
    return Obx(() {
      if (!controller.isSearchMode) {
        return const SizedBox.shrink();
      }

      if (controller.isSearching.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.searchedArchitects.isEmpty &&
          controller.searchedCatalogs.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text('No result found', style: AppTypography.bodyMedium),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.searchedArchitects.isNotEmpty &&
              !controller.isArchitect.value) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Architects',
                    style: AppTypography.headingSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                CustomTextButton(
                  text: 'See all',
                  onPressed: () => controller.openArchitectFromHome(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            12.0.sh,

            ...controller.searchedArchitects.map(
              (architect) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _architectCard(size: size, architect: architect),
              ),
            ),

            20.0.sh,
          ],

          if (controller.searchedCatalogs.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Designs',
                    style: AppTypography.headingSmall.copyWith(
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
            ),

            12.0.sh,

            ...controller.searchedCatalogs.map(
              (catalog) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _catalogItem(
                  size: size,
                  catalog: catalog,
                  onTap: () => controller.openDetailsFromHome(catalog.id),
                ),
              ),
            ),

            20.0.sh,
          ],
        ],
      );
    });
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

  Widget _catalogSection(
    Size size, {
    String emptyMessage = 'Belum ada katalog',
  }) {
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

      // final catalogs = hasData ? controller.catalogs.take(3).toList() : List.generate(3, (_) => Catalog.dummy());
      final catalogs = controller.catalogs.take(3).toList();

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
                    // onTap: hasData ? () => controller.openDetailsFromHome(catalogs[index].id) : null,
                    onTap:
                        () =>
                            controller.openDetailsFromHome(catalogs[index].id),
                  ),
                );
              }),
            ),
          ),

          if (!isLoading && !hasData)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacingXLarge),
              child: Text(
                emptyMessage,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textBodyColor,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _performanceHeaderSection() {
    return Text(
      'Performance',
      style: AppTypography.headingSmall.copyWith(
        color: AppColors.textHeadingColor,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _performanceSection(Size size) {
    return Obx(() {
      final isLoading = controller.isLoadingPerformance.value;
      final hasError = controller.performanceError.value.isNotEmpty;

      if (hasError) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.performanceError.value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.errorColor,
              ),
            ),
            // TextButton(
            //   onPressed: controller.fetchArchitectPerformance,
            //   child: const Text('Coba Lagi'),
            // ),
          ],
        );
      }

      return Skeletonizer(
        enabled: isLoading,
        child: Row(
          children: [
            Expanded(
              child: _performanceCard(
                size: size,
                icon: Icons.favorite_rounded,
                label: 'LIKES',
                // value: "100",
                value: controller.totalLikes.value.toString(),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: _performanceCard(
                size: size,
                icon: Icons.bookmark_rounded,
                label: 'SAVES',
                // value: "100",
                value: controller.totalSaved.value.toString(),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: _performanceCard(
                size: size,
                icon: Icons.calendar_month_rounded,
                label: 'CONSULTS',
                // value: "100",
                value: controller.totalConsult.value.toString(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _performanceCard({
    required Size size,
    required IconData icon,
    required String label,
    required String value,
    String? badgeText,
  }) {
    final double cardRadius = AppDimensions.radiusXLarge;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.02,
            vertical: size.height * 0.02,
          ),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSoftColor,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF7F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFC77A33), size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF8A9A9E),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTypography.headingSmall.copyWith(
                  color: AppColors.textHeadingColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        if (badgeText != null)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF52B788),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(cardRadius),
                  bottomLeft: const Radius.circular(8),
                ),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _activeProjectsHeaderSection() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Active Projects',
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

  Widget _activeProjectSection(Size size) {
    return _catalogSection(size, emptyMessage: 'Belum ada project');
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
    final images = catalog.images;
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
                Obx(
                  () =>
                      controller.isArchitect.value &&
                              catalog.architectId ==
                                  controller.currentArchitectId.value
                          ? Positioned(
                            top: size.width * 0.025,
                            right: size.width * 0.025,
                            child: GestureDetector(
                              onTap: () => controller.openEditDesign(catalog),
                              child: Container(
                                width: size.width * 0.085,
                                height: size.width * 0.085,
                                decoration: const BoxDecoration(
                                  color: AppColors.whiteColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: size.width * 0.045,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
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
                                Expanded(
                                  child: Text(
                                    specs,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textBodyColor,
                                      fontSize:
                                          AppTypography.captionLarge.fontSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            8.0.sh,

                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textHeadingColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      8.0.sw,

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap:
                                controller.isArchitect.value
                                    ? null
                                    : () => controller.toggleCatalogLike(
                                      catalog.id,
                                    ),
                            child: Icon(
                              catalog.liked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color:
                                  catalog.liked
                                      ? AppColors.errorColor
                                      : AppColors.formBorderColor,
                              size: AppDimensions.iconSizeLarge,
                            ),
                          ),

                          2.0.sh,

                          Text(
                            likesCount,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textBodyColor.withValues(
                                alpha: 0.75,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
    return Skeletonizer(
      enabled: controller.isLoadingArchitect.value,
      child: Container(
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
              onPressed: controller.openAiChatFromHome,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.whiteColor,
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
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

      final architects = controller.architects.take(3).toList();
      final showMore = controller.architects.length > 3;

      return Skeletonizer(
        enabled: isLoading && !hasData,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...architects.map(
              (a) => _architectItem(
                size: size,
                name: a.name,
                avatarUrl: a.profilePicture,
                onTap: () => controller.openArchitectPortofolio(a),
              ),
            ),

            if (showMore)
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

  Widget _architectCard({required Size size, required Architect architect}) {
    final projectsCount = controller.projectCompletedCount(architect);
    final isPlaceholder = architect.id.isEmpty;
    final catalogs = controller.catalogsByArchitect(architect.id);

    return GestureDetector(
      onTap:
          isPlaceholder
              ? null
              : () => controller.openArchitectPortofolio(architect),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(size.width * 0.03),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: AppColors.formBorderColor.withValues(alpha: 0.25),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSoftColor,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: size.width * 0.078,
                  backgroundColor: AppColors.whiteColor,
                  child: ClipOval(
                    child:
                        architect.profilePicture.isNotEmpty
                            ? Image.network(
                              architect.profilePicture,
                              width: size.width * 0.156,
                              height: size.width * 0.156,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Image.asset(
                                    _dummyAvatar,
                                    width: size.width * 0.156,
                                    height: size.width * 0.156,
                                    fit: BoxFit.cover,
                                  ),
                            )
                            : Image.asset(
                              _dummyAvatar,
                              width: size.width * 0.156,
                              height: size.width * 0.156,
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
                AppDimensions.spacingSemibold.sw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        architect.name.isNotEmpty ? architect.name : '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textHeadingColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      2.0.sh,
                      Text(
                        architect.specialization.isNotEmpty
                            ? architect.specialization
                            : (architect.headline.isNotEmpty
                                ? architect.headline
                                : 'Architect'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textBodyColor,
                        ),
                      ),
                      2.0.sh,
                      Text(
                        '$projectsCount Projects completed',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textBodyColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            14.0.sh,
            _projectPreview(size, catalogs),
          ],
        ),
      ),
    );
  }

  Widget _projectPreview(Size size, List<Catalog> catalogs) {
    final count = catalogs.length;

    if (count == 0) {
      return const SizedBox.shrink();
    }

    final visibleCount = count > 3 ? 2 : count;
    final hiddenCount = count > 3 ? count - 2 : 0;

    return Row(
      children: [
        ...List.generate(visibleCount, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < visibleCount - 1 || hiddenCount > 0 ? 6 : 0,
              ),
              child: _projectThumb(size, _projectImage(catalogs[index])),
            ),
          );
        }),

        if (hiddenCount > 0)
          Expanded(child: _moreThumb(size: size, label: '+$hiddenCount')),
      ],
    );
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

  String _projectImage(Catalog catalog) {
    if (catalog.images.isNotEmpty) {
      return catalog.images.first;
    }

    return _dummyImage;
  }

  Widget _projectThumb(Size size, String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: AspectRatio(
        aspectRatio: 1.25,
        child:
            imagePath.startsWith('http') || imagePath.startsWith('https')
                ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) =>
                          Image.asset(_dummyImage, fit: BoxFit.cover),
                )
                : Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }

  Widget _moreThumb({required Size size, required String label}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: AspectRatio(
        aspectRatio: 1.25,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(_dummyImage, fit: BoxFit.cover),
            Container(color: AppColors.accentColor.withValues(alpha: 0.30)),
            Center(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textWhiteColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
