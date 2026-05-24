import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/network/token_service.dart';

class NavigationController extends GetxController {
  final TokenService _tokenService;

  NavigationController(this._tokenService);

  final RxInt currentIndex = 0.obs;
  final RxString role = ''.obs;

  final navigatorKeys = List.generate(4, (index) => Get.nestedKey(index + 1));
  final architectTabKey = Get.nestedKey(30);
  final awardTabKey = Get.nestedKey(31);

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments != null && arguments is int) {
      currentIndex.value = arguments;
    }

    loadRole();
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> loadRole() async {
    role.value = (await _tokenService.getRole() ?? '').trim().toLowerCase();
  }

  bool get isArchitect => role.value.trim().toLowerCase() == 'architect';

  GlobalKey<NavigatorState>? keyForTab(int index) {
    if (index == 2) {
      return isArchitect ? awardTabKey : architectTabKey;
    }
    return navigatorKeys[index];
  }

  void changeIndex(int index) {
    if (currentIndex.value == index) {
      final nav = keyForTab(index)?.currentState;

      if (nav != null) {
        nav.popUntil((route) => route.isFirst);
      }

      return;
    }
    currentIndex.value = index;
  }

  Future<bool> onPop() async {
    final nav = keyForTab(currentIndex.value)?.currentState;

    if (nav != null && nav.canPop()) {
      nav.pop();
      return false;
    }

    if (currentIndex.value != 0) {
      currentIndex.value = 0;
      return false;
    }

    return true;
  }

  void navigateTo({required int tabIndex, String? route, Object? arguments}) {
    changeIndex(tabIndex);

    if (route != null) {
      keyForTab(tabIndex)?.currentState?.pushNamed(route, arguments: arguments);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
