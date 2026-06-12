import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/chat.dart';
import '../controllers/chat_detail_controller.dart';

class ChatDetailView extends GetView<ChatDetailController> {
  const ChatDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(size),
            Expanded(child: _messageList(size)),
            Obx(() => controller.isSessionExpired.value
                ? _expiredBanner(size)
                : _inputBar(size)),
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
            onTap: controller.goBack,
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
          // Avatar circle
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
                  controller.displayTitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHeadingColor,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Konsultasi',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textBodyColor.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          // Report flag button (red)
          InkWell(
            onTap: () => _showReportModal(),
            borderRadius: BorderRadius.circular(AppDimensions.radius4XLarge),
            child: const Padding(
              padding: EdgeInsets.all(AppDimensions.spacingSmall),
              child: Icon(
                Icons.flag_rounded,
                color: AppColors.errorColor,
                size: AppDimensions.iconSizeMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageList(Size size) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final hasError = controller.errorMessage.value.isNotEmpty;

      if (hasError && controller.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: AppColors.errorColor.withValues(alpha: 0.5),
                size: 40,
              ),
              AppDimensions.spacingLarge.sh,
              Text(
                controller.errorMessage.value,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              AppDimensions.spacingMedium.sh,
              TextButton(
                onPressed: controller.fetchMessages,
                child: Text(
                  'Coba Lagi',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final msgs = controller.messages;

      return ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.015,
        ),
        itemCount: msgs.length + (isLoading ? 1 : 0),
        itemBuilder: (_, index) {
          if (isLoading && index == msgs.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingLarge,
              ),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            );
          }

          final msg = msgs[index];
          final showDateSep = _shouldShowDateSeparator(msgs, index);

          return Column(
            children: [
              if (showDateSep) _dateSeparator(msg.createdAt),
              _messageBubble(size, msg),
              AppDimensions.spacingLarge.sh,
            ],
          );
        },
      );
    });
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
              margin: const EdgeInsets.only(
                bottom: AppDimensions.spacingSmall,
              ),
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
                // Sender name (for non-mine)
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
                // Timestamp
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
    final hasCaption = message.displayBody.isNotEmpty &&
        message.displayBody != imageUrl;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: size.width * 0.45,
                  color: AppColors.subtleSurfaceColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                height: size.width * 0.3,
                color: AppColors.subtleSurfaceColor,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.formBorderColor,
                  size: 32,
                ),
              ),
            ),
          if (hasCaption)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXLarge,
                vertical: AppDimensions.spacingSmall,
              ),
              child: Text(
                message.displayBody,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textBodyColor,
                  height: 1.35,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _expiredBanner(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: AppDimensions.spacingXLarge,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_off_rounded,
            color: AppColors.primaryColor,
            size: AppDimensions.iconSizeMedium,
          ),
          AppDimensions.spacingMedium.sw,
          Expanded(
            child: Text(
              'Sesi konsultasi telah berakhir. Anda tidak dapat lagi mengirim pesan.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar(Size size) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          size.width * 0.04,
          size.height * 0.01,
          size.width * 0.04,
          size.height * 0.018,
        ),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border(
            top: BorderSide(
              color: AppColors.formBorderColor.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            // Attachment / image button
            Obx(
              () => InkWell(
                onTap: controller.isSending.value
                    ? null
                    : controller.pickAndSendImage,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusCircle,
                ),
                child: Container(
                  width: size.width * 0.1,
                  height: size.width * 0.1,
                  decoration: BoxDecoration(
                    color: AppColors.subtleSurfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.textBodyColor,
                    size: AppDimensions.iconSizeLarge,
                  ),
                ),
              ),
            ),
            AppDimensions.spacingMedium.sw,
            // Text field
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.035,
                  vertical: AppDimensions.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  border: Border.all(
                    color: AppColors.formBorderColor.withValues(alpha: 0.35),
                  ),
                ),
                child: TextField(
                  controller: controller.messageController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => controller.sendMessage(),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Ketik pesan...',
                    hintStyle: AppTypography.bodySmall.copyWith(
                      color: AppColors.textBodyColor.withValues(alpha: 0.55),
                    ),
                  ),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textHeadingColor,
                  ),
                ),
              ),
            ),
            AppDimensions.spacingMedium.sw,
            // Send button
            Obx(
              () => InkWell(
                onTap: controller.isSending.value ? null : controller.sendMessage,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                child: Container(
                  width: size.width * 0.1,
                  height: size.width * 0.1,
                  decoration: BoxDecoration(
                    color: controller.isSending.value
                        ? AppColors.primaryColor.withValues(alpha: 0.5)
                        : AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: controller.isSending.value
                      ? const Padding(
                          padding: EdgeInsets.all(
                            AppDimensions.spacingXLarge,
                          ),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.whiteColor,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: AppColors.whiteColor,
                          size: size.width * 0.045,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportModal() {
    controller.reportController.clear();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Builder(
          builder: (context) {
            final size = MediaQuery.of(context).size;
            return Container(
              padding: const EdgeInsets.all(AppDimensions.spacing2XLarge),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radius2XLarge,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Consultation Issue',
                    style: AppTypography.headingSmall.copyWith(
                      color: AppColors.textHeadingColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  AppDimensions.spacingMedium.sh,
                  Text(
                    'Please provide details about the problem you encountered during your session.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textBodyColor,
                      height: 1.45,
                    ),
                  ),
                  AppDimensions.spacing4XLarge.sh,
                  Text(
                    'DETAILED REASON',
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  AppDimensions.spacingMedium.sh,
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.formBorderColor.withValues(alpha: 0.4),
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLarge,
                      ),
                    ),
                    child: TextField(
                      controller: controller.reportController,
                      maxLines: 5,
                      minLines: 4,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textHeadingColor,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Describe the issue in detail...',
                        hintStyle: AppTypography.bodySmall.copyWith(
                          color: AppColors.textBodyColor.withValues(alpha: 0.5),
                        ),
                        contentPadding: const EdgeInsets.all(
                          AppDimensions.spacingXLarge,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  AppDimensions.spacing4XLarge.sh,
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: size.height * 0.058,
                      child: ElevatedButton(
                        onPressed: controller.isSubmittingReport.value
                            ? null
                            : controller.submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.whiteColor,
                          disabledBackgroundColor: AppColors.primaryColor
                              .withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusPill,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isSubmittingReport.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.whiteColor,
                                  ),
                                ),
                              )
                            : Text(
                                'Submit Report',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                  AppDimensions.spacingLarge.sh,
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textBodyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: true,
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
}
