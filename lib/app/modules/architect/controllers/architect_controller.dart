// lib/app/modules/architect/controllers/architect_controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/network/architect_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class ArchitectController extends GetxController {
  static const int _perPage = 12;

  final ArchitectService _architectService;

  ArchitectController(this._architectService);

  final architects = <Architect>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int _page = 1;
  Timer? _searchDebounce;

  bool get hasData => architects.isNotEmpty;

  void goBack() {
    final nav = Get.find<NavigationController>();
    nav.onPop();
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
    fetchArchitects(reset: true);
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

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final triggerPoint = scrollController.position.maxScrollExtent - 200;
    if (scrollController.position.pixels >= triggerPoint) {
      loadMoreArchitects();
    }
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchArchitects(reset: true);
    });
  }

  Future<void> refreshArchitects() async {
    await fetchArchitects(reset: true);
  }

  Future<void> fetchArchitects({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasMore.value = true;
      architects.clear();
    } else {
      if (!hasMore.value || isLoading.value || isLoadingMore.value) {
        return;
      }
    }

    try {
      if (reset) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      errorMessage.value = '';

      final result = await _architectService.getArchitects(
        page: _page,
        perPage: _perPage,
        search: searchController.text,
      );

      if (reset) {
        architects.assignAll(result);
      } else {
        architects.addAll(result);
      }

      hasMore.value = result.length == _perPage;
      if (hasMore.value) {
        _page++;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreArchitects() async {
    if (!hasMore.value || isLoading.value || isLoadingMore.value) return;
    await fetchArchitects();
  }

  int projectCompletedCount(Architect architect) {
    return architect.totalProjects;
  }

  void openPortofolio(Architect architect) {
    final nav = Get.find<NavigationController>();
    nav.navigateTo(tabIndex: 2, route: '/portofolio', arguments: architect.id);
  }

  int hiddenProjectsCount(Architect architect) {
    final total = projectCompletedCount(architect);
    if (total <= 2) return 0;
    return total - 2;
  }
}
