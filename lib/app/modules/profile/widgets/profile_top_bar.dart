import 'package:flutter/material.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_typography.dart';

class ProfileTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onLogout;

  const ProfileTopBar({
    super.key,
    required this.title,
    required this.onBack,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 15),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHeadingColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child:
                onLogout == null
                    ? const SizedBox.shrink()
                    : IconButton(
                      tooltip: 'Logout',
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout_rounded, size: 20),
                    ),
          ),
        ],
      ),
    );
  }
}
