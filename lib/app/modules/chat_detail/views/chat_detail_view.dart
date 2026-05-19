import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/chat_message.dart';
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
            _inputBar(size),
          ],
        ),
      ),
    );
  }

  Widget _topBar(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      child: SizedBox(
        height: size.height * 0.045,
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
            Expanded(
              child: Center(
                child: Text(
                  controller.displayTitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHeadingColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Icon(
              Icons.flag_outlined,
              color: AppColors.primaryColor,
              size: AppDimensions.iconSizeMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageList(Size size) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final hasError = controller.errorMessage.value.isNotEmpty;

      if (hasError && controller.messages.isEmpty) {
        return Column(
          children: [
            Text(
              controller.errorMessage.value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.errorColor,
              ),
            ),
            TextButton(
              onPressed: controller.fetchMessages,
              child: const Text('Coba Lagi'),
            ),
          ],
        );
      }

      final messages =
          controller.messages.isNotEmpty
              ? controller.messages
              : <ChatMessage>[];

      return ListView.separated(
        controller: controller.scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.01,
        ),
        itemCount: messages.length + (isLoading ? 1 : 0),
        separatorBuilder: (_, __) => AppDimensions.spacingLarge.sh,
        itemBuilder: (_, index) {
          if (isLoading && index == messages.length) {
            return Center(
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
            );
          }

          return _messageBubble(size, messages[index]);
        },
      );
    });
  }

  Widget _messageBubble(Size size, ChatMessage message) {
    final isMine = message.isMine;
    final bubbleColor =
        isMine ? AppColors.primaryColor : AppColors.subtleSurfaceColor;
    final textColor =
        isMine ? AppColors.whiteColor : AppColors.textHeadingColor;
    final timeText = _formatTime(message.createdAt);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: size.width * 0.72),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXLarge,
              vertical: AppDimensions.spacingLarge,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusLarge,
              ).copyWith(
                topLeft:
                    isMine
                        ? const Radius.circular(AppDimensions.radiusLarge)
                        : const Radius.circular(AppDimensions.radiusXSmall),
                topRight:
                    isMine
                        ? const Radius.circular(AppDimensions.radiusXSmall)
                        : const Radius.circular(AppDimensions.radiusLarge),
              ),
            ),
            child: Text(
              message.displayBody,
              style: AppTypography.bodySmall.copyWith(
                color: textColor,
                height: 1.35,
              ),
            ),
          ),
          if (timeText.isNotEmpty) AppDimensions.spacingXSmall.sh,
          if (timeText.isNotEmpty)
            Text(
              timeText,
              style: AppTypography.caption.copyWith(
                color: AppColors.textBodyColor.withValues(alpha: 0.7),
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
          size.width * 0.05,
          size.height * 0.01,
          size.width * 0.05,
          size.height * 0.02,
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
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
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
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Type your message...',
                    hintStyle: AppTypography.bodySmall.copyWith(
                      color: AppColors.textBodyColor.withValues(alpha: 0.55),
                    ),
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHeadingColor,
                  ),
                ),
              ),
            ),
            AppDimensions.spacingMedium.sw,
            Obx(
              () => InkWell(
                onTap:
                    controller.isSending.value ? null : controller.sendMessage,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                child: Container(
                  width: size.width * 0.12,
                  height: size.width * 0.12,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: AppColors.whiteColor,
                    size: size.width * 0.055,
                  ),
                ),
              ),
            ),
          ],
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
}
