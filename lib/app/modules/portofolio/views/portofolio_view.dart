import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/portofolio_controller.dart';

class PortofolioView extends GetView<PortofolioController> {
  const PortofolioView({super.key});

  static const String _dummyAvatar = 'assets/images/logo.png';
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
              _topBar(size),
              12.0.sh,
              _profileCard(size),
              12.0.sh,
              _priceAndChat(size),
              14.0.sh,
              _tabSwitch(size),
              12.0.sh,
              _tabContent(size),
              10.0.sh,
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(Size size) {
    return SizedBox(
      height: size.height * 0.04,
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: controller.goBack,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
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
          SizedBox(width: size.width * 0.05),
        ],
      ),
    );
  }

  Widget _profileCard(Size size) {
    return Row(
      children: [
        CircleAvatar(
          radius: size.width * 0.09,
          backgroundColor: AppColors.whiteColor,
          child: ClipOval(
            child: Image.asset(
              _dummyAvatar,
              width: size.width * 0.18,
              height: size.width * 0.18,
              fit: BoxFit.cover,
            ),
          ),
        ),
        12.0.sw,
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
              4.0.sh,
              Obx(
                () => Text(
                  '${controller.architectTitle.value} | ${controller.experienceLabel.value}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textBodyColor,
                  ),
                ),
              ),
              6.0.sh,
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

  Widget _priceAndChat(Size size) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.014),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
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
        10.0.sw,
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.chat_bubble_outline, size: size.width * 0.045),
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
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: size.height * 0.014),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabSwitch(Size size) {
    return Obx(() {
      final active = controller.activeTab.value;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.formBorderColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            _tabItem(
              size: size,
              title: 'Portofolio',
              isActive: active == 0,
              onTap: () => controller.setTab(0),
            ),
            _tabItem(
              size: size,
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
    required Size size,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(10),
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

  Widget _tabContent(Size size) {
    return Obx(() {
      if (controller.activeTab.value == 0) {
        return _portfolioGrid(size);
      }
      return _awardGrid(size);
    });
  }

  Widget _portfolioGrid(Size size) {
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
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (_, index) => _portfolioCard(size, items[index]),
      ),
    );
  }

  Widget _awardGrid(Size size) {
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
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (_, index) => _awardCard(size, items[index]),
      ),
    );
  }

  Widget _portfolioCard(Size size, Catalog catalog) {
    final images =
        catalog.imageUrls.isNotEmpty ? catalog.imageUrls : catalog.images;
    final image = images.isNotEmpty ? images.first : '';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
            padding: EdgeInsets.all(size.width * 0.02),
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

  Widget _awardCard(Size size, Award award) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
            padding: EdgeInsets.all(size.width * 0.02),
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
                2.0.sh,
                Text(
                  award.dateLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textBodyColor.withValues(alpha: 0.8),
                    fontSize: 10,
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
