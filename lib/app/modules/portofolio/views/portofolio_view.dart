import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controllers/portofolio_controller.dart';

class PortofolioView extends GetView<PortofolioController> {
  const PortofolioView({super.key});

  static const String _dummyAvatar = 'assets/images/logo.png';
  static const String _dummyImage = 'assets/images/bg-image.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pageHorizontalPadding,
            vertical: AppDimensions.pageVerticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              AppDimensions.spacingLarge.sh,
              _profileCard(),
              AppDimensions.spacingLarge.sh,
              _priceAndChat(),
              AppDimensions.spacingXLarge.sh,
              _tabSwitch(),
              AppDimensions.spacingLarge.sh,
              _tabContent(),
              AppDimensions.spacingSemibold.sh,
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radius4XLarge),
            onTap: controller.goBack,
            child: const Padding(
              padding: EdgeInsets.all(AppDimensions.spacingXSmall),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: AppDimensions.iconSizeSmall,
                color: AppColors.textHeadingColor,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Architect Profile',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHeadingColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.avatarIndicatorSize / 2),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.whiteColor,
          child: ClipOval(
            child: Image.asset(
              _dummyAvatar,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
        ),
        AppDimensions.spacingLarge.sw,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  controller.architectName.value,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textHeadingColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppDimensions.spacingXSmall.sh,
              Obx(
                () => Text(
                  '${controller.architectTitle.value} | ${controller.experienceLabel.value}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textBodyColor,
                  ),
                ),
              ),
              AppDimensions.spacingSmall.sh,
              Text(
                'Specializing in sustainable modern residential design.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textBodyColor.withValues(alpha: 0.85),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceAndChat() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            child: Center(
              child: Text(
                'Rp 25.000 / 3 jam',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        AppDimensions.spacingSemibold.sw,
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.chat_bubble_outline,
              size: AppDimensions.iconSizeSmall + 1,
            ),
            label: Text(
              'Chat Now',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabSwitch() {
    return Obx(() {
      final active = controller.activeTab.value;
      return Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXSmall),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          border: Border.all(
            color: AppColors.formBorderColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            _tabItem(
              title: 'Portofolio',
              isActive: active == 0,
              onTap: () => controller.setTab(0),
            ),
            _tabItem(
              title: 'Award',
              isActive: active == 1,
              onTap: () => controller.setTab(1),
            ),
          ],
        ),
      );
    });
  }

  Widget _tabItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color:
                    isActive ? AppColors.whiteColor : AppColors.textBodyColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabContent() {
    return Obx(() {
      if (controller.activeTab.value == 0) {
        return _portfolioGrid();
      }
      return _awardGrid();
    });
  }

  Widget _portfolioGrid() {
    final isLoading = controller.isLoadingPortfolio.value;
    final hasError = controller.portfolioError.value.isNotEmpty;
    final hasData = controller.portfolios.isNotEmpty;

    if (hasError && !hasData) {
      return _errorState(
        message: controller.portfolioError.value,
        onRetry: controller.fetchPortfolios,
      );
    }

    final items =
        hasData
            ? controller.portfolios
            : List.generate(6, (_) => Catalog.dummy());

    return Skeletonizer(
      enabled: isLoading && !hasData,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppDimensions.spacingLarge,
          crossAxisSpacing: AppDimensions.spacingLarge,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (_, index) => _portfolioCard(items[index]),
      ),
    );
  }

  Widget _awardGrid() {
    final isLoading = controller.isLoadingAward.value;
    final hasError = controller.awardError.value.isNotEmpty;
    final hasData = controller.awards.isNotEmpty;

    if (hasError && !hasData) {
      return _errorState(
        message: controller.awardError.value,
        onRetry: controller.fetchAwards,
      );
    }

    final items =
        hasData ? controller.awards : List.generate(6, (_) => Award.dummy());

    return Skeletonizer(
      enabled: isLoading && !hasData,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppDimensions.spacingLarge,
          crossAxisSpacing: AppDimensions.spacingLarge,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (_, index) => _awardCard(items[index]),
      ),
    );
  }

  Widget _portfolioCard(Catalog catalog) {
    final images =
        catalog.imageUrls.isNotEmpty ? catalog.imageUrls : catalog.images;
    final image = images.isNotEmpty ? images.first : '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoftColor,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXLarge),
            ),
            child: AspectRatio(
              aspectRatio: 1.1,
              child:
                  image.isNotEmpty
                      ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                Image.asset(_dummyImage, fit: BoxFit.cover),
                      )
                      : Image.asset(_dummyImage, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              catalog.name.isNotEmpty ? catalog.name : 'Project',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textHeadingColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _awardCard(Award award) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoftColor,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXLarge),
            ),
            child: AspectRatio(
              aspectRatio: 1.1,
              child:
                  award.imageUrl.isNotEmpty
                      ? Image.network(
                        award.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                Image.asset(_dummyImage, fit: BoxFit.cover),
                      )
                      : Image.asset(_dummyImage, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  award.title.isNotEmpty ? award.title : 'Award',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textHeadingColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppDimensions.spacingExtraSmall.sh,
                Text(
                  award.dateLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textBodyColor.withValues(alpha: 0.8),
                    fontSize: AppTypography.caption.fontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState({required String message, required VoidCallback onRetry}) {
    return Column(
      children: [
        Text(
          message,
          style: AppTypography.bodySmall.copyWith(color: AppColors.errorColor),
        ),
        TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
      ],
    );
  }
}
