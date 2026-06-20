import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/core/widgets/custom_text_button.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/home_controller.dart';

class UserHomeView extends GetView<HomeController> {
  const UserHomeView({super.key});

  static const String _dummyImage = 'assets/images/bg-image.png';
  static const String _dummyAvatar = 'assets/images/logo.png';

  static const List<Map<String, String>> _styleFilters = [
    {'label': 'All', 'value': 'all'},
    {'label': 'Modern', 'value': 'modern'},
    {'label': 'Traditional', 'value': 'traditional'},
    {'label': 'Minimalist', 'value': 'minimalist'},
    {'label': 'Futuristik', 'value': 'futuristik'},
    {'label': 'Industrial', 'value': 'industrial'},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      floatingActionButton: _floatingActionButton(),
      body: SafeArea(
        child: Obx(() {
          final isSearchMode = controller.isSearchMode;

          return RefreshIndicator(
            onRefresh: controller.refreshDashboard,
            color: AppColors.primaryColor,
            backgroundColor: AppColors.whiteColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.01),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerSection(size),
                  AppDimensions.spacingXLarge.sh,
                  _searchSection(size, hintText: 'Search Design or Architects'),
                  if (isSearchMode) ...[
                    AppDimensions.spacing2XLarge.sh,
                    _searchResultSection(size),
                  ] else ...[
                    AppDimensions.spacing4XLarge.sh,
                    _greetingSection(size),
                    AppDimensions.spacing4XLarge.sh,
                    _summaryCardsSection(size),
                    AppDimensions.spacing4XLarge.sh,
                    _featuredSection(size),
                    AppDimensions.spacing4XLarge.sh,
                    _aiAssistantSection(size),
                    AppDimensions.spacing4XLarge.sh,
                    _recommendedSection(size),
                    32.0.sh,
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────

  Widget _headerSection(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  style: AppTypography.headingMedium.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Greeting ────────────────────────────────────────────────────────

  Widget _greetingSection(Size size) {
    return Obx(() {
      final profile = controller.userProfile.value;
      final isLoading = controller.isLoadingProfile.value;
      final name = profile?.name ?? '';
      final firstName = name.isNotEmpty ? name.split(' ').first : (isLoading ? 'User' : '');
      final baseUrl = ApiClient.baseUrl;
      final avatarUrl = profile?.photoProfileUrl != null ? "$baseUrl${profile?.photoProfileUrl}" : '';

      return Skeletonizer(
        enabled: isLoading,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstName.isNotEmpty ? 'Hello, $firstName!' : 'Helloe!',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textBodyColor),
                  ),
                  4.0.sh,
                  Text(
                    'Ready to design your\ndream home?',
                    style: AppTypography.headingSmall.copyWith(
                      color: AppColors.textHeadingColor,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            12.0.sw,
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child:
                    avatarUrl.isNotEmpty
                        ? Image.network(
                          avatarUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(_dummyAvatar, width: 64, height: 64, fit: BoxFit.cover),
                        )
                        : Image.asset(_dummyAvatar, width: 64, height: 64, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryCardsSection(Size size) {
    return Obx(() {
      final summary = controller.dashboardSummary.value;
      final isLoading = controller.isLoadingSummary.value;

      return Skeletonizer(
        enabled: isLoading,
        child: Row(
          children: [
            Expanded(
              child: _summaryCard(
                size: size,
                icon: Icons.bookmark,
                label: 'SAVED DESIGNS',
                value: '${summary?.totalSavedDesigns ?? 0}',
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: _summaryCard(
                size: size,
                icon: Icons.people,
                label: 'SAVED ARCHITECTS',
                value: '${summary?.totalSavedArchitects ?? 0}',
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: _summaryCard(
                size: size,
                icon: Icons.chat_bubble,
                label: 'CONSULTATIONS',
                value: '${summary?.totalConsultations ?? 0}',
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryCard({
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
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.02),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Color(0xFFFDF7F2), shape: BoxShape.circle),
                child: Icon(icon, color: const Color(0xFFC77A33), size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.captionLarge.copyWith(
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
                borderRadius: BorderRadius.only(topRight: Radius.circular(cardRadius), bottomLeft: const Radius.circular(8)),
              ),
              child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  // ─── Featured of the Week ────────────────────────────────────────────

  Widget _featuredSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured of the Week',
          style: AppTypography.headingSmall.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
        ),
        AppDimensions.spacingLarge.sh,
        _featuredCard(size),
        AppDimensions.spacingLarge.sh,
        _styleFilterChips(),
      ],
    );
  }

  Widget _featuredCard(Size size) {
    return Obx(() {
      final featured = controller.featuredDesign.value;
      final isLoading = controller.isLoadingFeatured.value;

      if (isLoading) {
        return Skeletonizer(
          enabled: true,
          child: Container(
            height: size.height * 0.24,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.subtleSurfaceColor,
              borderRadius: BorderRadius.circular(AppDimensions.radius2XLarge),
            ),
          ),
        );
      }

      if (featured == null) {
        return Container(
          height: size.height * 0.18,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.subtleSurfaceColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radius2XLarge),
          ),
          child: Center(
            child: Text(
              'No featured design this week',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textBodyColor),
            ),
          ),
        );
      }

      final image = featured.images.isNotEmpty ? featured.images.first : '';
      final style = featured.style.toUpperCase();

      return GestureDetector(
        onTap: () => controller.openDetailsFromHome(featured.id),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radius2XLarge),
            boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 12, offset: Offset(0, 6))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radius2XLarge),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.6,
                  child:
                      image.isNotEmpty
                          ? Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(_dummyImage, fit: BoxFit.cover),
                          )
                          : Image.asset(_dummyImage, fit: BoxFit.cover),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                        stops: const [0.35, 1.0],
                      ),
                    ),
                  ),
                ),
                // Style badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      style,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                // Bottom info
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        featured.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      6.0.sh,
                      Row(
                        children: [
                          Icon(Icons.square_foot_rounded, color: AppColors.whiteColor.withValues(alpha: 0.85), size: 14),
                          4.0.sw,
                          Text(
                            featured.areaRaw,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.whiteColor.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                          12.0.sw,
                          Icon(Icons.favorite_rounded, color: AppColors.whiteColor.withValues(alpha: 0.85), size: 14),
                          4.0.sw,
                          Text(
                            '${featured.likesCount}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.whiteColor.withValues(alpha: 0.85),
                              fontSize: 12,
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
        ),
      );
    });
  }

  Widget _styleFilterChips() {
    return Obx(() {
      final selected = controller.selectedFeaturedStyle.value;

      return SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: _styleFilters.length,
          separatorBuilder: (_, __) => 8.0.sw,
          itemBuilder: (_, index) {
            final filter = _styleFilters[index];
            final isActive = selected == filter['value'];

            return GestureDetector(
              onTap: () => controller.changeFeaturedStyle(filter['value']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryColor : AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primaryColor : AppColors.formBorderColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  filter['label']!,
                  style: AppTypography.bodySmall.copyWith(
                    color: isActive ? AppColors.whiteColor : AppColors.textBodyColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ─── AI Assistant ────────────────────────────────────────────────────

  Widget _aiAssistantSection(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.018),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radius2XLarge),
      ),
      child: Row(
        children: [
          Container(
            width: size.width * 0.12,
            height: size.width * 0.12,
            decoration: BoxDecoration(color: AppColors.whiteColor.withValues(alpha: 0.22), shape: BoxShape.circle),
            child: Icon(Icons.smart_toy_outlined, color: AppColors.whiteColor, size: size.width * 0.058),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Architecture Assistant',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                  ),
                ),
                AppDimensions.spacingXSmall.sh,
                Text(
                  'Describe your dream home and let\n'
                  'our pro-level AI engine generate\n'
                  'architectural concepts for you\n'
                  'instantly.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.whiteColor.withValues(alpha: 0.88),
                    height: 1.3,
                    fontSize: 11,
                  ),
                ),
                AppDimensions.spacingMedium.sh,
                GestureDetector(
                  onTap: controller.openAiChatFromHome,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Chat Now',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        4.0.sw,
                        const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryColor, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recommended for You ─────────────────────────────────────────────

  Widget _recommendedSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recommended for You',
                style: AppTypography.headingSmall.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
              ),
            ),
            CustomTextButton(
              text: 'See all design',
              onPressed: () => controller.openDesignFromHome(),
              style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        AppDimensions.spacingLarge.sh,
        _recommendedList(size),
      ],
    );
  }

  Widget _recommendedList(Size size) {
    return Obx(() {
      final isLoading = controller.isLoadingRecommended.value;
      final designs = controller.recommendedDesigns;

      if (isLoading) {
        return Skeletonizer(
          enabled: true,
          child: Column(
            children: List.generate(
              2,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: i == 0 ? 16 : 0),
                child: Container(
                  height: size.height * 0.26,
                  decoration: BoxDecoration(
                    color: AppColors.subtleSurfaceColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radius2XLarge),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      if (designs.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('No recommendations yet', style: AppTypography.bodyMedium.copyWith(color: AppColors.textBodyColor)),
          ),
        );
      }

      return Column(
        children: List.generate(designs.length, (index) {
          final isLast = index == designs.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.spacingXLarge),
            child: _catalogItem(
              size: size,
              catalog: designs[index],
              onTap: () => controller.openDetailsFromHome(designs[index].id),
            ),
          );
        }),
      );
    });
  }

  // ─── Catalog Item (design card) ──────────────────────────────────────

  Widget _catalogItem({required Size size, required Catalog catalog, VoidCallback? onTap}) {
    final String label = catalog.style.toUpperCase();
    final String specs = '${catalog.area.toStringAsFixed(catalog.area % 1 == 0 ? 0 : 1)}m² • ${catalog.estimatedCost}';
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
                                Expanded(
                                  child: Text(
                                    specs,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textBodyColor,
                                      fontSize: AppTypography.captionLarge.fontSize,
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
                            onTap: () => controller.toggleCatalogLike(catalog.id),
                            child: Icon(
                              catalog.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: catalog.liked ? AppColors.errorColor : AppColors.formBorderColor,
                              size: AppDimensions.iconSizeLarge,
                            ),
                          ),
                          2.0.sh,
                          Text(
                            likesCount,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textBodyColor.withValues(alpha: 0.75),
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

  // ─── Search ──────────────────────────────────────────────────────────

  Widget _searchSection(Size size, {required String hintText}) {
    return Container(
      height: size.height * 0.062,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.primaryColor, size: size.width * 0.055),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.55)),
              ),
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor),
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
              child: Icon(Icons.close_rounded, color: AppColors.textBodyColor, size: size.width * 0.05),
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

      if (controller.searchedArchitects.isEmpty && controller.searchedCatalogs.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text('No result found', style: AppTypography.bodyMedium)),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.searchedArchitects.isNotEmpty) ...[
            Row(
              children: [
                Expanded(child: Text('Architects', style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w700))),
                CustomTextButton(
                  text: 'See all',
                  onPressed: () => controller.openArchitectFromHome(),
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w700),
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
                Expanded(child: Text('Designs', style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w700))),
                CustomTextButton(
                  text: 'See all',
                  onPressed: () => controller.openDesignFromHome(),
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            12.0.sh,
            ...controller.searchedCatalogs.map(
              (catalog) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _catalogItem(size: size, catalog: catalog, onTap: () => controller.openDetailsFromHome(catalog.id)),
              ),
            ),
            20.0.sh,
          ],
        ],
      );
    });
  }

  // ─── Architect Card (for search results) ─────────────────────────────

  Widget _architectCard({required Size size, required Architect architect}) {
    final projectsCount = controller.projectCompletedCount(architect);
    final isPlaceholder = architect.id.isEmpty;
    final catalogs = controller.catalogsByArchitect(architect.id);

    return GestureDetector(
      onTap: isPlaceholder ? null : () => controller.openArchitectPortofolio(architect),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(size.width * 0.03),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.25)),
          boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 10, offset: Offset(0, 4))],
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
                            : (architect.headline.isNotEmpty ? architect.headline : 'Architect'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor),
                      ),
                      2.0.sh,
                      Text(
                        '$projectsCount Projects completed',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.7)),
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
              padding: EdgeInsets.only(right: index < visibleCount - 1 || hiddenCount > 0 ? 6 : 0),
              child: _projectThumb(size, _projectImage(catalogs[index])),
            ),
          );
        }),
        if (hiddenCount > 0) Expanded(child: _moreThumb(size: size, label: '+$hiddenCount')),
      ],
    );
  }

  // ─── Floating Action Buttons ─────────────────────────────────────────

  Widget _floatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'ai_chat_fab',
          onPressed: controller.openAiChatFromHome,
          backgroundColor: AppColors.primaryColor,
          elevation: 4,
          child: const ImageIcon(AssetImage('assets/icons/ai-bot.png'), size: 24, color: AppColors.whiteColor),
        ),
        const SizedBox(height: 12),
        Stack(
          clipBehavior: Clip.none,
          children: [
            FloatingActionButton(
              heroTag: 'chat_fab',
              onPressed: controller.openChatListFromHome,
              backgroundColor: AppColors.primaryColor,
              elevation: 4,
              child: const Icon(Icons.chat_bubble_rounded, color: AppColors.whiteColor),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

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
                  errorBuilder: (_, __, ___) => Image.asset(_dummyImage, fit: BoxFit.cover),
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
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textWhiteColor, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
