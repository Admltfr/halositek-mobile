import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_enums.dart';
import 'package:halositek/app/routes/route_middleware.dart';

extension SpaceExtension on double {
  SizedBox get sh => SizedBox(height: this);
  SizedBox get sw => SizedBox(width: this);
}

extension RoleExtension on UserRole {
  String get text {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.architect:
        return 'architect';
    }
  }
}

extension CustomGetPage on GetPage {
  GetPage withRole(List<String> allowedRoles) {
    return GetPage(
      name: name,
      page: page,
      binding: binding,
      transition: transition,
      middlewares: [RoleMiddleware(allowedRoles: allowedRoles)],
    );
  }
}
