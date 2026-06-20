import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/models/architect_earnings.dart';
import 'package:halositek/app/modules/profile/controllers/profile_controller.dart';
import 'package:halositek/app/modules/profile/widgets/profile_common_widgets.dart';
import 'package:halositek/app/modules/profile/widgets/profile_formatters.dart';
import 'package:halositek/app/modules/profile/widgets/profile_top_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ArchitectProfileView extends StatelessWidget {
  final ProfileController controller;

  const ArchitectProfileView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.01),
            child: Obx(() {
              final architect = controller.architect.value;
              final isLoading = controller.isLoading.value;
              final hasError = controller.errorMessage.value.isNotEmpty;

              if (hasError && architect == null) {
                return Column(
                  children: [
                    ProfileTopBar(title: 'Your Profile', onBack: controller.goBack, onLogout: controller.logout),
                    80.0.sh,
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.errorColor),
                    ),
                    TextButton(onPressed: controller.fetchArchitect, child: const Text('Coba Lagi')),
                  ],
                );
              }

              final profile = architect ?? _dummyArchitect();

              return Skeletonizer(
                enabled: isLoading,
                child: AbsorbPointer(
                  absorbing: isLoading,
                  child: Column(
                    children: [
                      ProfileTopBar(title: 'Your Profile', onBack: controller.goBack, onLogout: controller.logout),
                      12.0.sh,
                      _Header(architect: profile, onEdit: controller.openEditProfile),
                      24.0.sh,
                      _Stats(architect: profile),
                      24.0.sh,
                      _FeeButton(architect: profile, onEdit: controller.openEditProfile),
                      26.0.sh,
                      _Tabs(controller: controller),
                      18.0.sh,
                      _TabBody(controller: controller),
                      16.0.sh,
                      Obx(() {
                        bool isLoadingMore = false;
                        bool hasMore = true;
                        bool hasData = false;

                        if (controller.selectedTab.value == ProfileTab.portfolio) {
                          isLoadingMore = controller.isLoadingMoreProjects.value;
                          hasMore = controller.hasMoreProjects.value;
                          hasData = controller.projects.isNotEmpty;
                        } else if (controller.selectedTab.value == ProfileTab.award) {
                          isLoadingMore = controller.isLoadingMoreAwards.value;
                          hasMore = controller.hasMoreAwards.value;
                          hasData = controller.awards.isNotEmpty;
                        } else if (controller.selectedTab.value == ProfileTab.earnings) {
                          isLoadingMore = controller.isLoadingMoreEarnings.value;
                          hasMore = controller.hasMoreEarnings.value;
                          hasData = controller.earnings.value.earnings.isNotEmpty;
                        }

                        if (isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
                            ),
                          );
                        } else if (!hasMore && hasData) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'End of data',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textBodyColor.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
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

Architect _dummyArchitect() {
  return const Architect(
    id: 'loading-architect',
    name: 'Architect Name',
    email: 'architect@example.com',
    profilePicture: '',
    emailVerifiedAt: null,
    role: 'architect',
    createdAt: null,
    updatedAt: null,
    headline: 'Residential Specialist',
    bio: 'Experienced architect focused on thoughtful residential and interior design.',
    location: 'Jakarta',
    status: 'approved',
    specialization: 'Modern Minimalist',
    totalProjects: 12,
    totalAwards: 4,
    rating: 0,
    consultationFee: 250000,
    consultationDuration: 1,
    yearOfExperience: 8,
    isWishlisted: null,
    projects: _dummyProjects,
    awards: _dummyAwards,
  );
}

const _dummyProjects = <ArchitectProject>[
  ArchitectProject(
    id: 'loading-project-1',
    architectId: '',
    name: 'Modern Residence',
    style: 'modern',
    description: '',
    images: <String>[],
    imageUrls: <String>[],
    estimatedCost: '',
    layoutImages: <String>[],
    layoutImageUrls: <String>[],
    highlightFeatures: '',
    area: '',
    likesCount: 0,
    liked: false,
    status: 'approved',
    createdAt: null,
    updatedAt: null,
  ),
  ArchitectProject(
    id: 'loading-project-2',
    architectId: '',
    name: 'Classic Interior',
    style: 'classic',
    description: '',
    images: <String>[],
    imageUrls: <String>[],
    estimatedCost: '',
    layoutImages: <String>[],
    layoutImageUrls: <String>[],
    highlightFeatures: '',
    area: '',
    likesCount: 0,
    liked: false,
    status: 'approved',
    createdAt: null,
    updatedAt: null,
  ),
];

const _dummyAwards = <ArchitectAward>[
  ArchitectAward(
    id: 'loading-award-1',
    name: 'Design Award',
    projectName: 'Modern Residence',
    awardDate: null,
    description: '',
    verificationFileUrl: '',
    status: 'approved',
  ),
  ArchitectAward(
    id: 'loading-award-2',
    name: 'Architecture Award',
    projectName: 'Classic Interior',
    awardDate: null,
    description: '',
    verificationFileUrl: '',
    status: 'approved',
  ),
];

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
                border: Border.all(color: AppColors.secondaryColor.withValues(alpha: 0.28), width: 4),
              ),
              child: ClipOval(
                child:
                    architect.profilePicture.isNotEmpty
                        ? Image.network(
                          architect.profilePicture.startsWith('http') || architect.profilePicture.startsWith('https')
                              ? architect.profilePicture
                              : "${dotenv.env['BASEURL']}/storage/${architect.profilePicture}",
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
          architect.name.isNotEmpty ? architect.name : '-',
          textAlign: TextAlign.center,
          style: AppTypography.headingMedium.copyWith(
            fontSize: 20,
            color: AppColors.textHeadingColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        4.0.sh,
        Text(
          subtitle.isNotEmpty ? subtitle : 'Architect',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w700),
        ),
        14.0.sh,
        Text(
          architect.bio.isNotEmpty
              ? architect.bio
              : 'Lengkapi bio untuk menampilkan ringkasan keahlian dan pengalaman arsitektur Anda.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor, height: 1.55),
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
        Expanded(child: _StatCard(value: architect.totalProjects.toString(), label: 'PROJECTS')),
        12.0.sw,
        Expanded(child: _StatCard(value: architect.totalAwards.toString(), label: 'AWARDS')),
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
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: AppTypography.headingSmall.copyWith(color: AppColors.primaryColor, fontSize: 21)),
          5.0.sh,
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FeeButton extends StatelessWidget {
  final Architect architect;
  final VoidCallback onEdit;

  const _FeeButton({required this.architect, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Container(
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
                '${formatCurrency(architect.consultationFee)} / hour',
                style: AppTypography.bodySmall.copyWith(color: AppColors.whiteColor, fontWeight: FontWeight.w800),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppColors.whiteColor),
            22.0.sw,
            Text(
              'Your Fee',
              style: AppTypography.bodySmall.copyWith(color: AppColors.whiteColor, fontWeight: FontWeight.w800),
            ),
          ],
        ),
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
                color: active ? AppColors.primaryColor : AppColors.textBodyColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            12.0.sh,
            Container(height: 2, color: active ? AppColors.primaryColor : AppColors.accentColor),
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
          return _PortfolioGrid(
            projects: controller.isLoadingProjects.value ? _dummyProjects : controller.projects,
            onTap: controller.openPortfolioProjectDetail,
          );
        case ProfileTab.award:
          return _AwardGrid(
            awards: controller.isLoadingAwards.value ? _dummyAwards : controller.awards,
            onTap: controller.openArchitectAwardDetail,
          );
        case ProfileTab.earnings:
          return _EarningsList(controller: controller);
      }
    });
  }
}

class _PortfolioGrid extends StatelessWidget {
  final List<ArchitectProject> projects;
  final ValueChanged<ArchitectProject> onTap;

  const _PortfolioGrid({required this.projects, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const ProfileEmptyState(message: 'Belum ada portfolio.');
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
      itemBuilder: (_, index) => _ProjectCard(project: projects[index], onTap: () => onTap(projects[index])),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ArchitectProject project;
  final VoidCallback? onTap;

  const _ProjectCard({required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final images = project.imageUrls.isNotEmpty ? project.imageUrls : project.images;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: SizedBox.expand(
                child:
                    images.isNotEmpty
                        ? Image.network(
                          images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(profileFallbackImage, fit: BoxFit.cover),
                        )
                        : Image.asset(profileFallbackImage, fit: BoxFit.cover),
              ),
            ),
          ),
          8.0.sh,
          Text(
            project.name.isNotEmpty ? project.name : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _AwardGrid extends StatelessWidget {
  final List<ArchitectAward> awards;
  final ValueChanged<ArchitectAward> onTap;

  const _AwardGrid({required this.awards, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (awards.isEmpty) {
      return const ProfileEmptyState(message: 'Belum ada award.');
    }

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
      itemBuilder: (_, index) => _AwardCard(award: awards[index], onTap: () => onTap(awards[index])),
    );
  }
}

class _AwardCard extends StatelessWidget {
  final ArchitectAward award;
  final VoidCallback? onTap;

  const _AwardCard({required this.award, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child:
                  award.verificationFileUrl.isNotEmpty
                      ? Image.network(
                        award.verificationFileUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(profileFallbackImage, fit: BoxFit.cover),
                      )
                      : Image.asset(profileFallbackImage, fit: BoxFit.cover),
            ),
          ),
          8.0.sh,
          Text(
            award.name.isNotEmpty ? award.name : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _EarningsList extends StatelessWidget {
  final ProfileController controller;

  const _EarningsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isLoading = controller.isLoadingEarnings.value && controller.earnings.value.earnings.isEmpty;
    final data =
        isLoading
            ? const ArchitectEarnings(
              totalGrossEarnings: 0,
              totalTaxPaid: 0,
              totalNetEarnings: 0,
              earnings: _dummyEarnings,
              meta: ArchitectEarningsMeta(currentPage: 1, lastPage: 1, perPage: 15, total: 2),
            )
            : controller.earnings.value;

    if (controller.earningsError.value.isNotEmpty && data.earnings.isEmpty) {
      return Column(
        children: [
          Text(
            controller.earningsError.value,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.errorColor),
          ),
          TextButton(onPressed: controller.fetchEarnings, child: const Text('Coba Lagi')),
        ],
      );
    }

    if (data.earnings.isEmpty) {
      return const ProfileEmptyState(message: 'Belum ada earnings.');
    }

    return Skeletonizer(
      enabled: isLoading,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.earnings.length,
        separatorBuilder: (_, __) => 10.0.sh,
        itemBuilder: (_, index) => _EarningCard(item: data.earnings[index]),
      ),
    );
  }
}

const _dummyEarnings = <ArchitectEarningItem>[
  ArchitectEarningItem(
    consultationId: 'loading-earning-1',
    user: ArchitectEarningUser(id: '', name: 'Client Name', email: 'client@example.com'),
    date: null,
    grossFee: 250000,
    taxDeduction: 0,
    netEarning: 250000,
    releasedAt: null,
  ),
  ArchitectEarningItem(
    consultationId: 'loading-earning-2',
    user: ArchitectEarningUser(id: '', name: 'Client Name', email: 'client@example.com'),
    date: null,
    grossFee: 250000,
    taxDeduction: 0,
    netEarning: 250000,
    releasedAt: null,
  ),
];

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
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.14)),
        boxShadow: const [BoxShadow(color: AppColors.shadowSoftColor, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, color: AppColors.primaryColor),
          12.0.sw,
          Expanded(
            child: Text(
              item.user.name.isNotEmpty ? item.user.name : 'Consultation',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            '+ ${formatCurrency(item.grossFee)}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeadingColor, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
