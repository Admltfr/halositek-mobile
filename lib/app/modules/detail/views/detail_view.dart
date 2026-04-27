import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          final hasError = controller.errorMessage.value.isNotEmpty;
          final hasData = controller.catalog.value != null;

          if (hasError && !hasData) {
            return Column(
              children: [
                Text(
                  'Detail gagal dimuat',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.errorColor,
                  ),
                ),
                TextButton(
                  onPressed: controller.fetchCatalogDetail,
                  child: const Text('Coba Lagi'),
                ),
              ],
            );
          }

          final project = controller.catalog.value ?? Catalog.dummy();

          return Skeletonizer(
            enabled: isLoading,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(size),
                  _heroImage(size),
                  _mainInfoCard(size, project),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _priceSection(size),
                        14.0.sh,
                        _descriptionSection(project),
                        14.0.sh,
                        _layoutSection(size),
                        20.0.sh,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
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
    final images = controller.projectImages;
    final active = controller.activeImageIndex.value;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: size.height * 0.28,
          child:
              images.isNotEmpty
                  ? PageView.builder(
                    itemCount: images.length,
                    onPageChanged: controller.setActiveImageIndex,
                    itemBuilder: (_, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                Image.asset(_dummyImage, fit: BoxFit.cover),
                      );
                    },
                  )
                  : Image.asset(_dummyImage, fit: BoxFit.cover),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isActive = index == active;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 8 : 6,
                  height: isActive ? 8 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isActive
                            ? AppColors.primaryColor
                            : AppColors.whiteColor,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _mainInfoCard(Size size, Catalog p) {
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
                  p.style.toUpperCase(),
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 9,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              8.0.sw,
              Text(
                controller.areaDisplay,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textBodyColor,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: controller.toggleLike,
                child: Icon(
                  p.liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 17,
                  color:
                      p.liked
                          ? AppColors.errorColor
                          : AppColors.formBorderColor,
                ),
              ),
            ],
          ),
          6.0.sh,
          Row(
            children: [
              Expanded(
                child: Text(
                  p.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeadingColor,
                  ),
                ),
              ),
              Text(
                p.likesCount.toString(),
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
                      controller.architectName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textHeadingColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      controller.architectEmail,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textBodyColor,
                        fontSize: 10,
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
            value: controller.estimatedCostDisplay,
            valueColor: AppColors.primaryColor,
          ),
        ),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: _priceBox(
            title: 'AREA',
            value: controller.areaDisplay,
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

  Widget _descriptionSection(Catalog p) {
    final hasHighlight = p.highlightFeatures.trim().isNotEmpty;
    final desc =
        hasHighlight
            ? '${p.description}\n\nHighlight Features: ${p.highlightFeatures}'
            : p.description;

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
          desc.trim().isEmpty ? '-' : desc,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textBodyColor,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _layoutSection(Size size) {
    final layouts = controller.projectLayoutImages;

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
        if (layouts.isEmpty)
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
          )
        else
          SizedBox(
            height: size.height * 0.2,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: layouts.length,
              separatorBuilder: (_, __) => SizedBox(width: size.width * 0.03),
              itemBuilder: (_, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    layouts[index],
                    width: size.width * 0.7,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Image.asset(
                          _dummyImage,
                          width: size.width * 0.7,
                          fit: BoxFit.cover,
                        ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
