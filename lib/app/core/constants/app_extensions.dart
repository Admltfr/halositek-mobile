import 'package:flutter/material.dart';

extension SpaceExtension on double {
  SizedBox get sh => SizedBox(height: this);
  SizedBox get sw => SizedBox(width: this);
}
