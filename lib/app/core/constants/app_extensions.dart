import 'package:flutter/material.dart';
import 'package:halositek/app/core/constants/app_enums.dart';

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
