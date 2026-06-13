import 'package:get/get.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/catalog_service.dart';

import '../controllers/design_edit_controller.dart';

class DesignEditBinding extends Bindings {
  DesignEditBinding({this.catalogId = '', this.initialCatalog});

  final String catalogId;
  final Catalog? initialCatalog;

  @override
  void dependencies() {
    if (!Get.isRegistered<CatalogService>()) {
      Get.lazyPut<CatalogService>(() => CatalogService(Get.find<ApiClient>()));
    }

    String resolvedCatalogId = catalogId;
    Catalog? resolvedCatalog = initialCatalog;
    final arguments = Get.arguments;

    if (resolvedCatalog == null && arguments is Catalog) {
      resolvedCatalog = arguments;
      resolvedCatalogId = arguments.id;
    } else if (arguments is String) {
      resolvedCatalogId = arguments;
    } else if (arguments is Map) {
      resolvedCatalogId = (arguments['id'] ?? '').toString();
      final rawCatalog = arguments['catalog'];
      if (rawCatalog is Catalog) resolvedCatalog = rawCatalog;
    }

    Get.lazyPut<DesignEditController>(
      () => DesignEditController(
        Get.find<CatalogService>(),
        catalogId: resolvedCatalogId,
        initialCatalog: resolvedCatalog,
      ),
    );
  }
}
