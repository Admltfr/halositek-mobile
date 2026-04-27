import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';
import '../controllers/detail_controller.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  static const String _dummyImage = 'assets/images/bg-image.png';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(size),
              _heroImage(size),
              _mainInfoCard(size),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _priceSection(size),
                    14.0.sh,
                    _descriptionSection(size),
                    14.0.sh,
                    _layoutSection(size),
                    20.0.sh,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      child: SizedBox(
        height: size.height * 0.045,
        child: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                final nav = Get.find<NavigationController>();

                nav.onPop();
              },
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
                  'Details',
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
      ),
    );
  }

  Widget _heroImage(Size size) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: size.height * 0.28,
          child: Image.asset(_dummyImage, fit: BoxFit.cover),
        ),
        Positioned(
          right: size.width * 0.04,
          bottom: size.height * 0.014,
          child: Container(
            width: size.width * 0.08,
            height: size.width * 0.08,
            decoration: const BoxDecoration(
              color: AppColors.whiteColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: size.width * 0.045,
              color: AppColors.accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mainInfoCard(Size size) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.012,
      ),
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.formBorderColor.withValues(alpha: 0.25),
        ),
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
                  color: AppColors.secondaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'MODERN',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 9,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              8.0.sw,
              Text(
                '340m² • 4 Bedrooms',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textBodyColor,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.favorite_border_rounded,
                size: 17,
                color: AppColors.formBorderColor,
              ),
            ],
          ),
          6.0.sh,
          Row(
            children: [
              Expanded(
                child: Text(
                  'Modern Luxury Residential',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeadingColor,
                  ),
                ),
              ),
              Text(
                '2.300',
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.textBodyColor.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          10.0.sh,
          Row(
            children: [
              CircleAvatar(
                radius: size.width * 0.038,
                backgroundColor: AppColors.formBorderColor.withValues(
                  alpha: 0.2,
                ),
                child: Icon(
                  Icons.person,
                  size: size.width * 0.04,
                  color: AppColors.accentColor,
                ),
              ),
              8.0.sw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'David Larson',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textHeadingColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'ID. 15.000/08/1984',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textBodyColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.008,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: size.width * 0.035,
                      color: AppColors.whiteColor,
                    ),
                    4.0.sw,
                    Text(
                      'Chat Now',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceSection(Size size) {
    return Row(
      children: [
        Expanded(
          child: _priceBox(
            title: 'ESTIMATED COST',
            value: 'Rp3 B - Rp4.6 M',
            valueColor: AppColors.primaryColor,
          ),
        ),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: _priceBox(
            title: 'ESTIMATED AREA',
            value: '220 m² - 228 m²',
            valueColor: AppColors.textHeadingColor,
          ),
        ),
      ],
    );
  }

  Widget _priceBox({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textBodyColor,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        4.0.sh,
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _descriptionSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHeadingColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        8.0.sh,
        Text(
          'Modern Luxury Residential is designed to combine contemporary architecture with comfort and functionality. '
          'This residence features a clean geometric facade, large glass opening for natural lighting, and a harmonious blend '
          'of concrete, wood, and glass materials. The spacious layout creates a seamless connection between indoor and outdoor area, '
          'providing a bright and airy living environment.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textBodyColor,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _layoutSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layout',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHeadingColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        8.0.sh,
        Container(
          width: double.infinity,
          height: size.height * 0.2,
          decoration: BoxDecoration(
            color: const Color(0xFFE9E9E9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.formBorderColor.withValues(alpha: 0.25),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.grid_4x4_rounded,
            color: AppColors.formBorderColor,
            size: size.width * 0.12,
          ),
        ),
      ],
    );
  }
}
