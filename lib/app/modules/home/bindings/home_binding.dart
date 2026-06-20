import 'package:get/get.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/auth_service.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/data/network/architect_service.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/data/network/dashboard_service.dart';
import 'package:halositek/app/data/network/token_service.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatalogService>(() => CatalogService(Get.find<ApiClient>()));
    Get.lazyPut<ArchitectService>(
      () => ArchitectService(Get.find<ApiClient>()),
    );
    Get.lazyPut<ChatService>(() => ChatService(Get.find<ApiClient>()));
    Get.lazyPut<DashboardService>(
      () => DashboardService(Get.find<ApiClient>()),
    );
    Get.lazyPut<AuthService>(
      () => AuthService(Get.find<ApiClient>(), Get.find<TokenService>()),
    );

    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<CatalogService>(),
        Get.find<ArchitectService>(),
        Get.find<ChatService>(),
        Get.find<DashboardService>(),
        Get.find<AuthService>(),
      ),
    );
  }
}
