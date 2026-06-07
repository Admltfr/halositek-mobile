import 'package:flutter/material.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/user.dart';
import 'profile_formatters.dart';

const profileFallbackImage = 'assets/images/bg-image.png';

class ProfileEmptyState extends StatelessWidget {
  final String message;

  const ProfileEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.22)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor),
      ),
    );
  }
}

class ProfileSearchField extends StatelessWidget {
  final String hintText;

  const ProfileSearchField({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: AppTypography.bodySmall.copyWith(color: AppColors.textHeadingColor),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primaryColor),
        filled: true,
        fillColor: AppColors.whiteColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.28)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}

class SavedArchitectCard extends StatelessWidget {
  final SavedArchitect architect;
  final bool compact;

  const SavedArchitectCard({super.key, required this.architect, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final subtitle =
        architect.architectProfile.bio.isNotEmpty ? architect.architectProfile.bio : architect.architectProfile.location;

    return Container(
      child:
          compact
              ? Column(
                children: [
                  _Avatar(url: architect.photoProfileUrl, radius: 30),
                  6.0.sh,
                  Text(
                    architect.name.isNotEmpty ? architect.name : '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
                  ),
                ],
              )
              : Container(
                padding: EdgeInsets.all(compact ? 8 : 16),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
                  border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.14)),
                  boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 12, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    _Avatar(url: architect.photoProfileUrl, radius: 30),
                    16.0.sw,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            architect.name.isNotEmpty ? architect.name : '-',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textHeadingColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          4.0.sh,
                          Text(
                            subtitle.isNotEmpty ? subtitle : 'Architect',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.bookmark, color: AppColors.secondaryColor),
                  ],
                ),
              ),
    );
  }
}

class SavedDesignCard extends StatelessWidget {
  final SavedProject project;

  const SavedDesignCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: SizedBox.expand(
                  child:
                      project.imageUrl.isNotEmpty
                          ? Image.network(
                            project.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(profileFallbackImage, fit: BoxFit.cover),
                          )
                          : Image.asset(profileFallbackImage, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.whiteColor.withValues(alpha: 0.9),
                  child: const Icon(Icons.bookmark, size: 18, color: AppColors.secondaryColor),
                ),
              ),
            ],
          ),
        ),
        8.0.sh,
        Text(
          project.title.isNotEmpty ? project.title : '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w800),
        ),
        3.0.sh,
        Text(
          project.style.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.captionLarge.copyWith(color: AppColors.textBodyColor, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class PaymentHistoryCard extends StatelessWidget {
  final PaymentHistory payment;
  final bool positive;

  const PaymentHistoryCard({super.key, required this.payment, this.positive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.14)),
        boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: const Icon(Icons.payments_outlined, color: AppColors.primaryColor),
          ),
          12.0.sw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.architect.name.isNotEmpty ? '${payment.architect.name} Consultation' : 'Residential Consultation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w800),
                ),
                3.0.sh,
                Text(
                  '${formatDate(payment.paidAt ?? payment.createdAt).toUpperCase()} - ${payment.durationHours}H CONSULTATION',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionLarge.copyWith(color: AppColors.textBodyColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            '${positive ? '+' : '-'} ${formatCurrency(payment.totalPaidAmount)}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class ProfileFab extends StatelessWidget {
  const ProfileFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.whiteColor,
      child: const Icon(Icons.business_center_outlined),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final double radius;

  const _Avatar({required this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.subtleSurfaceColor,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty ? const Icon(Icons.person_outline_rounded) : null,
    );
  }
}
