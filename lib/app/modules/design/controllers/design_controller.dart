import 'package:get/get.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class DesignController extends GetxController {
  final CatalogService _catalogService;
  DesignController(this._catalogService);

  final catalogs = <Catalog>[].obs;
  final isLoadingCatalog = false.obs;
  final catalogError = ''.obs;
  final imageIndexByCatalog = <String, int>{}.obs;

  final likingCatalogIds = <String>{}.obs;

  bool isCatalogLiking(String catalogId) =>
      likingCatalogIds.contains(catalogId);

  int getImageIndex(String catalogId) {
    return imageIndexByCatalog[catalogId] ?? 0;
  }

  void setImageIndex(String catalogId, int index) {
    imageIndexByCatalog[catalogId] = index;
  }

  void openDetailsFromDesign() {
    final nav = Get.find<NavigationController>();
    nav.navigateTo(tabIndex: 1, route: '/detail');
  }

  @override
  void onInit() {
    super.onInit();
    fetchCatalogs();
  }

  Future<void> fetchCatalogs() async {
    try {
      isLoadingCatalog.value = true;
      catalogError.value = '';

      final result = await _catalogService.getCatalogs(perPage: 12);
      catalogs.assignAll(result);
    } catch (e) {
      catalogError.value = e.toString();
    } finally {
      isLoadingCatalog.value = false;
    }
  }

  Future<void> toggleCatalogLike(String id) async {
    final i = catalogs.indexWhere((e) => e.id == id);
    if (i < 0 || likingCatalogIds.contains(id)) return;

    likingCatalogIds.add(id);

    final prev = catalogs[i];
    final liked = !prev.liked;

    catalogs[i] = prev.copyWith(
      liked: liked,
      likesCount:
          (prev.likesCount + (liked ? 1 : -1))
              .clamp(0, double.infinity)
              .toInt(),
    );
    catalogs.refresh();

    try {
      await (liked
          ? _catalogService.likeCatalog(id)
          : _catalogService.unlikeCatalog(id));
    } catch (e) {
      catalogs[i] = prev;
      catalogs.refresh();
    } finally {
      likingCatalogIds.remove(id);
    }
  }
}
