// lib/app/modules/design/controllers/design_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class DesignController extends GetxController {
  static const int _perPage = 12;

  final CatalogService _catalogService;
  DesignController(this._catalogService);

  final catalogs = <Catalog>[].obs;
  final isLoadingCatalog = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final catalogError = ''.obs;
  final imageIndexByCatalog = <String, int>{}.obs;

  final likingCatalogIds = <String>{}.obs;
  final ScrollController scrollController = ScrollController();

  int _page = 1;

  bool isCatalogLiking(String catalogId) =>
      likingCatalogIds.contains(catalogId);

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

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchCatalogs(reset: true);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final triggerPoint = scrollController.position.maxScrollExtent - 200;
    if (scrollController.position.pixels >= triggerPoint) {
      loadMoreCatalogs();
    }
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
    }
  }

  Future<void> loadMoreCatalogs() async {
    if (!hasMore.value || isLoadingCatalog.value || isLoadingMore.value) return;
    await fetchCatalogs();
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
}
