import 'package:get/get.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/data/network/architect_service.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/data/network/token_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:halositek/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final CatalogService _catalogService;
  final ArchitectService _architectService;
  final ChatService _chatService;

  HomeController(
    this._catalogService,
    this._architectService,
    this._chatService,
  );

  final catalogs = <Catalog>[].obs;
  final isLoadingCatalog = false.obs;
  final catalogError = ''.obs;
  final imageIndexByCatalog = <String, int>{}.obs;

  final architects = <Architect>[].obs;
  final isLoadingArchitect = false.obs;
  final architectError = ''.obs;

  final isLoadingChat = false.obs;
  final chatError = ''.obs;
  final conversations = <ChatConversation>[].obs;
  // final totalUnread = 0.obs;

  final isArchitect = false.obs;
  final currentArchitectId = ''.obs;
  final isLoadingPerformance = false.obs;
  final performanceError = ''.obs;
  final totalLikes = 0.obs;
  final totalConsult = 0.obs;
  final totalSaved = 0.obs;

  final likingCatalogIds = <String>{}.obs;

  final searchController = TextEditingController();

  final searchedCatalogs = <Catalog>[].obs;
  final searchedArchitects = <Architect>[].obs;

  final isSearching = false.obs;
  final searchError = ''.obs;
  final searchQuery = ''.obs;
  final hasSearched = false.obs;

  Timer? _searchDebounce;

  bool isCatalogLiking(String catalogId) =>
      likingCatalogIds.contains(catalogId);

  int getImageIndex(String catalogId) {
    return imageIndexByCatalog[catalogId] ?? 0;
  }

  bool get isSearchMode => searchQuery.value.trim().isNotEmpty;

  void setImageIndex(String catalogId, int index) {
    imageIndexByCatalog[catalogId] = index;
  }

  void openDetailsFromHome(String projectId) {
    final nav = Get.find<NavigationController>();
    nav.navigateTo(tabIndex: 1, route: '/detail', arguments: projectId);
  }

  void openPortofolioFromHome() {
    final nav = Get.find<NavigationController>();
    nav.navigateTo(tabIndex: 2, route: '/portofolio');
  }

  void openDesignFromHome() {
    final nav = Get.find<NavigationController>();
    nav.changeIndex(1);
  }

  void openArchitectFromHome() {
    final nav = Get.find<NavigationController>();
    nav.changeIndex(2);
  }

  void openChatListFromHome() {
    final nav = Get.find<NavigationController>();
    nav.navigateTo(tabIndex: 0, route: '/chats');
  }

  void openAiChatFromHome() {
    Get.toNamed(Routes.AI_CHAT);
  }

  Future<void> openEditDesign(Catalog catalog) async {
    if (catalog.id.trim().isEmpty) return;
    final nav = Get.find<NavigationController>();
    nav.navigateTo(tabIndex: 1, route: '/design/edit', arguments: catalog);
  }

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();

    searchController.addListener(_onSearchChanged);

    _initializeDashboard();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;

    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      searchDashboard();
    });
  }

  Future<void> _initializeDashboard() async {
    await _loadCurrentRole();
    // fetchUnreadBadge();

    if (isArchitect.value) {
      fetchArchitectPerformance();
      fetchCatalogs();
    } else {
      fetchCatalogs();
      fetchArchitects();
    }
  }

  Future<void> searchDashboard() async {
    final keyword = searchController.text.trim();

    if (keyword.isEmpty) {
      hasSearched.value = false;
      searchedCatalogs.clear();
      searchedArchitects.clear();
      return;
    }

    try {
      isSearching.value = true;
      searchError.value = '';

      searchedCatalogs.clear();
      searchedArchitects.clear();

      if (isArchitect.value) {
        final architectId = currentArchitectId.value.trim();
        if (architectId.isEmpty) {
          searchError.value = 'Architect ID tidak ditemukan';
          return;
        }
      }

      final results = await Future.wait([
        _architectService.getArchitects(page: 1, perPage: 2, search: keyword),
        _catalogService.getCatalogList(page: 1, perPage: 2, search: keyword),
      ]);

      searchedArchitects.assignAll(results[0] as List<Architect>);

      searchedCatalogs.assignAll((results[1] as CatalogListResponse).catalogs);

      hasSearched.value = true;
    } catch (e) {
      searchError.value = e.toString();
      hasSearched.value = true;
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> _loadCurrentRole() async {
    final tokenService = Get.find<TokenService>();
    final role = (await tokenService.getRole() ?? '').trim().toLowerCase();
    isArchitect.value = role == 'architect';

    final userId = await tokenService.getUserId();
    currentArchitectId.value = (userId ?? '').trim();
  }

  int projectCompletedCount(Architect architect) {
    return architect.totalProjects;
  }

  int hiddenProjectsCount(Architect architect) {
    final total = projectCompletedCount(architect);
    if (total <= 2) return 0;
    return total - 2;
  }

  void openArchitectPortofolio(Architect architect) {
    final nav = Get.find<NavigationController>();

    nav.navigateTo(tabIndex: 2, route: '/portofolio', arguments: architect.id);
  }

  Future<void> fetchArchitectPerformance() async {
    final architectId = currentArchitectId.value.trim();
    if (architectId.isEmpty) {
      performanceError.value = 'Architect ID tidak ditemukan';
      totalLikes.value = 0;
      totalConsult.value = 0;
      totalSaved.value = 0;
      return;
    }

    try {
      isLoadingPerformance.value = true;
      performanceError.value = '';

      final performance = await _architectService.getArchitectPerformance(
        architectId,
      );

      totalLikes.value = performance.likes;
      totalConsult.value = performance.consultations;
      totalSaved.value = performance.saved;
    } catch (e) {
      performanceError.value = e.toString();
    } finally {
      isLoadingPerformance.value = false;
    }
  }

  Future<void> fetchCatalogs({String? architectId}) async {
    try {
      isLoadingCatalog.value = true;
      catalogError.value = '';

      final resolvedArchitectId =
          architectId ?? (isArchitect.value ? currentArchitectId.value : null);
      if (isArchitect.value &&
          (resolvedArchitectId == null || resolvedArchitectId.trim().isEmpty)) {
        catalogs.clear();
        catalogError.value = 'Architect ID tidak ditemukan';
        return;
      }

      final result =
          isArchitect.value
              ? await _catalogService.getCatalogs(
                perPage: 6,
                architectId: resolvedArchitectId,
                status: 'approved',
              )
              : await _catalogService.getCatalogs(perPage: 6);

      catalogs.assignAll(result);
    } catch (e) {
      catalogError.value = e.toString();
    } finally {
      isLoadingCatalog.value = false;
    }
  }

  // Future<void> fetchUnreadBadge() async {
  //   try {
  //     int total = 0;
  //     isLoadingChat.value = true;
  //     chatError.value = '';

  //     final result = await _chatService.getConversations();
  //     conversations.assignAll(result);

  //     for (var c in conversations) {
  //       total += c.unreadCount;
  //     }

  //     totalUnread.value = total;
  //   } catch (e) {
  //     chatError.value = e.toString();
  //   } finally {
  //     isLoadingChat.value = false;
  //   }
  // }

  Future<void> fetchArchitects() async {
    try {
      isLoadingArchitect.value = true;
      architectError.value = '';

      final result = await _architectService.getArchitects(perPage: 6);
      architects.assignAll(result);
    } catch (e) {
      architectError.value = e.toString();
    } finally {
      isLoadingArchitect.value = false;
    }
  }

  Future<void> toggleCatalogLike(String id) async {
    final i = catalogs.indexWhere((e) => e.id == id);
    if (i < 0 || likingCatalogIds.contains(id)) return;

    likingCatalogIds.add(id);

    final prev = catalogs[i];
    final liked = !prev.liked;

    catalogs[i] = prev.copyWith(
      liked: liked,
      likesCount:
          (prev.likesCount + (liked ? 1 : -1))
              .clamp(0, double.infinity)
              .toInt(),
    );
    catalogs.refresh();

    try {
      await (liked
          ? _catalogService.likeCatalog(id)
          : _catalogService.unlikeCatalog(id));
    } catch (e) {
      catalogs[i] = prev;
      catalogs.refresh();
    } finally {
      likingCatalogIds.remove(id);
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
