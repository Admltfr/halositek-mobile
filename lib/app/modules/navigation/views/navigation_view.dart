import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:halositek/app/modules/architect/bindings/architect_binding.dart';
import 'package:halositek/app/modules/architect/views/architect_view.dart';
import 'package:halositek/app/modules/design/bindings/design_binding.dart';
import 'package:halositek/app/modules/design/views/design_view.dart';
import 'package:halositek/app/modules/home/bindings/home_binding.dart';
import 'package:halositek/app/modules/home/views/home_view.dart';
import 'package:halositek/app/modules/profile/bindings/profile_binding.dart';
import 'package:halositek/app/modules/profile/views/profile_view.dart';
import 'package:halositek/app/core/constants/app_colors.dart';

import '../controllers/navigation_controller.dart';

class NavigationView extends GetView<NavigationController> {
  const NavigationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didpop, result) async {
          if (didpop) return;

          final canExit = await controller.onPop();

          if (canExit) {
            Get.back(); // SystemNavigator.pop() ???? Need testing
          }
        },
        child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeIndex,
            selectedItemColor: AppColors.primaryColor,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Design',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.architecture_outlined),
                activeIcon: Icon(Icons.architecture),
                label: 'Architect',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: [
              _buildNavigator(
                tabIndex: 0,
                active: controller.currentIndex.value == 0,
              ),
              _buildNavigator(
                tabIndex: 1,
                active: controller.currentIndex.value == 1,
              ),
              _buildNavigator(
                tabIndex: 2,
                active: controller.currentIndex.value == 2,
              ),
              _buildNavigator(
                tabIndex: 3,
                active: controller.currentIndex.value == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigator({required int tabIndex, required bool active}) {
    return Offstage(
      offstage: !active,
      child: Navigator(
        key: controller.navigatorKeys[tabIndex],
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (tabIndex) {
            case 0:
              return _homeRoutes(settings);
            case 1:
              return _designRoutes(settings);
            case 2:
              return _architectRoutes(settings);
            case 3:
              return _profileRoutes(settings);
            default:
              return _fallbackRoute('Unknown tab');
          }
        },
      ),
    );
  }

  Route<dynamic> _homeRoutes(RouteSettings settings) {
    if (settings.name == _TabRoutes.root) {
      return GetPageRoute(
        routeName: _TabRoutes.root,
        page: () => const HomeView(),
        binding: HomeBinding(),
      );
    }

    return _fallbackRoute('Unknown Home route');
  }

  Route<dynamic> _designRoutes(RouteSettings settings) {
    if (settings.name == _TabRoutes.root) {
      return GetPageRoute(
        routeName: _TabRoutes.root,
        page: () => const DesignView(),
        binding: DesignBinding(),
      );
    }

    return _fallbackRoute('Unknown Design route');
  }

  Route<dynamic> _architectRoutes(RouteSettings settings) {
    if (settings.name == _TabRoutes.root) {
      return GetPageRoute(
        routeName: _TabRoutes.root,
        page: () => const ArchitectView(),
        binding: ArchitectBinding(),
      );
    }

    return _fallbackRoute('Unknown Architect route');
  }

  Route<dynamic> _profileRoutes(RouteSettings settings) {
    if (settings.name == _TabRoutes.root) {
      return GetPageRoute(
        routeName: _TabRoutes.root,
        page: () => const ProfileView(),
        binding: ProfileBinding(),
      );
    }

    return _fallbackRoute('Unknown Profile route');
  }

  Route<dynamic> _fallbackRoute(String message) {
    return GetPageRoute(
      page: () => Scaffold(body: Center(child: Text(message))),
    );
  }
}

class _TabRoutes {
  static const root = '/';
  static const detail = '/detail';
}
