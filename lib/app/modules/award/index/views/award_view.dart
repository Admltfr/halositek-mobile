import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controllers/award_controller.dart';

class AwardView extends GetView<AwardController> {
  const AwardView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchAwards(reset: true),
          child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(),
                18.0.sh,
                _search(size),
                18.0.sh,
                _stats(),
                14.0.sh,
                _addButton(),
                12.0.sh,
                _listHeader(),
                6.0.sh,
                _awardList(),
                36.0.sh,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          InkWell(
            onTap: controller.goBack,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 15),
            ),
          ),
          Expanded(
            child: Text(
              'Awards',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHeadingColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _search(Size size) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: size.height * 0.062,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryColor,
                  size: size.width * 0.055,
                ),
                SizedBox(width: size.width * 0.025),
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Search Award',
                      hintStyle: AppTypography.bodySmall.copyWith(
                        color: AppColors.textBodyColor.withValues(alpha: 0.55),
                      ),
                    ),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textHeadingColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stats() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _statCard(
              controller.approvedCount.toString().padLeft(2, '0'),
              'Total Approved',
              Icons.check_circle_rounded,
              AppColors.successColor,
            ),
          ),
          16.0.sw,
          Expanded(
            child: _statCard(
              controller.pendingCount.toString().padLeft(2, '0'),
              'Pending Review',
              Icons.schedule_rounded,
              AppColors.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppColors.formBorderColor.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.headingMedium.copyWith(
                    color: AppColors.textHeadingColor,
                    fontSize: 22,
                  ),
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _addButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: controller.openAdd,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add New Award',
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textWhiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
      ),
    );
  }

  Widget _listHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Your Award',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textHeadingColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.22),
            ),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedStatus.value,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
                style: AppTypography.captionLarge.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w800,
                ),
                items: const [
                  DropdownMenuItem(value: 'approved', child: Text('ACTIVE')),
                  DropdownMenuItem(
                    value: 'submission',
                    child: Text('SUBMISSION'),
                  ),
                ],
                onChanged: controller.changeStatus,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _awardList() {
    return Obx(() {
      final hasError = controller.errorMessage.value.isNotEmpty;
      final hasData = controller.hasData;

      if (hasError && !hasData) {
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
              onPressed: () => controller.fetchAwards(reset: true),
              child: const Text('Coba Lagi'),
            ),
          ],
        );
      }

      if (!controller.isLoading.value && !hasData) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: AppColors.formBorderColor.withValues(alpha: 0.24),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.inbox_rounded,
                size: 42,
                color: AppColors.textBodyColor,
              ),
              10.0.sh,
              Text(
                'Belum ada data award tersedia.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHeadingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              6.0.sh,
              Text(
                'Silakan ubah filter atau tambahkan award baru.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textBodyColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        );
      }

      final items =
          hasData ? controller.awards : List.generate(3, (_) => Award.dummy());

      return Skeletonizer(
        enabled: controller.isLoading.value && !hasData,
        child: Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => 16.0.sh,
              itemBuilder: (_, index) => _awardCard(items[index]),
            ),
            if (controller.isLoadingMore.value)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
          ],
        ),
      );
    });
  }

  Widget _awardCard(Award award) {
    final approved = award.isApproved;

    return InkWell(
      onTap: () => controller.openDetail(award),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: AppColors.formBorderColor.withValues(alpha: 0.24),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: approved ? 96 : 72,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              clipBehavior: Clip.antiAlias,
              child: _awardImage(award),
            ),
            16.0.sw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusPill(award.status),
                  6.0.sh,
                  Text(
                    award.name,
                    maxLines: approved ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textHeadingColor,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  6.0.sh,
                  Text(
                    award.projectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textBodyColor,
                    ),
                  ),
                  8.0.sh,
                  Text(
                    'Submitted ${_formatDate(award.createdAt)}',
                    style: AppTypography.captionLarge.copyWith(
                      color: AppColors.textBodyColor.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.north_east_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _awardImage(Award award) {
    final url = _awardImageUrl(award);
    if (url.isEmpty) return _awardImageFallback();

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _awardImageFallback(),
    );
  }

  Widget _awardImageFallback() {
    return const Center(
      child: Icon(
        Icons.workspace_premium_outlined,
        color: AppColors.primaryColor,
        size: 34,
      ),
    );
  }

  String _awardImageUrl(Award award) {
    final path = award.verificationFileUrl.trim();
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;

    final baseUrl = (dotenv.env['BASEURL'] ?? '').trim();
    if (baseUrl.isEmpty) return path;

    final normalizedBase =
        baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return '$normalizedBase/$normalizedPath';
  }

  Widget _statusPill(String status) {
    final normalized = status.toLowerCase();
    final approved = normalized == 'approved';
    final declined = normalized == 'declined';
    final background =
        approved
            ? AppColors.successColor
            : (declined ? AppColors.errorColor : AppColors.warningColor);
    final label = approved ? 'APPROVED' : (declined ? 'DECLINED' : 'PENDING');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
      ),
      child: Text(
        label,
        style: AppTypography.captionLarge.copyWith(
          color: background,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }
}
