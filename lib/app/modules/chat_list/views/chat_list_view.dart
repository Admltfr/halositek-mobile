import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/chat_list_controller.dart';

class ChatListView extends GetView<ChatListController> {
  const ChatListView({super.key});

  static const String _dummyAvatar = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(size),
              AppDimensions.spacingXLarge.sh,
              _searchBar(size),
              AppDimensions.spacingXLarge.sh,
              Expanded(child: _chatList(size)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(Size size) {
    return SizedBox(
      height: size.height * 0.04,
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
                'Your Chats',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHeadingColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.height * 0.005,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            child: Row(
              children: [
                Text(
                  'Consultation',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primaryColor,
                  size: AppDimensions.iconSizeMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(Size size) {
    return Container(
      height: size.height * 0.062,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: AppColors.formBorderColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppColors.primaryColor,
            size: size.width * 0.055,
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search user',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textBodyColor.withValues(alpha: 0.55),
                ),
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHeadingColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatList(Size size) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final hasError = controller.errorMessage.value.isNotEmpty;

      if (hasError && controller.conversations.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.errorMessage.value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.errorColor,
              ),
            ),
            TextButton(
              onPressed: controller.fetchConversations,
              child: const Text('Coba Lagi'),
            ),
          ],
        );
      }

      final data =
          controller.filteredConversations.isNotEmpty
              ? controller.filteredConversations
              : <ChatConversation>[];

      return Skeletonizer(
        enabled: isLoading && controller.conversations.isEmpty,
        child: ListView.separated(
          itemCount: data.isEmpty && isLoading ? 6 : data.length,
          separatorBuilder: (_, __) => AppDimensions.spacingLarge.sh,
          itemBuilder: (_, index) {
            if (data.isEmpty) {
              return _chatTile(
                size,
                ChatConversation(
                  id: '',
                  name: 'Loading...',
                  isGroup: false,
                  participantIds: const [],
                  lastReadAt: null,
                  unreadCount: 0,
                  lastMessage: null,
                  updatedAt: null,
                ),
              );
            }

            return _chatTile(size, data[index]);
          },
        ),
      );
    });
  }

  Widget _chatTile(Size size, ChatConversation conversation) {
    final timeText = _formatTime(conversation.lastActivityAt);

    return InkWell(
      onTap: () => controller.openConversation(conversation),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Row(
        children: [
          CircleAvatar(
            radius: size.width * 0.065,
            backgroundColor: AppColors.whiteColor,
            child: ClipOval(
              child: Image.asset(
                _dummyAvatar,
                width: size.width * 0.13,
                height: size.width * 0.13,
                fit: BoxFit.cover,
              ),
            ),
          ),
          AppDimensions.spacingLarge.sw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHeadingColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppDimensions.spacingXSmall.sh,
                Text(
                  conversation.lastMessagePreview.isNotEmpty
                      ? conversation.lastMessagePreview
                      : 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textBodyColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (timeText.isNotEmpty)
                Text(
                  timeText,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textBodyColor.withValues(alpha: 0.7),
                  ),
                ),
              AppDimensions.spacingXSmall.sh,
              if (conversation.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSmall,
                    vertical: AppDimensions.spacingExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusPill,
                    ),
                  ),
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
