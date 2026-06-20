import 'package:get/get.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/architect_service.dart';
import 'package:halositek/app/data/network/auth_service.dart';
import 'package:halositek/app/data/network/token_service.dart';

import '../controllers/profile_edit_controller.dart';

class ProfileEditBinding extends Bindings {
  ProfileEditBinding({this.initialArchitect});

  final Architect? initialArchitect;

  @override
  void dependencies() {
    if (!Get.isRegistered<ArchitectService>()) {
      Get.lazyPut<ArchitectService>(
        () => ArchitectService(Get.find<ApiClient>()),
      );
    }

    Get.lazyPut<ProfileEditController>(
      () => ProfileEditController(
        Get.find<ArchitectService>(),
        Get.find<AuthService>(),
        Get.find<TokenService>(),
        initialArchitect: initialArchitect,
      ),
    );
  }
}
