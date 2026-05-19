import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:halositek/app/modules/architect/bindings/architect_binding.dart';
import 'package:halositek/app/modules/architect/views/architect_view.dart';
import 'package:halositek/app/modules/chat_detail/bindings/chat_detail_binding.dart';
import 'package:halositek/app/modules/chat_detail/views/chat_detail_view.dart';
import 'package:halositek/app/modules/chat_list/bindings/chat_list_binding.dart';
import 'package:halositek/app/modules/chat_list/views/chat_list_view.dart';
import 'package:halositek/app/modules/design/bindings/design_binding.dart';
import 'package:halositek/app/modules/design/views/design_view.dart';
import 'package:halositek/app/modules/detail/bindings/detail_binding.dart';
import 'package:halositek/app/modules/detail/views/detail_view.dart';
import 'package:halositek/app/modules/home/bindings/home_binding.dart';
import 'package:halositek/app/modules/home/views/home_view.dart';
import 'package:halositek/app/modules/portofolio/views/portofolio_view.dart';
import 'package:halositek/app/modules/portofolio/bindings/portofolio_binding.dart';
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
    } else if (settings.name == _TabRoutes.chatList) {
      return GetPageRoute(
        routeName: _TabRoutes.chatList,
        page: () => const ChatListView(),
        binding: ChatListBinding(),
      );
    } else if (settings.name == _TabRoutes.chatDetail) {
      final arg = settings.arguments;
      final conversationId =
          arg is Map ? (arg['conversationId'] ?? '').toString() : '';
      final title = arg is Map ? (arg['title'] ?? '').toString() : '';

      return GetPageRoute(
        routeName: _TabRoutes.chatDetail,
        page: () => const ChatDetailView(),
        binding: ChatDetailBinding(
          conversationId: conversationId,
          title: title,
        ),
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
    } else if (settings.name == _TabRoutes.detail) {
      final arg = settings.arguments;
      final catalogId = arg is String ? arg : '';

      return GetPageRoute(
        routeName: _TabRoutes.detail,
        page: () => const DetailView(),
        binding: DetailBinding(catalogId: catalogId),
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
    } else if (settings.name == _TabRoutes.portofolio) {
      return GetPageRoute(
        routeName: _TabRoutes.portofolio,
        page: () => const PortofolioView(),
        binding: PortofolioBinding(),
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
  static const portofolio = '/portofolio';
  static const chatList = '/chats';
  static const chatDetail = '/chat';
}
