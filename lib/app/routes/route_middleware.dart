import 'package:get/get.dart';

import 'package:halositek/app/data/network/token_service.dart';

import 'app_pages.dart';

class RoleMiddleware extends GetMiddleware {
  RoleMiddleware({required this.allowedRoles});

  final List<String> allowedRoles;

  @override
  int? get priority => 0;

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final tokenService = Get.find<TokenService>();

    final token = await tokenService.getAccessToken();

    final role = await tokenService.getRole();

    if (token == null  || role == null) {
      return GetNavConfig.fromRoute(Routes.LOGIN);
    }

    if (!allowedRoles.contains(role)) {
      return GetNavConfig.fromRoute(Routes.LOGIN);
    }

    return await super.redirectDelegate(route);
  }
}
