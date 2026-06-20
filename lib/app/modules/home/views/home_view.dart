import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'architect_home_view.dart';
import 'user_home_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isArchitect.value) {
        return const ArchitectHomeView();
      } else {
        return const UserHomeView();
      }
    });
  }
}
