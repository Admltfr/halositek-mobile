import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/architect_controller.dart';

class ArchitectView extends GetView<ArchitectController> {
  const ArchitectView({super.key});

  static const String _dummyAvatar = 'assets/images/logo.png';
  static const String _dummyProject = 'assets/images/bg-image.png';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: controller.refreshArchitects,
          child: SingleChildScrollView(
            controller: controller.scrollController,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.01),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBarSection(),
                18.0.sh,
                _searchSection(size),
                18.0.sh,
                _architectListSection(size),
                AppDimensions.spacingSemibold.sh,
              ],
            ),
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
            child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.arrow_back_ios_new_rounded, size: 15)),
          ),
          Expanded(
            child: Text(
              'Architects',
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
                      hintText: 'Search Architects',
                      hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.55)),
                    ),
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _architectListSection(Size size) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final isLoadingMore = controller.isLoadingMore.value;
      final hasError = controller.errorMessage.value.isNotEmpty;
      final hasData = controller.hasData;

      if (hasError && !hasData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.errorMessage.value, style: AppTypography.bodySmall.copyWith(color: AppColors.errorColor)),
            TextButton(onPressed: () => controller.fetchArchitects(reset: true), child: const Text('Coba Lagi')),
          ],
        );
      }

      if (!isLoading && !hasData) {
        return _emptyState();
      }

      final architects = hasData ? controller.architects : List.generate(3, (_) => Architect.dummy());

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeletonizer(
            enabled: isLoading && !hasData,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: architects.length,
              separatorBuilder: (_, __) => AppDimensions.spacingSemibold.sh,
              itemBuilder: (_, index) {
                return _architectCard(size: size, architect: architects[index]);
              },
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

  Widget _architectCard({required Size size, required Architect architect}) {
    final projectsCount = controller.projectCompletedCount(architect);
    final hiddenCount = controller.hiddenProjectsCount(architect);
    final isPlaceholder = architect.id.isEmpty;

    return GestureDetector(
      onTap: isPlaceholder ? null : () => controller.openPortofolio(architect),
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
            Row(
              children: [
                Expanded(child: _projectThumb(size, _projectImage(architect, 0))),
                6.0.sw,
                Expanded(child: _projectThumb(size, _projectImage(architect, 1))),
                6.0.sw,
                Expanded(child: _moreThumb(size: size, label: hiddenCount > 0 ? '+$hiddenCount' : '+0')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final hasSearch = controller.searchController.text.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXLarge, vertical: AppDimensions.spacing3XLarge),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: AppColors.textBodyColor.withValues(alpha: 0.45), size: 36),
          10.0.sh,
          Text(
            hasSearch ? 'Architect tidak ditemukan' : 'Belum ada architect',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
          ),
          4.0.sh,
          Text(
            hasSearch ? 'Coba gunakan kata kunci lain.' : 'Data architect belum tersedia.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }

  String _projectImage(Architect architect, int index) {
    if (architect.projects.length <= index) return _dummyProject;

    final project = architect.projects[index];
    if (project.images.isNotEmpty) return project.images.first;
    if (project.imageUrls.isNotEmpty) return project.imageUrls.first;
    return _dummyProject;
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
                  errorBuilder: (_, __, ___) => Image.asset(_dummyProject, fit: BoxFit.cover),
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
            Image.asset(_dummyProject, fit: BoxFit.cover),
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
