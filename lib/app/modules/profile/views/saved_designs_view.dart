import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/modules/profile/controllers/profile_controller.dart';
import 'package:halositek/app/modules/profile/widgets/profile_common_widgets.dart';
import 'package:halositek/app/modules/profile/widgets/profile_top_bar.dart';

class SavedDesignsView extends GetView<ProfileController> {
  const SavedDesignsView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.01,
          ),
          child: Column(
            children: [
              ProfileTopBar(title: 'Saved Design', onBack: controller.goBack),
              const ProfileSearchField(hintText: 'Search saved design'),
              34.0.sh,
              Expanded(
                child: Obx(() {
                  final items = controller.savedProjects;
                  if (items.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        16.0.sh,
                        Icon(
                          Icons.design_services_outlined,
                          size: 32,
                          color: AppColors.textBodyColor,
                        ),
                        12.0.sh,
                        Text(
                          'Belum ada saved design.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textBodyColor,
                          ),
                        ),
                      ],
                    );
                  }
                  return GridView.builder(
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 30,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder:
                        (_, index) => SavedDesignCard(
                          project: items[index],
                          onTap:
                              () => controller.openSavedDesignDetail(
                                items[index],
                              ),
                        ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
