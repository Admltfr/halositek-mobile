import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:halositek/app/data/network/api_client.dart';
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
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.01),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(size),
              AppDimensions.spacingXLarge.sh,
              _searchBar(size),
              AppDimensions.spacingXLarge.sh,
              _sectionHeader(size),
              _dropdownPanel(size),
              AppDimensions.spacingLarge.sh,
              Expanded(child: _contentList(size)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar (no dropdown – just back + title) ──────────────────────
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
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          // Spacer to balance the back button
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────
  Widget _searchBar(Size size) {
    return Container(
      height: size.height * 0.062,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.primaryColor, size: size.width * 0.055),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search user',
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.55)),
              ),
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header with dropdown ───────────────────────────────────
  Widget _sectionHeader(Size size) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Text(
              'Your Chat',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
            ),
          ),
          _tabDropdownButton(size),
        ],
      ),
    );
  }

  /// Dropdown button styled like _statusFilter from design_view
  Widget _tabDropdownButton(Size size) {
    final isConsultation = controller.selectedTab.value == ChatListController.tabConsultation;
    final label = isConsultation ? 'CONSULTATION' : 'REPORT';

    return GestureDetector(
      onTap: controller.toggleDropdown,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.captionLarge.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 4),
            Icon(
              controller.isDropdownOpen.value ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  /// Dropdown panel (appears below header when open)
  Widget _dropdownPanel(Size size) {
    return Obx(() {
      if (!controller.isDropdownOpen.value) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(top: size.height * 0.01),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.formBorderColor.withValues(alpha: 0.20)),
            boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: Column(
            children: [
              _dropdownItem(label: 'Consultation', value: ChatListController.tabConsultation),
              _dropdownItem(label: 'Report', value: ChatListController.tabReport),
            ],
          ),
        ),
      );
    });
  }

  Widget _dropdownItem({required String label, required String value}) {
    final selected = controller.selectedTab.value == value;
    return InkWell(
      onTap: () => controller.changeTab(value),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: selected ? AppColors.secondaryColor.withValues(alpha: 0.16) : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: selected ? AppColors.primaryColor : AppColors.textHeadingColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primaryColor, size: 16),
          ],
        ),
      ),
    );
  }

  // ── Content (switches between consultation list and report list) ───
  Widget _contentList(Size size) {
    return Obx(() {
      if (controller.selectedTab.value == ChatListController.tabReport) {
        return _reportList(size);
      }
      return _chatList(size);
    });
  }

  // ── Consultation chat list ─────────────────────────────────────────
  Widget _chatList(Size size) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final hasError = controller.errorMessage.value.isNotEmpty;

      if (hasError && controller.conversations.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.errorMessage.value, style: AppTypography.bodySmall.copyWith(color: AppColors.errorColor)),
            TextButton(onPressed: controller.fetchConversations, child: const Text('Coba Lagi')),
          ],
        );
      }

      final data = controller.conversations;
      final showLoadingMore = controller.isLoadingMoreConversations.value;

      return Skeletonizer(
        enabled: isLoading && controller.conversations.isEmpty,
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primaryColor,
          child: ListView.separated(
            controller: controller.conversationsScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.isEmpty && isLoading ? 6 : (data.isEmpty ? 1 : data.length + (showLoadingMore ? 1 : 0)),
            separatorBuilder: (_, __) => const Divider(height: AppDimensions.spacing2XLarge, color: Color(0xFFF1F1F1)),
            itemBuilder: (_, index) {
              if (data.isEmpty && !isLoading) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: Center(
                    child: Text(
                      'Chat not found',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor.withValues(alpha: 0.6)),
                    ),
                  ),
                );
              }

              if (index == data.length && showLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                );
              }

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
                    createdAt: null,
                    durationHours: 0,
                    status: '',
                    consultationId: '',
                  ),
                );
              }

              return _chatTile(size, data[index]);
            },
          ),
        ),
      );
    });
  }

  Widget _chatTile(Size size, ChatConversation conversation) {
    final timeText = _formatTime(conversation.lastActivityAt);

    String? displayImageUrl;

    if (controller.isArchitect.value) {
      if (conversation.user?.photoProfile != null && conversation.user!.photoProfile!.isNotEmpty) {
        if (conversation.user!.photoProfile!.startsWith('http')) {
          displayImageUrl = conversation.user!.photoProfile;
        } else {
          final base = ApiClient.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? '';
          displayImageUrl = '$base/storage/${conversation.user!.photoProfile}';
        }
      }
    } else {
      if (conversation.architect?.profilePicture != null && conversation.architect!.profilePicture!.isNotEmpty) {
        if (conversation.architect!.profilePicture!.startsWith('http')) {
          displayImageUrl = conversation.architect!.profilePicture;
        } else {
          final base = ApiClient.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? '';
          displayImageUrl = '$base/storage/${conversation.architect!.profilePicture}';
        }
      }
    }

    String displayName;
    if (controller.isArchitect.value == false) {
      if (conversation.architect?.name != null && conversation.architect!.name.isNotEmpty) {
        displayName = conversation.architect!.name;
      } else {
        displayName = 'Architect';
      }
    } else {
      if (conversation.user?.name != null && conversation.user!.name.isNotEmpty) {
        displayName = conversation.user!.name;
      } else {
        displayName = 'User';
      }
    }

    return InkWell(
      onTap: () => controller.openConversation(conversation),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSmall),
        child: Row(
          children: [
            _buildAvatar(size, displayImageUrl),
            AppDimensions.spacingLarge.sw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (conversation.canSendMessage) ...[
                        4.0.sw,
                        Icon(
                          Icons.access_time_filled_rounded,
                          size: 14,
                          color: AppColors.primaryColor.withValues(alpha: 0.8),
                        ),
                      ],
                    ],
                  ),
                  AppDimensions.spacingXSmall.sh,
                  Obx(() {
                    final isTyping = controller.typingConversations[conversation.id] ?? false;
                    if (isTyping) {
                      return Text(
                        'typing...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }
                    return Text(
                      conversation.lastMessagePreview.isNotEmpty ? conversation.lastMessagePreview : 'No messages yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.8)),
                    );
                  }),
                ],
              ),
            ),
            AppDimensions.spacingMedium.sw,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (timeText.isNotEmpty)
                  Text(
                    timeText,
                    style: AppTypography.caption.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.7)),
                  ),
                if (conversation.unreadCount > 0) ...[
                  AppDimensions.spacingXSmall.sh,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSmall,
                      vertical: AppDimensions.spacingExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                    child: Text(
                      conversation.unreadCount.toString(),
                      style: AppTypography.caption.copyWith(color: AppColors.whiteColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Report list ────────────────────────────────────────────────────
  Widget _reportList(Size size) {
    return Obx(() {
      final isLoading = controller.isLoadingReports.value;
      final hasError = controller.errorReports.value.isNotEmpty;

      if (hasError && controller.reports.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.errorReports.value, style: AppTypography.bodySmall.copyWith(color: AppColors.errorColor)),
            TextButton(onPressed: controller.fetchReports, child: const Text('Coba Lagi')),
          ],
        );
      }

      final data = controller.reports;
      final showLoadingMore = controller.isLoadingMoreReports.value;

      return Skeletonizer(
        enabled: isLoading && controller.reports.isEmpty,
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primaryColor,
          child: ListView.separated(
            controller: controller.reportsScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.isEmpty && isLoading ? 6 : (data.isEmpty ? 1 : data.length + (showLoadingMore ? 1 : 0)),
            separatorBuilder: (_, __) => const Divider(height: AppDimensions.spacing2XLarge, color: Color(0xFFF1F1F1)),
            itemBuilder: (_, index) {
              if (data.isEmpty && !isLoading) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: Center(
                    child: Text(
                      'No report found',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor.withValues(alpha: 0.6)),
                    ),
                  ),
                );
              }

              if (index == data.length && showLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                );
              }

              if (data.isEmpty) {
                return _reportTileSkeleton(size);
              }
              return _reportTile(size, data[index]);
            },
          ),
        ),
      );
    });
  }

  Widget _reportTileSkeleton(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSmall),
      child: Row(
        children: [
          CircleAvatar(
            radius: size.width * 0.065,
            backgroundColor: AppColors.whiteColor,
            child: ClipOval(
              child: Image.asset(_dummyAvatar, width: size.width * 0.13, height: size.width * 0.13, fit: BoxFit.cover),
            ),
          ),
          AppDimensions.spacingLarge.sw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loading...',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
                ),
                AppDimensions.spacingXSmall.sh,
                Text(
                  'Loading reason...',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportTile(Size size, ChatReport report) {
    final status = report.actionReport.toLowerCase();
    final isApprovedOrDeclined = status == 'approved' || status == 'declined';
    final timeText = _formatTime(report.updatedAt ?? report.consultationDate);

    String? displayImageUrl;

    if (report.opposingParty.photoProfileUrl != null && report.opposingParty.photoProfileUrl!.isNotEmpty) {
      if (report.opposingParty.photoProfileUrl!.startsWith('http')) {
        displayImageUrl = report.opposingParty.photoProfileUrl;
      } else {
        final base = ApiClient.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? '';
        displayImageUrl = '$base${report.opposingParty.photoProfileUrl}';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSmall),
      child: Row(
        children: [
          _buildAvatar(size, displayImageUrl),
          AppDimensions.spacingLarge.sw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w700),
                ),
                AppDimensions.spacingXSmall.sh,
                Text(
                  report.reasonPreview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          AppDimensions.spacingMedium.sw,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isApprovedOrDeclined)
                _statusBadge('pending')
              else ...[
                _statusBadge(status),
                if (timeText.isNotEmpty) ...[
                  AppDimensions.spacingXSmall.sh,
                  Text(timeText, style: AppTypography.caption.copyWith(color: AppColors.textBodyColor.withValues(alpha: 0.7))),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Status badge for report cards ──────────────────────────────────
  Widget _statusBadge(String status) {
    Color color;
    String label;
    bool outlined;

    switch (status) {
      case 'approved':
        color = AppColors.successColor;
        label = 'APPROVE';
        outlined = false;
        break;
      case 'declined':
        color = AppColors.errorColor;
        label = 'DECLINED';
        outlined = true;
        break;
      case 'pending':
        color = AppColors.warningColor;
        label = 'PENDING';
        outlined = true;
        break;
      default:
        color = AppColors.textBodyColor;
        label = status.toUpperCase();
        outlined = true;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLarge, vertical: AppDimensions.spacingXSmall),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.12),
        border: outlined ? Border.all(color: color.withValues(alpha: 0.4)) : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: AppTypography.captionLarge.copyWith(color: color, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildAvatar(Size size, String? imageUrl) {
    return CircleAvatar(
      radius: size.width * 0.065,
      backgroundColor: AppColors.whiteColor,
      child: ClipOval(
        child:
            imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                  imageUrl,
                  width: size.width * 0.13,
                  height: size.width * 0.13,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) =>
                          Image.asset(_dummyAvatar, width: size.width * 0.13, height: size.width * 0.13, fit: BoxFit.cover),
                )
                : Image.asset(_dummyAvatar, width: size.width * 0.13, height: size.width * 0.13, fit: BoxFit.cover),
      ),
    );
  }

  // ── Time formatter ─────────────────────────────────────────────────
  String _formatTime(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(local.year, local.month, local.day);

    if (dateOnly == today) {
      final hour = local.hour;
      final minute = local.minute;
      final h = hour % 12 == 0 ? 12 : hour % 12;
      final suffix = hour >= 12 ? 'PM' : 'AM';
      final mm = minute.toString().padLeft(2, '0');
      return '${h.toString().padLeft(2, '0')}:$mm $suffix';
    }

    final diff = today.difference(dateOnly).inDays;
    if (diff == 1) return 'Yesterday';
    if (diff < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[local.weekday - 1];
    }

    return '${local.day}/${local.month}/${local.year}';
  }
}
