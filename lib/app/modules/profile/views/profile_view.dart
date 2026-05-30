import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/modules/profile/views/architect_profile_view.dart';
import 'package:halositek/app/modules/profile/views/user_profile_view.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isReady.value) {
        return const Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: SafeArea(child: Center(child: CircularProgressIndicator())),
        );
      }

      return controller.isArchitect
          ? ArchitectProfileView(controller: controller)
          : UserProfileView(controller: controller);
    });
  }
}
