// lib/app/modules/design/controllers/design_controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/data/network/token_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class DesignController extends GetxController {
  static const int _perPage = 12;
  static const List<String> styleFilters = ['all', 'modern', 'traditional', 'minimalist', 'futuristik', 'industrial'];

  final CatalogService _catalogService;
  DesignController(this._catalogService);

  final catalogs = <Catalog>[].obs;
  final isLoadingCatalog = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final catalogError = ''.obs;
  final imageIndexByCatalog = <String, int>{}.obs;
  final selectedStyle = 'all'.obs;
  final selectedStatus = 'approved'.obs;
  final isStyleFilterOpen = false.obs;
  final isArchitect = false.obs;

  final likingCatalogIds = <String>{}.obs;
  final ScrollController scrollController = ScrollController();

  final searchController = TextEditingController();

  int _page = 1;
  Timer? _searchDebounce;
  bool _isScrollFetchRunning = false;

  int get designCount => catalogs.length;

  String get selectedStyleLabel {
    if (selectedStyle.value == 'all') return 'All Design';
    return _capitalize(selectedStyle.value);
  }

  bool isCatalogLiking(String catalogId) => likingCatalogIds.contains(catalogId);

  int getImageIndex(String catalogId) {
    return imageIndexByCatalog[catalogId] ?? 0;
  }

  void setImageIndex(String catalogId, int index) {
    imageIndexByCatalog[catalogId] = index;
  }

  void openDetailsFromDesign(String catalogId) {
    final nav = Get.find<NavigationController>();
    nav.navigateTo(tabIndex: 1, route: '/detail', arguments: catalogId);
  }

  void goBack() {
    Get.find<NavigationController>().onPop();
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
    _bootstrap();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    searchController.removeListener(_onSearchChanged);
    _searchDebounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    final tokenService = Get.find<TokenService>();
    final role = (await tokenService.getRole() ?? '').trim().toLowerCase();
    isArchitect.value = role == 'architect';
    await fetchCatalogs(reset: true);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 8 &&
        !_isScrollFetchRunning &&
        !isLoadingCatalog.value &&
        !isLoadingMore.value &&
        hasMore.value) {
      _isScrollFetchRunning = true;
      loadMoreCatalogs();
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchCatalogs(reset: true);
    });
  }

  Future<String?> _getCurrentArchitectId() async {
    if (!isArchitect.value) return null;
    final tokenService = Get.find<TokenService>();
    final userId = await tokenService.getUserId();
    final normalized = userId?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  Future<void> fetchCatalogs({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasMore.value = true;
      catalogs.clear();
    } else {
      if (!hasMore.value || isLoadingCatalog.value || isLoadingMore.value) {
        return;
      }
    }

    try {
      if (reset) {
        isLoadingCatalog.value = true;
      } else {
        isLoadingMore.value = true;
      }
      catalogError.value = '';

      final result = await _catalogService.getCatalogs(
        page: _page,
        perPage: _perPage,
        search: searchController.text,
        style: selectedStyle.value == 'all' ? null : selectedStyle.value,
        architectId: await _getCurrentArchitectId(),
        status: isArchitect.value ? selectedStatus.value : null,
      );

      if (reset) {
        catalogs.assignAll(result);
      } else {
        catalogs.addAll(result);
      }

      hasMore.value = result.length == _perPage;
      if (hasMore.value) {
        _page++;
      }
    } catch (e) {
      catalogError.value = e.toString();
    } finally {
      isLoadingCatalog.value = false;
      isLoadingMore.value = false;
      _isScrollFetchRunning = false;
    }
  }

  Future<void> loadMoreCatalogs() async {
    if (!hasMore.value || isLoadingCatalog.value || isLoadingMore.value) return;
    await fetchCatalogs();
  }

  void toggleStyleFilter() {
    isStyleFilterOpen.value = !isStyleFilterOpen.value;
  }

  void changeStyle(String style) {
    if (!styleFilters.contains(style) || style == selectedStyle.value) {
      isStyleFilterOpen.value = false;
      return;
    }
    selectedStyle.value = style;
    isStyleFilterOpen.value = false;
    fetchCatalogs(reset: true);
  }

  void changeStatus(String status) {
    if (status == selectedStatus.value) return;
    selectedStatus.value = status;
    fetchCatalogs(reset: true);
  }

  void openUploadDesign() {
    Get.snackbar('Upload Design', 'Halaman upload design akan dibuat nanti.');
  }

  void openEditDesign(String catalogId) {
    Get.snackbar('Edit Design', 'Halaman edit design akan dibuat nanti.');
  }

  Future<void> toggleCatalogLike(String id) async {
    final i = catalogs.indexWhere((e) => e.id == id);
    if (i < 0 || likingCatalogIds.contains(id)) return;

    likingCatalogIds.add(id);

    final prev = catalogs[i];
    final liked = !prev.liked;

    catalogs[i] = prev.copyWith(
      liked: liked,
      likesCount: (prev.likesCount + (liked ? 1 : -1)).clamp(0, double.infinity).toInt(),
    );
    catalogs.refresh();

    try {
      await (liked ? _catalogService.likeCatalog(id) : _catalogService.unlikeCatalog(id));
    } catch (e) {
      catalogs[i] = prev;
      catalogs.refresh();
    } finally {
      likingCatalogIds.remove(id);
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
