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
  final VoidCallback? onTap;

  const SavedArchitectCard({super.key, required this.architect, this.compact = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final subtitle =
        architect.architectProfile.bio.isNotEmpty ? architect.architectProfile.bio : architect.architectProfile.location;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(compact ? AppDimensions.radiusMedium : AppDimensions.radiusXLarge),
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
  final VoidCallback? onTap;

  const SavedDesignCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Column(
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
      ),
    );
  }
}

class PaymentHistoryCard extends StatelessWidget {
  final PaymentHistory payment;
  final bool positive;

  const PaymentHistoryCard({super.key, required this.payment, this.positive = false});

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction Details',
                      style: AppTypography.headingSmall.copyWith(
                        color: AppColors.textHeadingColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.close)),
                  ],
                ),
                16.0.sh,
                _buildDetailRow('Order ID', payment.orderId),
                12.0.sh,
                _buildDetailRow('Architect', payment.architect.name.isNotEmpty ? payment.architect.name : '-'),
                12.0.sh,
                _buildDetailRow('Duration', '${payment.durationHours} Hours'),
                if (payment.paymentMethod.isNotEmpty) ...[12.0.sh, _buildDetailRow('Payment Method', payment.paymentMethod)],
                12.0.sh,
                _buildDetailRow('Date', formatDate(payment.paidAt ?? payment.createdAt)),
                const Divider(height: 24),
                _buildDetailRow('Amount', formatCurrency(payment.amount)),
                12.0.sh,
                _buildDetailRow('Tax', formatCurrency(payment.taxAmount)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Paid',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHeadingColor,
                      ),
                    ),
                    Text(
                      formatCurrency(payment.totalPaidAmount),
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor)),
        16.0.sw,
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'success':
        bgColor = AppColors.successColor.withValues(alpha: 0.1);
        textColor = AppColors.successColor;
        text = 'Success';
        break;
      case 'pending':
        bgColor = AppColors.warningColor.withValues(alpha: 0.1);
        textColor = AppColors.warningColor;
        text = 'Pending';
        break;
      case 'cancelled':
      case 'cancel':
        bgColor = AppColors.errorColor.withValues(alpha: 0.1);
        textColor = AppColors.errorColor;
        text = 'Cancel';
        break;
      default:
        bgColor = AppColors.formBorderColor.withValues(alpha: 0.1);
        textColor = AppColors.formBorderColor;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
      child: Text(text.toUpperCase(), style: AppTypography.caption.copyWith(color: textColor, fontWeight: FontWeight.w800)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.14)),
        boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          onTap: () => _showDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
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
                        payment.architect.name.isNotEmpty
                            ? '${payment.architect.name} Consultation'
                            : 'Residential Consultation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textHeadingColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      3.0.sh,
                      Text(
                        '${formatDate(payment.paidAt ?? payment.createdAt).toUpperCase()} - ${payment.durationHours}H CONSULTATION',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.captionLarge.copyWith(
                          color: AppColors.textBodyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                8.0.sw,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(payment.status),
                    6.0.sh,
                    Text(
                      formatCurrency(payment.totalPaidAmount),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textHeadingColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
