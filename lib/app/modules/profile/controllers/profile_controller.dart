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

  ProfileController(
    this._authService,
    this._tokenService,
    this._architectService,
  );

  final role = ''.obs;
  final userId = ''.obs;
  final isReady = false.obs;
  final isLoading = false.obs;
  final isLoadingEarnings = false.obs;
  final errorMessage = ''.obs;
  final earningsError = ''.obs;
  final selectedTab = ProfileTab.portfolio.obs;
  final architect = Rxn<Architect>();
  final user = Rxn<UserProfile>();
  final earnings = ArchitectEarnings.empty().obs;

  bool get isArchitect => role.value.trim().toLowerCase() == 'architect';
  List<ArchitectProject> get projects => architect.value?.projects ?? const [];
  List<ArchitectAward> get awards => architect.value?.awards ?? const [];
  List<SavedProject> get savedProjects => user.value?.savedProjects ?? const [];
  List<SavedArchitect> get savedArchitects =>
      user.value?.savedArchitects ?? const [];
  List<PaymentHistory> get paymentHistories =>
      user.value?.paymentHistories ?? const [];

  @override
  void onInit() {
    super.onInit();
    loadProfile();
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
          errorMessage.value =
              'Architect id tidak ditemukan. Silakan login ulang.';
          return;
        }

        await Future.wait([fetchArchitect(), fetchEarnings()]);
      } else {
        await fetchUser();
      }
    } finally {
      isReady.value = true;
    }
  }

  Future<void> refreshProfile() async {
    if (isArchitect) {
      await Future.wait([fetchArchitect(), fetchEarnings()]);
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

  Future<void> fetchEarnings() async {
    try {
      isLoadingEarnings.value = true;
      earningsError.value = '';
      earnings.value = await _architectService.getArchitectEarnings();
    } catch (e) {
      earningsError.value = e.toString();
    } finally {
      isLoadingEarnings.value = false;
    }
  }

  void changeTab(ProfileTab tab) {
    selectedTab.value = tab;
  }

  void openEditProfile() {
    if (!isArchitect || architect.value == null) {
      if (user.value != null) {
        Get.find<NavigationController>().navigateTo(
          tabIndex: 3,
          route: '/profile/edit',
          arguments: user.value,
        );
      }
    } else {
      Get.find<NavigationController>().navigateTo(
        tabIndex: 3,
        route: '/profile/edit',
        arguments: architect.value,
      );
    }
  }

  void openSavedArchitects() {
    Get.find<NavigationController>().navigateTo(
      tabIndex: 3,
      route: '/profile/saved-architects',
    );
  }

  void openSavedDesigns() {
    Get.find<NavigationController>().navigateTo(
      tabIndex: 3,
      route: '/profile/saved-designs',
    );
  }

  void openSavedArchitectDetail(SavedArchitect architect) {
    final architectId = architect.id.trim();
    if (architectId.isEmpty) {
      Get.snackbar('Gagal', 'Architect ID tidak ditemukan');
      return;
    }

    Get.find<NavigationController>().navigateTo(
      tabIndex: 2,
      route: '/portofolio',
      arguments: architectId,
    );
  }

  void openSavedDesignDetail(SavedProject project) {
    final projectId = project.id.trim();
    if (projectId.isEmpty) {
      Get.snackbar('Gagal', 'Design ID tidak ditemukan');
      return;
    }

    Get.find<NavigationController>().navigateTo(
      tabIndex: 1,
      route: '/detail',
      arguments: projectId,
    );
  }

  void openPortfolioProjectDetail(ArchitectProject project) {
    final projectId = project.id.trim();
    if (projectId.isEmpty) {
      Get.snackbar('Gagal', 'Design ID tidak ditemukan');
      return;
    }

    Get.find<NavigationController>().navigateTo(
      tabIndex: 1,
      route: '/detail',
      arguments: projectId,
    );
  }

  void openArchitectAwardDetail(ArchitectAward award) {
    final awardId = award.id.trim();
    if (awardId.isEmpty) {
      Get.snackbar('Gagal', 'Award ID tidak ditemukan');
      return;
    }

    Get.find<NavigationController>().navigateTo(
      tabIndex: 2,
      route: '/award/detail',
      arguments: awardId,
    );
  }

  void openPaymentHistory() {
    Get.find<NavigationController>().navigateTo(
      tabIndex: 3,
      route: '/profile/payment-history',
    );
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
