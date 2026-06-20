import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/models/architect_earnings.dart';
import 'package:halositek/app/data/models/user.dart';
import 'package:halositek/app/data/network/architect_service.dart';
import 'package:halositek/app/data/network/auth_service.dart';
import 'package:halositek/app/data/network/token_service.dart';
import 'package:halositek/app/data/network/websocket_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

enum ProfileTab { portfolio, award, earnings }

class ProfileController extends GetxController {
  final AuthService _authService;
  final TokenService _tokenService;
  final ArchitectService _architectService;

  ProfileController(this._authService, this._tokenService, this._architectService);

  final ScrollController scrollController = ScrollController();

  final role = ''.obs;
  final userId = ''.obs;
  final isReady = false.obs;
  final isLoading = false.obs;
  final isLoadingEarnings = false.obs;
  final isLoadingProjects = false.obs;
  final isLoadingAwards = false.obs;
  final errorMessage = ''.obs;
  final earningsError = ''.obs;
  final selectedTab = ProfileTab.portfolio.obs;
  final architect = Rxn<Architect>();
  final user = Rxn<UserProfile>();
  final earnings = ArchitectEarnings.empty().obs;

  // Pagination states
  int _projectsPage = 1;
  int _awardsPage = 1;
  int _earningsPage = 1;
  final int _perPage = 10;

  final isLoadingMoreProjects = false.obs;
  final isLoadingMoreAwards = false.obs;
  final isLoadingMoreEarnings = false.obs;

  final hasMoreProjects = true.obs;
  final hasMoreAwards = true.obs;
  final hasMoreEarnings = true.obs;

  final RxList<ArchitectProject> paginatedProjects = <ArchitectProject>[].obs;
  final RxList<ArchitectAward> paginatedAwards = <ArchitectAward>[].obs;

  bool get isArchitect => role.value.trim().toLowerCase() == 'architect';
  List<ArchitectProject> get projects => paginatedProjects.toList();
  List<ArchitectAward> get awards => paginatedAwards.toList();
  List<SavedProject> get savedProjects => user.value?.savedProjects ?? const [];
  List<SavedArchitect> get savedArchitects => user.value?.savedArchitects ?? const [];
  List<PaymentHistory> get paymentHistories => user.value?.paymentHistories ?? const [];

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadProfile();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (selectedTab.value == ProfileTab.portfolio) {
        fetchMoreProjects();
      } else if (selectedTab.value == ProfileTab.award) {
        fetchMoreAwards();
      } else if (selectedTab.value == ProfileTab.earnings) {
        fetchMoreEarnings();
      }
    }
  }

  void goBack() {
    Get.find<NavigationController>().onPop();
  }

  Future<void> loadProfile() async {
    try {
      role.value = await _tokenService.getRole() ?? '';
      userId.value = await _tokenService.getUserId() ?? '';
      isReady.value = true;

      if (isArchitect) {
        if (userId.value.trim().isEmpty) {
          errorMessage.value = 'Architect id tidak ditemukan. Silakan login ulang.';
          return;
        }

        await Future.wait([fetchArchitect(), fetchProjects(), fetchAwards(), fetchEarnings()]);
      } else {
        await fetchUser();
      }
    } finally {
      isReady.value = true;
    }
  }

  Future<void> refreshProfile() async {
    if (isArchitect) {
      await Future.wait([fetchArchitect(), fetchProjects(), fetchAwards(), fetchEarnings()]);
    } else {
      await fetchUser();
    }
  }

  Future<void> fetchUser() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      user.value = await _authService.getMe();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchArchitect() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      architect.value = await _architectService.getArchitectById(userId.value);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProjects() async {
    try {
      isLoadingProjects.value = true;
      _projectsPage = 1;
      hasMoreProjects.value = true;
      paginatedProjects.clear();
      await fetchMoreProjects();
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      isLoadingProjects.value = false;
    }
  }

  Future<void> fetchMoreProjects() async {
    if (isLoadingMoreProjects.value || !hasMoreProjects.value) return;
    try {
      isLoadingMoreProjects.value = true;

      final result = await _architectService.getProjects(architectId: userId.value, page: _projectsPage, perPage: _perPage);
      if (result.items.isEmpty) {
        hasMoreProjects.value = false;
      } else {
        paginatedProjects.addAll(result.items);
        _projectsPage++;
        if (_projectsPage > result.lastPage || result.lastPage == 0) {
          hasMoreProjects.value = false;
        }
      }
    } catch (e) {
      debugPrint('Error fetching projects: $e');
    } finally {
      isLoadingMoreProjects.value = false;
    }
  }

  Future<void> fetchAwards() async {
    try {
      isLoadingAwards.value = true;
      _awardsPage = 1;
      hasMoreAwards.value = true;
      paginatedAwards.clear();
      await fetchMoreAwards();
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      isLoadingAwards.value = false;
    }
  }

  Future<void> fetchMoreAwards() async {
    if (isLoadingMoreAwards.value || !hasMoreAwards.value) return;
    try {
      isLoadingMoreAwards.value = true;
      final result = await _architectService.getAwards(architectId: userId.value, page: _awardsPage, perPage: _perPage);
      if (result.items.isEmpty) {
        hasMoreAwards.value = false;
      } else {
        paginatedAwards.addAll(result.items);
        _awardsPage++;
        if (_awardsPage > result.lastPage || result.lastPage == 0) {
          hasMoreAwards.value = false;
        }
      }
    } catch (e) {
      debugPrint('Error fetching awards: $e');
    } finally {
      isLoadingMoreAwards.value = false;
    }
  }

  Future<void> fetchEarnings() async {
    try {
      isLoadingEarnings.value = true;
      earningsError.value = '';
      _earningsPage = 1;
      hasMoreEarnings.value = true;
      final data = await _architectService.getArchitectEarnings(page: _earningsPage, perPage: _perPage);
      earnings.value = data;
      _earningsPage++;
      if (data.earnings.length < _perPage) hasMoreEarnings.value = false;
    } catch (e) {
      earningsError.value = e.toString();
    } finally {
      isLoadingEarnings.value = false;
    }
  }

  Future<void> fetchMoreEarnings() async {
    if (isLoadingMoreEarnings.value || !hasMoreEarnings.value) return;
    try {
      isLoadingMoreEarnings.value = true;
      final data = await _architectService.getArchitectEarnings(page: _earningsPage, perPage: _perPage);
      if (data.earnings.isEmpty) {
        hasMoreEarnings.value = false;
      } else {
        final currentEarnings = earnings.value;
        earnings.value = ArchitectEarnings(
          totalGrossEarnings: data.totalGrossEarnings,
          totalTaxPaid: data.totalTaxPaid,
          totalNetEarnings: data.totalNetEarnings,
          earnings: [...currentEarnings.earnings, ...data.earnings],
          meta: data.meta,
        );
        _earningsPage++;
        if (data.earnings.length < _perPage) hasMoreEarnings.value = false;
      }
    } catch (e) {
      debugPrint('Error fetching more earnings: $e');
    } finally {
      isLoadingMoreEarnings.value = false;
    }
  }

  void changeTab(ProfileTab tab) {
    selectedTab.value = tab;
  }

  void openEditProfile() {
    if (!isArchitect || architect.value == null) {
      if (user.value != null) {
        Get.find<NavigationController>().navigateTo(tabIndex: 3, route: '/profile/edit', arguments: user.value);
      }
    } else {
      Get.find<NavigationController>().navigateTo(tabIndex: 3, route: '/profile/edit', arguments: architect.value);
    }
  }

  void openSavedArchitects() {
    Get.find<NavigationController>().navigateTo(tabIndex: 3, route: '/profile/saved-architects');
  }

  void openSavedDesigns() {
    Get.find<NavigationController>().navigateTo(tabIndex: 3, route: '/profile/saved-designs');
  }

  void openSavedArchitectDetail(SavedArchitect architect) {
    final architectId = architect.id.trim();
    if (architectId.isEmpty) {
      Get.snackbar('Gagal', 'Architect ID tidak ditemukan');
      return;
    }

    Get.find<NavigationController>().navigateTo(tabIndex: 2, route: '/portofolio', arguments: architectId);
  }

  void openSavedDesignDetail(SavedProject project) {
    final projectId = project.id.trim();
    if (projectId.isEmpty) {
      Get.snackbar('Gagal', 'Design ID tidak ditemukan');
      return;
    }

    Get.find<NavigationController>().navigateTo(tabIndex: 1, route: '/detail', arguments: projectId);
  }

  void openPortfolioProjectDetail(ArchitectProject project) {
    final projectId = project.id.trim();
    if (projectId.isEmpty) {
      Get.snackbar('Gagal', 'Design ID tidak ditemukan');
      return;
    }

    Get.find<NavigationController>().navigateTo(tabIndex: 1, route: '/detail', arguments: projectId);
  }

  void openArchitectAwardDetail(ArchitectAward award) {
    final awardId = award.id.trim();
    if (awardId.isEmpty) {
      Get.snackbar('Gagal', 'Award ID tidak ditemukan');
      return;
    }

    Get.find<NavigationController>().navigateTo(tabIndex: 2, route: '/award/detail', arguments: awardId);
  }

  void openPaymentHistory() {
    Get.find<NavigationController>().navigateTo(tabIndex: 3, route: '/profile/payment-history');
  }

  Future<void> logout() async {
    try {
      // Disconnect WebSocket before logout
      Get.find<WebSocketService>().disconnect();

      await _authService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Log out Failed', e.toString());
    }
  }
}
