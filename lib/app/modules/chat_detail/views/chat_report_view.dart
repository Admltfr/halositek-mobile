import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/chat.dart';

class ChatReportView extends StatelessWidget {
  final String title;
  final String reportReason;
  final String reportStatus;
  final List<ChatMessage> messages;
  final DateTime? reportedAt;

  const ChatReportView({
    super.key,
    required this.title,
    required this.reportReason,
    required this.reportStatus,
    required this.messages,
    this.reportedAt,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(size),
            _reportBanner(size),
            Expanded(child: _messageList(size)),
          ],
        ),
      ),
    );
  }

  Widget _topBar(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radius4XLarge),
            onTap: () => Get.back(),
            child: const Padding(
              padding: EdgeInsets.all(AppDimensions.spacingXSmall),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: AppDimensions.iconSizeSmall,
                color: AppColors.textHeadingColor,
              ),
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Container(
            width: size.width * 0.1,
            height: size.width * 0.1,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(width: size.width * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.trim().isNotEmpty ? title : 'Chat',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHeadingColor,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Laporan Konsultasi',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.errorColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Status chip
          _statusChip(reportStatus),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'resolved':
        color = AppColors.successColor;
        label = 'RESOLVED';
        break;
      case 'pending':
        color = AppColors.warningColor;
        label = 'PENDING';
        break;
      default:
        color = AppColors.textBodyColor;
        label = status.isEmpty ? 'REPORT' : status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLarge,
        vertical: AppDimensions.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _reportBanner(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: AppDimensions.spacingLarge,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: AppColors.errorColor.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.flag_rounded,
            color: AppColors.errorColor,
            size: AppDimensions.iconSizeMedium,
          ),
          AppDimensions.spacingMedium.sw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alasan Laporan',
                  style: AppTypography.captionLarge.copyWith(
                    color: AppColors.errorColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppDimensions.spacingXSmall.sh,
                Text(
                  reportReason.isNotEmpty
                      ? reportReason
                      : 'Tidak ada alasan diberikan.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textBodyColor,
                    height: 1.4,
                  ),
                ),
                if (reportedAt != null) ...[
                  AppDimensions.spacingXSmall.sh,
                  Text(
                    'Dilaporkan pada ${_formatFullDate(reportedAt)}',
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.textBodyColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageList(Size size) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 44,
              color: AppColors.formBorderColor.withValues(alpha: 0.5),
            ),
            AppDimensions.spacingLarge.sh,
            Text(
              'Tidak ada pesan dalam laporan ini.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textBodyColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.015,
      ),
      itemCount: messages.length,
      itemBuilder: (_, index) {
        final msg = messages[index];
        final showDateSep = _shouldShowDateSeparator(messages, index);

        return Column(
          children: [
            if (showDateSep) _dateSeparator(msg.createdAt),
            _messageBubble(size, msg),
            AppDimensions.spacingLarge.sh,
          ],
        );
      },
    );
  }

  bool _shouldShowDateSeparator(List<ChatMessage> msgs, int index) {
    if (index == 0) return true;
    final prev = msgs[index - 1].createdAt;
    final curr = msgs[index].createdAt;
    if (prev == null || curr == null) return false;
    final p = prev.toLocal();
    final c = curr.toLocal();
    return p.year != c.year || p.month != c.month || p.day != c.day;
  }

  Widget _dateSeparator(DateTime? date) {
    final label = _formatDate(date);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingXLarge,
      ),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.formBorderColor.withValues(alpha: 0.25),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXLarge,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLarge,
                vertical: AppDimensions.spacingXSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.subtleSurfaceColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Text(
                label,
                style: AppTypography.captionSmall.copyWith(
                  color: AppColors.textBodyColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.formBorderColor.withValues(alpha: 0.25),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(Size size, ChatMessage message) {
    final isMine = message.isMine;
    final timeText = _formatTime(message.createdAt);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            Container(
              width: size.width * 0.08,
              height: size.width * 0.08,
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primaryColor,
                size: AppDimensions.iconSizeSmall,
              ),
            ),
            AppDimensions.spacingMedium.sw,
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMine && message.sender != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.spacingXSmall,
                      left: AppDimensions.spacingXSmall,
                    ),
                    child: Text(
                      message.sender!.name,
                      style: AppTypography.captionLarge.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (message.hasImage)
                  _imageBubble(size, message)
                else
                  _textBubble(size, message),
                if (timeText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppDimensions.spacingXSmall,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeText,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textBodyColor.withValues(alpha: 0.7),
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.readAt != null
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 14,
                            color: message.readAt != null
                                ? AppColors.infoColor
                                : AppColors.formBorderColor,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isMine) AppDimensions.spacingMedium.sw,
        ],
      ),
    );
  }

  Widget _textBubble(Size size, ChatMessage message) {
    final isMine = message.isMine;
    final bubbleColor =
        isMine ? AppColors.primaryColor : AppColors.subtleSurfaceColor;
    final textColor =
        isMine ? AppColors.whiteColor : AppColors.textHeadingColor;

    return Container(
      constraints: BoxConstraints(maxWidth: size.width * 0.68),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXLarge,
        vertical: AppDimensions.spacingLarge,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            isMine ? AppDimensions.radiusLarge : AppDimensions.radiusXSmall,
          ),
          topRight: Radius.circular(
            isMine ? AppDimensions.radiusXSmall : AppDimensions.radiusLarge,
          ),
          bottomLeft: const Radius.circular(AppDimensions.radiusLarge),
          bottomRight: const Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: Text(
        message.displayBody,
        style: AppTypography.bodySmall.copyWith(
          color: textColor,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _imageBubble(Size size, ChatMessage message) {
    final isMine = message.isMine;
    final imageUrl = message.attachmentUrl ?? '';

    return Container(
      constraints: BoxConstraints(maxWidth: size.width * 0.68),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            isMine ? AppDimensions.radiusLarge : AppDimensions.radiusXSmall,
          ),
          topRight: Radius.circular(
            isMine ? AppDimensions.radiusXSmall : AppDimensions.radiusLarge,
          ),
          bottomLeft: const Radius.circular(AppDimensions.radiusLarge),
          bottomRight: const Radius.circular(AppDimensions.radiusLarge),
        ),
        color: AppColors.subtleSurfaceColor,
      ),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: size.width * 0.3,
                color: AppColors.subtleSurfaceColor,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.formBorderColor,
                  size: 32,
                ),
              ),
            )
          : Container(
              height: size.width * 0.3,
              color: AppColors.subtleSurfaceColor,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.formBorderColor,
                size: 32,
              ),
            ),
    );
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    final hour = local.hour;
    final minute = local.minute;
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final mm = minute.toString().padLeft(2, '0');
    return '${h.toString().padLeft(2, '0')}:$mm $suffix';
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(local.year, local.month, local.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  String _formatFullDate(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = local.hour;
    final minute = local.minute;
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final mm = minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year}, '
        '${h.toString().padLeft(2, '0')}:$mm $suffix';
  }
}
