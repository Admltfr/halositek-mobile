import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/modules/profile/controllers/profile_controller.dart';
import 'package:halositek/app/modules/profile/widgets/profile_common_widgets.dart';
import 'package:halositek/app/modules/profile/widgets/profile_top_bar.dart';

class SavedArchitectsView extends GetView<ProfileController> {
  const SavedArchitectsView({super.key});

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
              ProfileTopBar(
                title: 'Saved Architect',
                onBack: controller.goBack,
              ),
              const ProfileSearchField(hintText: 'Search saved architect'),
              26.0.sh,
              Expanded(
                child: Obx(() {
                  final items = controller.savedArchitects;
                  if (items.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        16.0.sh,
                        Icon(
                          Icons.people_alt_outlined,
                          size: 32,
                          color: AppColors.textBodyColor,
                        ),
                        12.0.sh,
                        Text(
                          'Belum ada saved architect.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textBodyColor,
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => 16.0.sh,
                    itemBuilder:
                        (_, index) => SavedArchitectCard(
                          architect: items[index],
                          onTap:
                              () => controller.openSavedArchitectDetail(
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
