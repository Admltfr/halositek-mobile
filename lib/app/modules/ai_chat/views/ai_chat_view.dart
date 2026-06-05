import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/chat.dart';
import '../controllers/ai_chat_controller.dart';

class AiChatView extends GetView<AiChatController> {
  const AiChatView({super.key});

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
            blurRadius: 10,
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
          // AI Robot Profile Pic with Gradient Background
          Container(
            width: size.width * 0.1,
            height: size.width * 0.1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: AppColors.whiteColor,
              size: size.width * 0.052,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sitek AI Assistant',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHeadingColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.successColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Online & Siap Membantu',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textBodyColor.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Premium badge label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            child: Text(
              'BETA',
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageList(Size size) {
    return Obx(() {
      final messages = controller.messages;
      final isThinking = controller.isAiThinking.value;

      return ListView.separated(
        controller: controller.scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.02,
        ),
        itemCount: messages.length + (isThinking ? 1 : 0),
        separatorBuilder: (_, __) => AppDimensions.spacingLarge.sh,
        itemBuilder: (_, index) {
          if (isThinking && index == messages.length) {
            return _thinkingBubble(size);
          }

          final msg = messages[index];
          final isMine = msg.isMine;

          // If the welcome message is showing and no user message has been sent,
          // render suggestions below it.
          if (index == 0 && messages.length == 1) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _aiBubbleLayout(size, msg.displayBody, msg.createdAt),
                AppDimensions.spacing5XLarge.sh,
                _suggestionsHeader(),
                AppDimensions.spacingMedium.sh,
                _suggestionsGrid(size),
              ],
            );
          }

          return isMine
              ? _userBubbleLayout(size, msg.displayBody, msg.createdAt)
              : _aiBubbleLayout(size, msg.displayBody, msg.createdAt);
        },
      );
    });
  }

  Widget _userBubbleLayout(Size size, String text, DateTime? time) {
    final timeText = _formatTime(time);

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: size.width * 0.75),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXLarge,
              vertical: AppDimensions.spacingLarge,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radius2XLarge),
                topRight: Radius.circular(AppDimensions.radiusXSmall),
                bottomLeft: Radius.circular(AppDimensions.radius2XLarge),
                bottomRight: Radius.circular(AppDimensions.radius2XLarge),
              ),
            ),
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.whiteColor,
                height: 1.4,
              ),
            ),
          ),
          if (timeText.isNotEmpty) AppDimensions.spacingXSmall.sh,
          if (timeText.isNotEmpty)
            Text(
              timeText,
              style: AppTypography.caption.copyWith(
                color: AppColors.textBodyColor.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _aiBubbleLayout(Size size, String text, DateTime? time) {
    final timeText = _formatTime(time);

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small AI avatar
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: size.width * 0.08,
            height: size.width * 0.08,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: AppColors.whiteColor,
              size: size.width * 0.042,
            ),
          ),
          SizedBox(width: size.width * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: size.width * 0.72),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXLarge,
                    vertical: AppDimensions.spacingLarge,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.subtleSurfaceColor.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusXSmall),
                      topRight: Radius.circular(AppDimensions.radius2XLarge),
                      bottomLeft: Radius.circular(AppDimensions.radius2XLarge),
                      bottomRight: Radius.circular(AppDimensions.radius2XLarge),
                    ),
                  ),
                  child: Text(
                    text,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textHeadingColor,
                      height: 1.45,
                    ),
                  ),
                ),
                if (timeText.isNotEmpty) AppDimensions.spacingXSmall.sh,
                if (timeText.isNotEmpty)
                  Text(
                    timeText,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textBodyColor.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thinkingBubble(Size size) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: size.width * 0.08,
            height: size.width * 0.08,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: AppColors.whiteColor,
              size: size.width * 0.042,
            ),
          ),
          SizedBox(width: size.width * 0.025),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXLarge,
              vertical: AppDimensions.spacingLarge,
            ),
            decoration: BoxDecoration(
              color: AppColors.subtleSurfaceColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusXSmall),
                topRight: Radius.circular(AppDimensions.radius2XLarge),
                bottomLeft: Radius.circular(AppDimensions.radius2XLarge),
                bottomRight: Radius.circular(AppDimensions.radius2XLarge),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BouncingDots(),
                SizedBox(width: 8),
                Text(
                  'Sitek AI sedang berpikir...',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textBodyColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionsHeader() {
    return Row(
      children: [
        const Icon(
          Icons.lightbulb_outline_rounded,
          color: AppColors.primaryColor,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          'Rekomendasi Pertanyaan:',
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textHeadingColor,
          ),
        ),
      ],
    );
  }

  Widget _suggestionsGrid(Size size) {
    return Column(
      children: controller.suggestions.map((suggestion) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.selectSuggestion(suggestion),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.04),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.12),
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        suggestion,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHeadingColor,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primaryColor,
                      size: AppDimensions.iconSizeSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
          size.height * 0.02,
        ),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border(
            top: BorderSide(
              color: AppColors.formBorderColor.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  border: Border.all(
                    color: AppColors.formBorderColor.withValues(alpha: 0.3),
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
                    hintText: 'Tanyakan ide arsitektur / estimasi...',
                    hintStyle: AppTypography.bodySmall.copyWith(
                      color: AppColors.textBodyColor.withValues(alpha: 0.5),
                    ),
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHeadingColor,
                  ),
                ),
              ),
            ),
            AppDimensions.spacingMedium.sw,
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.sendMessage(),
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                child: Container(
                  width: size.width * 0.11,
                  height: size.width * 0.11,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: AppColors.whiteColor,
                    size: size.width * 0.05,
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

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double delay = index * 0.2;
            double value = _controller.value - delay;
            if (value < 0) value += 1.0;
            // Map 0..1 to smooth sine wave bounce
            final double bounce = math.sin(value * 2 * 3.14159);
            final double offset = bounce * 3.0; // Translate up and down by 3 pixels

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              transform: Matrix4.translationValues(0, offset, 0),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
