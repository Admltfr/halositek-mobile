import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';

import '../modules/architect/bindings/architect_binding.dart';
import '../modules/architect/views/architect_view.dart';
import '../modules/award/add/bindings/award_add_binding.dart';
import '../modules/award/add/views/award_add_view.dart';
import '../modules/award/detail/bindings/award_detail_binding.dart';
import '../modules/award/detail/views/award_detail_view.dart';
import '../modules/award/edit/bindings/award_edit_binding.dart';
import '../modules/award/edit/views/award_edit_view.dart';
import '../modules/award/index/bindings/award_binding.dart';
import '../modules/award/index/views/award_view.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';
import '../modules/chat_detail/bindings/chat_detail_binding.dart';
import '../modules/chat_detail/views/chat_detail_view.dart';
import '../modules/chat_list/bindings/chat_list_binding.dart';
import '../modules/chat_list/views/chat_list_view.dart';
import '../modules/design/bindings/design_binding.dart';
import '../modules/design/views/design_view.dart';
import '../modules/detail/bindings/detail_binding.dart';
import '../modules/detail/views/detail_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/navigation/bindings/navigation_binding.dart';
import '../modules/navigation/views/navigation_view.dart';
import '../modules/portofolio/bindings/portofolio_binding.dart';
import '../modules/portofolio/views/portofolio_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/ai_chat/bindings/ai_chat_binding.dart';
import '../modules/ai_chat/views/ai_chat_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.NAVIGATION,
      page: () => const NavigationView(),
      binding: NavigationBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.DESIGN,
      page: () => const DesignView(),
      binding: DesignBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.ARCHITECT,
      page: () => const ArchitectView(),
      binding: ArchitectBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.AWARD,
      page: () => const AwardView(),
      binding: AwardBinding(),
      transition: Transition.fadeIn,
    ).withRole(['architect']),
    GetPage(
      name: _Paths.AWARD_DETAIL,
      page: () => const AwardDetailView(),
      binding: AwardDetailBinding(),
      transition: Transition.fadeIn,
    ).withRole(['architect']),
    GetPage(
      name: _Paths.AWARD_ADD,
      page: () => const AwardAddView(),
      binding: AwardAddBinding(),
      transition: Transition.fadeIn,
    ).withRole(['architect']),
    GetPage(
      name: _Paths.AWARD_EDIT,
      page: () => const AwardEditView(),
      binding: AwardEditBinding(),
      transition: Transition.fadeIn,
    ).withRole(['architect']),
    GetPage(
      name: _Paths.DETAIL,
      page: () => const DetailView(),
      binding: DetailBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.PORTOFOLIO,
      page: () => const PortofolioView(),
      binding: PortofolioBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.CHAT_LIST,
      page: () => const ChatListView(),
      binding: ChatListBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_DETAIL,
      page: () => const ChatDetailView(),
      binding: ChatDetailBinding(),
    ),
    GetPage(
      name: _Paths.AI_CHAT,
      page: () => const AiChatView(),
      binding: AiChatBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
