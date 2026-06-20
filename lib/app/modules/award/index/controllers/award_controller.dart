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
  final selectedStatus = 'all'.obs;
  final totalApproved = 0.obs;
  final totalPending = 0.obs;
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  int _page = 1;
  Timer? _searchDebounce;
  bool _isScrollRefreshRunning = false;

  bool get hasData => awards.isNotEmpty;
  int get approvedCount => totalApproved.value;
  int get pendingCount => totalPending.value;

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
        !isLoading.value &&
        !isLoadingMore.value &&
        hasMore.value) {
      _isScrollRefreshRunning = true;
      fetchAwards();
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
      if (reset) {
        await _fetchAwardTotals(
          architectId: architectId,
          search: searchController.text,
        );
      }

      final result = await _awardService.getAwardList(
        page: _page,
        perPage: _perPage,
        architectId: architectId,
        status: _statusQuery,
        search: searchController.text,
      );

      if (reset) {
        awards.assignAll(result.awards);
      } else {
        awards.addAll(result.awards);
      }

      hasMore.value = result.meta.currentPage < result.meta.lastPage;
      if (hasMore.value) _page++;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      _isScrollRefreshRunning = false;
    }
  }

  String? get _statusQuery {
    if (selectedStatus.value == 'all') return null;
    return selectedStatus.value;
  }

  Future<void> _fetchAwardTotals({
    required String? architectId,
    required String search,
  }) async {
    final result = await _awardService.getAwardList(
      page: 1,
      perPage: 1,
      architectId: architectId,
      search: search,
    );
    totalApproved.value = result.meta.approvedCount;
    totalPending.value = result.meta.pendingCount;
  }

  void changeStatus(String? status) {
    if (status == null || status == selectedStatus.value) return;
    selectedStatus.value = status;
    fetchAwards(reset: true);
  }

  void searchAwards(String _) {
    fetchAwards(reset: true);
  }

  Future<void> openAdd() async {
    final nav = Get.find<NavigationController>().keyForTab(2)?.currentState;
    if (nav == null) return;
    final popped = await nav.pushNamed('/award/add');
    if (popped != null || !isLoading.value) {
      await fetchAwards(reset: true);
    }
  }

  Future<void> openDetail(Award award) async {
    final nav = Get.find<NavigationController>().keyForTab(2)?.currentState;
    if (nav == null) return;
    final popped = await nav.pushNamed('/award/detail', arguments: award.id);
    if (popped != null || !isLoading.value) {
      await fetchAwards(reset: true);
    }
  }
}
