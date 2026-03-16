import 'package:flutter/material.dart';
import 'package:halositek/app/constants/app_colors.dart';

class HeroBg extends StatelessWidget {
  final Size size;
  const HeroBg({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.5,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg-image.png', fit: BoxFit.cover),
          Container(color: AppColors.blackColor.withOpacity(0.3)),
        ],
      ),
    );
  }
}
