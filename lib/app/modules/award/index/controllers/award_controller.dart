import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/network/award_service.dart';
import 'package:halositek/app/data/network/token_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class AwardController extends GetxController {
  static const int _perPage = 10;

  AwardController(this._awardService);

  final AwardService _awardService;

  final awards = <Award>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;
  final selectedStatus = 'approved'.obs;
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  int _page = 1;
  Timer? _searchDebounce;
  bool _isScrollRefreshRunning = false;

  bool get hasData => awards.isNotEmpty;
  int get approvedCount => awards.where((award) => award.isApproved).length;
  int get pendingCount => awards.where((award) => !award.isApproved).length;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
    fetchAwards(reset: true);
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

  void goBack() {
    Get.find<NavigationController>().onPop();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 8 &&
        !_isScrollRefreshRunning &&
        !isLoading.value) {
      _isScrollRefreshRunning = true;
      fetchAwards(reset: true);
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchAwards(reset: true);
    });
  }

  Future<String?> _getCurrentArchitectId() async {
    final tokenService = Get.find<TokenService>();
    final userId = await tokenService.getUserId();
    final normalized = userId?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  Future<void> fetchAwards({bool reset = false}) async {
    if (!reset && (isLoading.value || isLoadingMore.value)) {
      return;
    }

    if (reset) {
      _page = 1;
      hasMore.value = true;
      awards.clear();
    } else if (!hasMore.value) {
      return;
    }

    try {
      if (reset) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      errorMessage.value = '';
      final architectId = await _getCurrentArchitectId();

      final result = await _awardService.getAwards(
        page: _page,
        perPage: _perPage,
        architectId: architectId,
        status: selectedStatus.value,
        search: searchController.text,
      );

      if (reset) {
        awards.assignAll(result);
      } else {
        awards.addAll(result);
      }

      hasMore.value = result.length == _perPage;
      if (hasMore.value) _page++;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      _isScrollRefreshRunning = false;
    }
  }

  void changeStatus(String? status) {
    if (status == null || status == selectedStatus.value) return;
    selectedStatus.value = status;
    fetchAwards(reset: true);
  }

  void searchAwards(String _) {
    fetchAwards(reset: true);
  }

  void openAdd() {
    Get.find<NavigationController>().navigateTo(tabIndex: 2, route: '/award/add');
  }

  void openDetail(Award award) {
    Get.find<NavigationController>().navigateTo(tabIndex: 2, route: '/award/detail', arguments: award.id);
  }
}
