import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/network/token_service.dart';
import 'app/routes/app_pages.dart';
import 'app/data/network/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  final ApiClient apiClient = ApiClient();
  final TokenService tokenService = TokenService();

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      initialBinding: BindingsBuilder(() {
        Get.put(tokenService, permanent: true);
        Get.lazyPut<ApiClient>(() => apiClient, fenix: true);
      }),
      getPages: AppPages.routes,
    ),
  );
}
