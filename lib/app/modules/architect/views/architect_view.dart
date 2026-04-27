import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
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
              _architectListSection(size),
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
                'Architects',
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

  Widget _architectListSection(Size size) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final hasError = controller.errorMessage.value.isNotEmpty;
      final hasData = controller.hasData;

      if (hasError && !hasData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.errorMessage.value,
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

      final architects =
          hasData
              ? controller.architects
              : List.generate(3, (_) => Architect.dummy());

      return Skeletonizer(
        enabled: isLoading && !hasData,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: architects.length,
          separatorBuilder: (_, __) => 10.0.sh,
          itemBuilder: (_, index) {
            return _architectCard(size: size, architect: architects[index]);
          },
        ),
      );
    });
  }

  Widget _architectCard({required Size size, required Architect architect}) {
    final projectsCount = controller.projectCompletedCount(architect);
    final hiddenCount = controller.hiddenProjectsCount(architect);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.formBorderColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: size.width * 0.06,
                backgroundColor: AppColors.whiteColor,
                child: ClipOval(
                  child:
                      architect.profilePicture.isNotEmpty
                          ? Image.network(
                            architect.profilePicture,
                            width: size.width * 0.12,
                            height: size.width * 0.12,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Image.asset(
                                  _dummyAvatar,
                                  width: size.width * 0.12,
                                  height: size.width * 0.12,
                                  fit: BoxFit.cover,
                                ),
                          )
                          : Image.asset(
                            _dummyAvatar,
                            width: size.width * 0.12,
                            height: size.width * 0.12,
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              10.0.sw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      architect.name.isNotEmpty ? architect.name : '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLarge.copyWith(
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
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textBodyColor.withValues(alpha: 0.9),
                      ),
                    ),
                    2.0.sh,
                    Text(
                      '$projectsCount Projects completed',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textBodyColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          10.0.sh,
          Row(
            children: [
              Expanded(child: _projectThumb(size, _dummyProject)),
              6.0.sw,
              Expanded(child: _projectThumb(size, _dummyProject)),
              6.0.sw,
              Expanded(
                child: _moreThumb(
                  size: size,
                  label: hiddenCount > 0 ? '+$hiddenCount' : '+0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _projectThumb(Size size, String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1.25,
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }

  Widget _moreThumb({required Size size, required String label}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
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
