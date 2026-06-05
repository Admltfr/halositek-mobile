import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/modules/profile/widgets/profile_formatters.dart';
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
      floatingActionButton: FloatingActionButton(
        elevation: 8,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
        shape: const CircleBorder(),
        onPressed: controller.startConsultationChat,
        child: const Icon(Icons.smart_toy_outlined),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: controller.refreshPortofolio,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.01,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _topBar(),
                18.0.sh,
                _architectOverview(),
                24.0.sh,
                _tabSwitch(),
                22.0.sh,
                _tabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _architectOverview() {
    return Obx(
      () => Skeletonizer(
        enabled: controller.isLoadingArchitect.value,
        child: Column(
          children: [
            _profileHeader(),
            22.0.sh,
            _stats(),
            22.0.sh,
            _priceAndChat(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          InkWell(
            onTap: controller.goBack,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 15),
            ),
          ),
          Expanded(
            child: Text(
              'Architect Profile',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHeadingColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    return Obx(
      () => Column(
        children: [
          SizedBox(
            height: 138,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 128,
                  height: 128,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.18),
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        controller.architectPhoto.value.isNotEmpty
                            ? Image.network(
                              controller.architectPhoto.value,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Image.asset(
                                    _dummyAvatar,
                                    fit: BoxFit.cover,
                                  ),
                            )
                            : Image.asset(_dummyAvatar, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.08),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowSoftColor,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bookmark_border_rounded,
                      color: AppColors.textHeadingColor,
                      size: 21,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 56,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          18.0.sh,
          Text(
            controller.architectName.value,
            textAlign: TextAlign.center,
            style: AppTypography.headingMedium.copyWith(
              fontSize: 20,
              color: AppColors.textHeadingColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          4.0.sh,
          Text(
            '${controller.architectTitle.value} | ${controller.experienceLabel.value}',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          14.0.sh,
          Text(
            controller.architectBio.value,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textBodyColor,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _statCard(
              controller.totalProjects.value.toString(),
              'PROJECTS',
            ),
          ),
          12.0.sw,
          Expanded(
            child: _statCard(controller.totalAwards.value.toString(), 'AWARDS'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.14),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoftColor,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTypography.headingSmall.copyWith(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          4.0.sh,
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textBodyColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceAndChat() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: AppDimensions.spacingLarge,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          onTap:
              controller.isStartingChat.value
                  ? null
                  : controller.startConsultationChat,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '${formatCurrency(controller.consultationFee.value)} / ${controller.consultationDuration.value} Jam',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              10.0.sw,
              controller.isStartingChat.value
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.whiteColor,
                    ),
                  )
                  : const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.whiteColor,
                    size: 16,
                  ),
              8.0.sw,
              Text(
                controller.isStartingChat.value ? 'Loading...' : 'Chat Now',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabSwitch() {
    return Obx(() {
      final active = controller.activeTab.value;
      return Row(
        children: [
          _tabItem(
            title: 'Portfolio',
            isActive: active == 0,
            onTap: () => controller.setTab(0),
          ),
          _tabItem(
            title: 'Award',
            isActive: active == 1,
            onTap: () => controller.setTab(1),
          ),
        ],
      );
    });
  }

  Widget _tabItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color:
                    isActive ? AppColors.primaryColor : AppColors.textBodyColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            14.0.sh,
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: isActive ? AppColors.primaryColor : AppColors.accentColor,
            ),
          ],
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
      enabled: isLoading,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 18,
          childAspectRatio: 0.74,
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
      enabled: isLoading,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 18,
          childAspectRatio: 0.74,
        ),
        itemBuilder: (_, index) => _awardCard(items[index]),
      ),
    );
  }

  Widget _portfolioCard(Catalog catalog) {
    final images =
        catalog.imageUrls.isNotEmpty ? catalog.imageUrls : catalog.images;
    final image = images.isNotEmpty ? images.first : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox.expand(
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
        ),
        9.0.sh,
        Text(
          catalog.name.isNotEmpty ? catalog.name : 'Project',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textHeadingColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        2.0.sh,
        Text(
          _formatDate(catalog.createdAt),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textBodyColor,
          ),
        ),
      ],
    );
  }

  Widget _awardCard(Award award) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                award.imageUrl.isNotEmpty
                    ? Image.network(
                      award.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              Image.asset(_dummyImage, fit: BoxFit.cover),
                    )
                    : Image.asset(_dummyImage, fit: BoxFit.cover),
          ),
        ),
        9.0.sh,
        Text(
          award.title.isNotEmpty ? award.title : 'Award',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textHeadingColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        2.0.sh,
        Text(
          _formatDate(award.awardDate),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textBodyColor,
          ),
        ),
      ],
    );
  }

  Widget _errorState({required String message, required VoidCallback onRetry}) {
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.errorColor),
        ),
        TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]}, ${date.day} ${date.year}';
  }
}
