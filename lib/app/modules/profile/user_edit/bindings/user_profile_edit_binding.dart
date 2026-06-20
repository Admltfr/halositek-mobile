import 'package:get/get.dart';
import 'package:halositek/app/data/models/user.dart';
import 'package:halositek/app/data/network/auth_service.dart';

import '../controllers/user_profile_edit_controller.dart';

class UserProfileEditBinding extends Bindings {
  UserProfileEditBinding({this.initialUser});

  final UserProfile? initialUser;

  @override
  void dependencies() {
    Get.lazyPut<UserProfileEditController>(
      () => UserProfileEditController(
        Get.find<AuthService>(),
        initialUser: initialUser,
      ),
    );
  }
}
