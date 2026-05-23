import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/network/award_service.dart';
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

  bool get hasData => awards.isNotEmpty;
  int get approvedCount => awards.where((award) => award.isApproved).length;
  int get pendingCount => awards.where((award) => !award.isApproved).length;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchAwards(reset: true);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void goBack() {
    Get.find<NavigationController>().onPop();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final triggerPoint = scrollController.position.maxScrollExtent - 200;
    if (scrollController.position.pixels >= triggerPoint) {
      fetchAwards();
    }
  }

  Future<void> fetchAwards({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasMore.value = true;
      awards.clear();
    } else if (!hasMore.value || isLoading.value || isLoadingMore.value) {
      return;
    }

    try {
      if (reset) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      errorMessage.value = '';

      final result = await _awardService.getAwards(
        page: _page,
        perPage: _perPage,
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
    Get.find<NavigationController>().navigateTo(
      tabIndex: 2,
      route: '/award/add',
    );
  }

  void openDetail(Award award) {
    Get.find<NavigationController>().navigateTo(
      tabIndex: 2,
      route: '/award/detail',
      arguments: award.id,
    );
  }
}
