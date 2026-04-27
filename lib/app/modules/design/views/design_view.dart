import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';

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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBarSection(size),
              14.0.sh,
              _searchSection(size),
              14.0.sh,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _designCardSection(
                        size: size,
                        title: 'Modern Luxury Residential',
                        label: 'MODERN',
                        specs: '340m² • 4 Bedrooms',
                        showFloatingAction: true,
                        onTap: _openDetailsFromDesign,
                      ),
                      12.0.sh,
                      _designCardSection(
                        size: size,
                        title: 'Modern Luxury Residential',
                        label: 'MODERN',
                        specs: '340m² • 4 Bedrooms',
                        onTap: _openDetailsFromDesign,
                      ),
                      12.0.sh,
                      _designCardSection(
                        size: size,
                        title: 'Modern Luxury Residential',
                        label: 'MODERN',
                        specs: '340m² • 4 Bedrooms',
                        onTap: _openDetailsFromDesign,
                      ),
                      10.0.sh,
                    ],
                  ),
                ),
              ),
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

  Widget _aiDesignButton(Size size) {
    return Container(
      height: size.height * 0.052,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Text(
            'AI Design',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.whiteColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: size.width * 0.01),
          Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.whiteColor,
            size: size.width * 0.038,
          ),
        ],
      ),
    );
  }

  Widget _designCardSection({
    required Size size,
    required String title,
    required String label,
    required String specs,
    bool showFloatingAction = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.formBorderColor.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.60,
                    child: Image.asset(_dummyImage, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: size.width * 0.02,
                  right: size.width * 0.02,
                  child: Container(
                    width: size.width * 0.07,
                    height: size.width * 0.07,
                    decoration: const BoxDecoration(
                      color: AppColors.whiteColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmark_border_rounded,
                      color: AppColors.accentColor,
                      size: size.width * 0.042,
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.width * 0.024,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == 0 ? 7 : 5,
                        height: index == 0 ? 7 : 5,
                        decoration: BoxDecoration(
                          color:
                              index == 0
                                  ? AppColors.primaryColor
                                  : AppColors.whiteColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                if (showFloatingAction)
                  Positioned(
                    right: -8,
                    top: size.height * 0.22,
                    child: Container(
                      width: size.width * 0.085,
                      height: size.width * 0.085,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.business_center_outlined,
                        color: AppColors.whiteColor,
                        size: size.width * 0.045,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                size.width * 0.025,
                size.height * 0.008,
                size.width * 0.025,
                size.height * 0.010,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.017,
                          vertical: size.height * 0.003,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor.withValues(
                            alpha: 0.20,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          label,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      8.0.sw,
                      Text(
                        specs,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textBodyColor,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.favorite_border_rounded,
                        color: AppColors.formBorderColor,
                        size: 17,
                      ),
                    ],
                  ),
                  5.0.sh,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textHeadingColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '2.300',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textBodyColor.withValues(
                            alpha: 0.75,
                          ),
                          fontSize: 10,
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

  void _openDetailsFromDesign() {
    Get.toNamed('/detail', id: 2);
  }
}
