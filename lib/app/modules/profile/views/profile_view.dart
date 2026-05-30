import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/models/architect_earnings.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static const String _fallbackImage = 'assets/images/bg-image.png';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isReady.value) {
        return const Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: SafeArea(child: Center(child: CircularProgressIndicator())),
        );
      }

      return controller.isArchitect
          ? _ArchitectProfile(controller: controller)
          : _UserProfile(controller: controller);
    });
  }
}

class _ArchitectProfile extends StatelessWidget {
  final ProfileController controller;

  const _ArchitectProfile({required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
        child: const Icon(Icons.business_center_outlined),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.01,
            ),
            child: Obx(() {
              final architect = controller.architect.value;
              final hasError = controller.errorMessage.value.isNotEmpty;

              if (hasError && architect == null) {
                return Column(
                  children: [
                    _TopBar(controller: controller),
                    80.0.sh,
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.errorColor,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.fetchArchitect,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                );
              }

              final profile = architect ?? Architect.dummy();

              return Column(
                children: [
                  _TopBar(controller: controller),
                  12.0.sh,
                  _Header(
                    architect: profile,
                    onEdit: controller.openEditProfile,
                  ),
                  24.0.sh,
                  _Stats(architect: profile),
                  24.0.sh,
                  _FeeButton(architect: profile),
                  26.0.sh,
                  _Tabs(controller: controller),
                  18.0.sh,
                  _TabBody(controller: controller),
                  24.0.sh,
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final ProfileController controller;

  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
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
              'Your Profile',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHeadingColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: controller.logout,
            icon: const Icon(Icons.logout_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Architect architect;
  final VoidCallback onEdit;

  const _Header({required this.architect, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (architect.headline.isNotEmpty) architect.headline,
      if (architect.specialization.isNotEmpty) architect.specialization,
    ].join(' | ');

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
                border: Border.all(
                  color: AppColors.secondaryColor.withValues(alpha: 0.28),
                  width: 4,
                ),
              ),
              child: ClipOval(
                child:
                    architect.profilePicture.isNotEmpty
                        ? Image.network(
                          architect.profilePicture,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Image.asset(
                                ProfileView._fallbackImage,
                                fit: BoxFit.cover,
                              ),
                        )
                        : Image.asset(
                          ProfileView._fallbackImage,
                          fit: BoxFit.cover,
                        ),
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
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                    border: Border.all(color: AppColors.whiteColor, width: 3),
                  ),
                  child: const Icon(
                    Icons.edit_square,
                    color: AppColors.whiteColor,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        22.0.sh,
        Text(
          architect.name.isNotEmpty ? architect.name : '-',
          textAlign: TextAlign.center,
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.textHeadingColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        4.0.sh,
        Text(
          subtitle.isNotEmpty ? subtitle : 'Architect',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        14.0.sh,
        Text(
          architect.bio.isNotEmpty
              ? architect.bio
              : 'Lengkapi bio untuk menampilkan ringkasan keahlian dan pengalaman arsitektur Anda.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textBodyColor,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  final Architect architect;

  const _Stats({required this.architect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: architect.totalProjects.toString(),
            label: 'PROJECTS',
          ),
        ),
        12.0.sw,
        Expanded(
          child: _StatCard(
            value: architect.totalAwards.toString(),
            label: 'AWARDS',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTypography.headingSmall.copyWith(
              color: AppColors.primaryColor,
              fontSize: 21,
            ),
          ),
          5.0.sh,
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textBodyColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeButton extends StatelessWidget {
  final Architect architect;

  const _FeeButton({required this.architect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_formatCurrency(architect.consultationFee)} / hour',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: AppColors.whiteColor),
          22.0.sw,
          Text(
            'Your Fee',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.whiteColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final ProfileController controller;

  const _Tabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _tab('Portfolio', ProfileTab.portfolio),
          _tab('Award', ProfileTab.award),
          _tab('Earnings', ProfileTab.earnings),
        ],
      ),
    );
  }

  Widget _tab(String label, ProfileTab tab) {
    final active = controller.selectedTab.value == tab;
    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTab(tab),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color:
                    active ? AppColors.primaryColor : AppColors.textBodyColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            12.0.sh,
            Container(
              height: 2,
              color: active ? AppColors.primaryColor : AppColors.accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  final ProfileController controller;

  const _TabBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.selectedTab.value) {
        case ProfileTab.portfolio:
          return _PortfolioGrid(projects: controller.projects);
        case ProfileTab.award:
          return _AwardGrid(awards: controller.awards);
        case ProfileTab.earnings:
          return _EarningsList(controller: controller);
      }
    });
  }
}

class _PortfolioGrid extends StatelessWidget {
  final List<ArchitectProject> projects;

  const _PortfolioGrid({required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const _EmptyState(message: 'Belum ada portfolio.');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 18,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, index) => _ProjectCard(project: projects[index]),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ArchitectProject project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final images =
        project.imageUrls.isNotEmpty ? project.imageUrls : project.images;

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
                      images.isNotEmpty
                          ? Image.network(
                            images.first,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Image.asset(
                                  ProfileView._fallbackImage,
                                  fit: BoxFit.cover,
                                ),
                          )
                          : Image.asset(
                            ProfileView._fallbackImage,
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.whiteColor.withValues(alpha: 0.88),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: AppColors.textHeadingColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        8.0.sh,
        Text(
          project.name.isNotEmpty ? project.name : '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHeadingColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        3.0.sh,
        Row(
          children: [
            const Icon(
              Icons.favorite_border_rounded,
              size: 20,
              color: AppColors.textBodyColor,
            ),
            5.0.sw,
            Text(
              project.likesCount.toString(),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textBodyColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AwardGrid extends StatelessWidget {
  final List<ArchitectAward> awards;

  const _AwardGrid({required this.awards});

  @override
  Widget build(BuildContext context) {
    if (awards.isEmpty) return const _EmptyState(message: 'Belum ada award.');

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: awards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 22,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, index) => _AwardCard(award: awards[index]),
    );
  }
}

class _AwardCard extends StatelessWidget {
  final ArchitectAward award;

  const _AwardCard({required this.award});

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
                      award.verificationFileUrl.isNotEmpty
                          ? Image.network(
                            award.verificationFileUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Image.asset(
                                  ProfileView._fallbackImage,
                                  fit: BoxFit.cover,
                                ),
                          )
                          : Image.asset(
                            ProfileView._fallbackImage,
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.whiteColor.withValues(alpha: 0.88),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: AppColors.textHeadingColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        8.0.sh,
        Text(
          award.name.isNotEmpty ? award.name : '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHeadingColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        4.0.sh,
        Text(
          _formatDate(award.awardDate),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textBodyColor,
          ),
        ),
      ],
    );
  }
}

class _EarningsList extends StatelessWidget {
  final ProfileController controller;

  const _EarningsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.earnings.value;

    if (controller.earningsError.value.isNotEmpty && data.earnings.isEmpty) {
      return Column(
        children: [
          Text(
            controller.earningsError.value,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.errorColor,
            ),
          ),
          TextButton(
            onPressed: controller.fetchEarnings,
            child: const Text('Coba Lagi'),
          ),
        ],
      );
    }

    if (data.earnings.isEmpty) {
      return const _EmptyState(message: 'Belum ada earnings.');
    }

    return Column(
      children: [
        _EarningSummary(data: data),
        14.0.sh,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.earnings.length,
          separatorBuilder: (_, __) => 10.0.sh,
          itemBuilder: (_, index) => _EarningCard(item: data.earnings[index]),
        ),
      ],
    );
  }
}

class _EarningSummary extends StatelessWidget {
  final ArchitectEarnings data;

  const _EarningSummary({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniSummary(
            label: 'Gross',
            value: _formatCurrency(data.totalGrossEarnings),
          ),
        ),
        8.0.sw,
        Expanded(
          child: _MiniSummary(
            label: 'Tax',
            value: _formatCurrency(data.totalTaxPaid),
          ),
        ),
        8.0.sw,
        Expanded(
          child: _MiniSummary(
            label: 'Net',
            value: _formatCurrency(data.totalNetEarnings),
          ),
        ),
      ],
    );
  }
}

class _MiniSummary extends StatelessWidget {
  final String label;
  final String value;

  const _MiniSummary({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        color: AppColors.primaryColor.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.captionLarge.copyWith(
              color: AppColors.textBodyColor,
            ),
          ),
          4.0.sh,
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.captionLarge.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningCard extends StatelessWidget {
  final ArchitectEarningItem item;

  const _EarningCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.14),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoftColor,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
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
            child: const Icon(
              Icons.payments_outlined,
              color: AppColors.primaryColor,
            ),
          ),
          12.0.sw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.user.name.isNotEmpty ? item.user.name : 'Consultation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHeadingColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                3.0.sh,
                Text(
                  _formatDate(item.date),
                  style: AppTypography.captionLarge.copyWith(
                    color: AppColors.textBodyColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+ ${_formatCurrency(item.grossFee)}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textHeadingColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: AppColors.formBorderColor.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textBodyColor,
        ),
      ),
    );
  }
}

class _UserProfile extends StatelessWidget {
  final ProfileController controller;

  const _UserProfile({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _TopBar(controller: controller),
              const Spacer(),
              const CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.subtleSurfaceColor,
                child: Icon(Icons.person_outline_rounded, size: 42),
              ),
              18.0.sh,
              Text(
                'User Profile',
                style: AppTypography.headingSmall.copyWith(
                  color: AppColors.textHeadingColor,
                ),
              ),
              8.0.sh,
              Text(
                'Profile reguler tetap sederhana, sementara architect memakai profile profesional dengan portfolio, award, dan earnings.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textBodyColor,
                  height: 1.45,
                ),
              ),
              24.0.sh,
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatCurrency(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return 'Rp ${buffer.toString()}';
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
