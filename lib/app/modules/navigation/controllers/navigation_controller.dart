import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  final navigatorKeys = List.generate(4, (index) {
    return Get.nestedKey(index + 1);
  });

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments != null && arguments is int) {
      currentIndex.value = arguments;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  void changeIndex(int index) {
    if (currentIndex.value == index) {
      final nav = navigatorKeys[index]?.currentState;

      if (nav != null) {
        nav.popUntil((route) => route.isFirst);
      }

      return;
    }
    currentIndex.value = index;
  }

  Future<bool> onPop() async {
    final nav = navigatorKeys[currentIndex.value]?.currentState;

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
      navigatorKeys[tabIndex]?.currentState?.pushNamed(
        route,
        arguments: arguments,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
