import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/user.dart';
import 'package:halositek/app/modules/profile/controllers/profile_controller.dart';
import 'package:halositek/app/modules/profile/widgets/profile_common_widgets.dart';
import 'package:halositek/app/modules/profile/widgets/profile_top_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserProfileView extends StatelessWidget {
  final ProfileController controller;

  const UserProfileView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      floatingActionButton: const ProfileFab(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.01),
            child: Obx(() {
              final isLoading = controller.isLoading.value;
              final user = controller.user.value ?? _dummyUser();

              if (controller.errorMessage.value.isNotEmpty && controller.user.value == null) {
                return Column(
                  children: [
                    ProfileTopBar(title: 'Your Profile', onBack: controller.goBack, onLogout: controller.logout),
                    80.0.sh,
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.errorColor),
                    ),
                    TextButton(onPressed: controller.fetchUser, child: const Text('Coba Lagi')),
                  ],
                );
              }

              return Skeletonizer(
                enabled: isLoading,
                child: AbsorbPointer(
                  absorbing: isLoading,
                  child: Column(
                    children: [
                      ProfileTopBar(title: 'Your Profile', onBack: controller.goBack, onLogout: controller.logout),
                      12.0.sh,
                      _UserHeader(user: user, onEdit: controller.openEditProfile),
                      24.0.sh,
                      _PersonalData(user: user),
                      24.0.sh,
                      _SectionTitle(title: 'Saved Architect', onViewAll: controller.openSavedArchitects),
                      14.0.sh,
                      _SavedArchitectPreview(items: isLoading ? _dummySavedArchitects : controller.savedArchitects),
                      24.0.sh,
                      _SectionTitle(title: 'Saved Design', onViewAll: controller.openSavedDesigns),
                      14.0.sh,
                      _SavedDesignPreview(items: isLoading ? _dummySavedProjects : controller.savedProjects),
                      24.0.sh,
                      _SectionTitle(title: 'Consultation Payment History', onViewAll: controller.openPaymentHistory),
                      14.0.sh,
                      _PaymentPreview(items: isLoading ? _dummyPayments : controller.paymentHistories),
                      24.0.sh,
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: controller.logout,
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: Text('LOGOUT', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: AppColors.whiteColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                          ),
                        ),
                      ),
                      16.0.sh,
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

UserProfile _dummyUser() {
  return const UserProfile(
    id: 'loading-user',
    name: 'Muhammad User',
    email: 'user@example.com',
    role: 'user',
    accountStatus: 'active',
    photoProfileUrl: '',
    createdAt: null,
    updatedAt: null,
    savedProjects: <SavedProject>[],
    savedArchitects: <SavedArchitect>[],
    paymentHistories: <PaymentHistory>[],
  );
}

const _dummySavedArchitects = <SavedArchitect>[
  SavedArchitect(
    id: 'loading-architect-1',
    name: 'Architect Name',
    photoProfileUrl: '',
    architectProfile: SavedArchitectProfile(id: '', bio: 'Residential Specialist', location: 'Jakarta'),
    totalProjects: 0,
    totalAwards: 0,
  ),
  SavedArchitect(
    id: 'loading-architect-2',
    name: 'Architect Name',
    photoProfileUrl: '',
    architectProfile: SavedArchitectProfile(id: '', bio: 'Interior Designer', location: 'Bandung'),
    totalProjects: 0,
    totalAwards: 0,
  ),
  SavedArchitect(
    id: 'loading-architect-3',
    name: 'Architect Name',
    photoProfileUrl: '',
    architectProfile: SavedArchitectProfile(id: '', bio: 'Modern Design', location: 'Surabaya'),
    totalProjects: 0,
    totalAwards: 0,
  ),
];

const _dummySavedProjects = <SavedProject>[
  SavedProject(
    id: 'loading-project-1',
    title: 'Modern House',
    style: 'modern',
    imageUrl: '',
    architect: UserArchitectSummary(id: '', name: '', photoProfileUrl: ''),
  ),
  SavedProject(
    id: 'loading-project-2',
    title: 'Classic Villa',
    style: 'classic',
    imageUrl: '',
    architect: UserArchitectSummary(id: '', name: '', photoProfileUrl: ''),
  ),
];

const _dummyPayments = <PaymentHistory>[
  PaymentHistory(
    id: 'loading-payment-1',
    orderId: '',
    status: 'paid',
    refundStatus: '',
    amount: 250000,
    taxAmount: 0,
    totalPaidAmount: 250000,
    durationHours: 1,
    paymentMethod: '',
    paidAt: null,
    createdAt: null,
    consultationId: '',
    conversationId: '',
    architect: UserArchitectSummary(id: '', name: 'Architect Name', photoProfileUrl: ''),
  ),
  PaymentHistory(
    id: 'loading-payment-2',
    orderId: '',
    status: 'paid',
    refundStatus: '',
    amount: 250000,
    taxAmount: 0,
    totalPaidAmount: 250000,
    durationHours: 1,
    paymentMethod: '',
    paidAt: null,
    createdAt: null,
    consultationId: '',
    conversationId: '',
    architect: UserArchitectSummary(id: '', name: 'Architect Name', photoProfileUrl: ''),
  ),
];

class _UserHeader extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onEdit;

  const _UserHeader({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 138,
              height: 138,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondaryColor.withValues(alpha: 0.28), width: 4),
              ),
              child: ClipOval(
                child:
                    user.photoProfileUrl.isNotEmpty
                        ? Image.network(
                          user.photoProfileUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(profileFallbackImage, fit: BoxFit.cover),
                        )
                        : Image.asset(profileFallbackImage, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 6,
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(color: AppColors.whiteColor, width: 3),
                  ),
                  child: const Icon(Icons.edit_square, color: AppColors.whiteColor, size: 18),
                ),
              ),
            ),
          ],
        ),
        18.0.sh,
        Text(
          user.name.isNotEmpty ? user.name : '-',
          textAlign: TextAlign.center,
          style: AppTypography.headingMedium.copyWith(
            fontSize: 20,
            color: AppColors.textHeadingColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _PersonalData extends StatelessWidget {
  final UserProfile user;

  const _PersonalData({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Data',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textBodyColor, fontWeight: FontWeight.w800),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              16.0.sh,
              _DataRow(label: 'USERNAME', value: user.name),
              16.0.sh,
              _DataRow(label: 'EMAIL', value: user.email, action: 'CHANGE'),
              16.0.sh,
              const _DataRow(label: 'PASSWORD', value: '************', action: 'CHANGE'),
            ],
          ),
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final String? action;

  const _DataRow({required this.label, required this.value, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.captionLarge.copyWith(
                  color: AppColors.textBodyColor.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w800,
                ),
              ),
              6.0.sh,
              Text(
                value.isNotEmpty ? value : '-',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: AppTypography.captionLarge.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w800),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionTitle({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textBodyColor, fontWeight: FontWeight.w800),
          ),
        ),
        InkWell(
          onTap: onViewAll,
          child: Text(
            'VIEW ALL',
            style: AppTypography.captionLarge.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _SavedArchitectPreview extends StatelessWidget {
  final List<SavedArchitect> items;

  const _SavedArchitectPreview({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const ProfileEmptyState(message: 'Belum ada saved architect.');
    }

    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.take(4).length,
        separatorBuilder: (_, __) => 12.0.sw,
        itemBuilder: (_, index) => SizedBox(width: 72, child: SavedArchitectCard(architect: items[index], compact: true)),
      ),
    );
  }
}

class _SavedDesignPreview extends StatelessWidget {
  final List<SavedProject> items;

  const _SavedDesignPreview({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const ProfileEmptyState(message: 'Belum ada saved design.');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.take(2).length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 18,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, index) => SavedDesignCard(project: items[index]),
    );
  }
}

class _PaymentPreview extends StatelessWidget {
  final List<PaymentHistory> items;

  const _PaymentPreview({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const ProfileEmptyState(message: 'Belum ada payment history.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.take(3).length,
      separatorBuilder: (_, __) => 10.0.sh,
      itemBuilder: (_, index) => PaymentHistoryCard(payment: items[index]),
    );
  }
}
