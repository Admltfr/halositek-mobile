import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:halositek/app/modules/architect/bindings/architect_binding.dart';
import 'package:halositek/app/modules/architect/views/architect_view.dart';
import 'package:halositek/app/modules/award/add/bindings/award_add_binding.dart';
import 'package:halositek/app/modules/award/add/views/award_add_view.dart';
import 'package:halositek/app/modules/award/detail/bindings/award_detail_binding.dart';
import 'package:halositek/app/modules/award/detail/views/award_detail_view.dart';
import 'package:halositek/app/modules/award/edit/bindings/award_edit_binding.dart';
import 'package:halositek/app/modules/award/edit/views/award_edit_view.dart';
import 'package:halositek/app/modules/award/index/bindings/award_binding.dart';
import 'package:halositek/app/modules/award/index/views/award_view.dart';
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
import 'package:halositek/app/modules/profile/edit/bindings/profile_edit_binding.dart';
import 'package:halositek/app/modules/profile/edit/views/profile_edit_view.dart';
import 'package:halositek/app/modules/profile/views/payment_history_view.dart';
import 'package:halositek/app/modules/profile/views/profile_view.dart';
import 'package:halositek/app/modules/profile/views/saved_architects_view.dart';
import 'package:halositek/app/modules/profile/views/saved_designs_view.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/models/architect.dart';

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
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Dashboard',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Design',
              ),
              controller.isArchitect
                  ? const BottomNavigationBarItem(
                    icon: Icon(Icons.workspace_premium_outlined),
                    activeIcon: Icon(Icons.workspace_premium),
                    label: 'Awards',
                  )
                  : const BottomNavigationBarItem(
                    icon: Icon(Icons.architecture_outlined),
                    activeIcon: Icon(Icons.architecture),
                    label: 'Architect',
                  ),
              const BottomNavigationBarItem(
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
    final navigatorKey = ValueKey(
      tabIndex == 2
          ? 'tab-2-${controller.isArchitect ? 'architect' : 'user'}'
          : 'tab-$tabIndex',
    );

    return KeyedSubtree(
      key: navigatorKey,
      child: Navigator(
        key: controller.keyForTab(tabIndex),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (tabIndex) {
            case 0:
              return _homeRoutes(settings);
            case 1:
              return _designRoutes(settings);
            case 2:
              return controller.isArchitect
                  ? _awardRoutes(settings)
                  : _architectRoutes(settings);
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
      final arg = settings.arguments;
      final architectId = arg is String ? arg : '';
      return GetPageRoute(
        routeName: _TabRoutes.portofolio,
        page: () => const PortofolioView(),
        binding: PortofolioBinding(architectId: architectId),
      );
    }

    return _fallbackRoute('Unknown Architect route');
  }

  Route<dynamic> _awardRoutes(RouteSettings settings) {
    if (settings.name == _TabRoutes.root) {
      return GetPageRoute(
        routeName: _TabRoutes.root,
        page: () => const AwardView(),
        binding: AwardBinding(),
      );
    } else if (settings.name == _TabRoutes.awardDetail) {
      final arg = settings.arguments;
      final awardId = arg is String ? arg : '';

      return GetPageRoute(
        routeName: _TabRoutes.awardDetail,
        page: () => const AwardDetailView(),
        binding: AwardDetailBinding(awardId: awardId),
      );
    } else if (settings.name == _TabRoutes.awardAdd) {
      return GetPageRoute(
        routeName: _TabRoutes.awardAdd,
        page: () => const AwardAddView(),
        binding: AwardAddBinding(),
      );
    } else if (settings.name == _TabRoutes.awardEdit) {
      final arg = settings.arguments;
      final initialAward = arg is Award ? arg : null;
      final awardId = arg is String ? arg : initialAward?.id ?? '';

      return GetPageRoute(
        routeName: _TabRoutes.awardEdit,
        page: () => const AwardEditView(),
        binding: AwardEditBinding(awardId: awardId, initialAward: initialAward),
      );
    }

    return _fallbackRoute('Unknown Award route');
  }

  Route<dynamic> _profileRoutes(RouteSettings settings) {
    if (settings.name == _TabRoutes.root) {
      return GetPageRoute(
        routeName: _TabRoutes.root,
        page: () => const ProfileView(),
        binding: ProfileBinding(),
      );
    } else if (settings.name == _TabRoutes.profileEdit) {
      if (!controller.isArchitect) {
        return _fallbackRoute('Edit Profile hanya tersedia untuk architect');
      }

      final arg = settings.arguments;
      final initialArchitect = arg is Architect ? arg : null;

      return GetPageRoute(
        routeName: _TabRoutes.profileEdit,
        page: () => const ProfileEditView(),
        binding: ProfileEditBinding(initialArchitect: initialArchitect),
      );
    } else if (settings.name == _TabRoutes.savedArchitects) {
      return GetPageRoute(
        routeName: _TabRoutes.savedArchitects,
        page: () => const SavedArchitectsView(),
      );
    } else if (settings.name == _TabRoutes.savedDesigns) {
      return GetPageRoute(
        routeName: _TabRoutes.savedDesigns,
        page: () => const SavedDesignsView(),
      );
    } else if (settings.name == _TabRoutes.paymentHistory) {
      return GetPageRoute(
        routeName: _TabRoutes.paymentHistory,
        page: () => const PaymentHistoryView(),
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
  static const awardDetail = '/award/detail';
  static const awardAdd = '/award/add';
  static const awardEdit = '/award/edit';
  static const profileEdit = '/profile/edit';
  static const savedArchitects = '/profile/saved-architects';
  static const savedDesigns = '/profile/saved-designs';
  static const paymentHistory = '/profile/payment-history';
}
