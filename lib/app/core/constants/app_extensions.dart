import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

extension ImageUrlExtension on String {
  String toImageUrl({String? baseUrl}) {
    if (isEmpty) return '';

    if (startsWith('http://') || startsWith('https://')) {
      return this;
    }

    final domain = (baseUrl ?? dotenv.env['BASEURL'] ?? '').trim().replaceAll(
      RegExp(r'\/+$'),
      '',
    );

    if (startsWith('/storage')) {
      return '$domain$this';
    }

    if (startsWith('storage/')) {
      return '$domain/$this';
    }

    return '$domain/storage/$this';
  }
}
