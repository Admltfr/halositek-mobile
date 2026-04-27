import 'package:get/get.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/data/network/architect_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class HomeController extends GetxController {
  final CatalogService _catalogService;
  final ArchitectService _architectService;

  HomeController(this._catalogService, this._architectService);

  final catalogs = <Catalog>[].obs;
  final isLoadingCatalog = false.obs;
  final catalogError = ''.obs;
  final imageIndexByCatalog = <String, int>{}.obs;

  final architects = <Architect>[].obs;
  final isLoadingArchitect = false.obs;
  final architectError = ''.obs;

  final likingCatalogIds = <String>{}.obs;

  bool isCatalogLiking(String catalogId) =>
      likingCatalogIds.contains(catalogId);

  int getImageIndex(String catalogId) {
    return imageIndexByCatalog[catalogId] ?? 0;
  }

  void setImageIndex(String catalogId, int index) {
    imageIndexByCatalog[catalogId] = index;
  }

  void openDetailsFromHome() {
    final nav = Get.find<NavigationController>();
    nav.navigateTo(tabIndex: 1, route: '/detail');
  }

  void openPortofolioFromHome() {
    final nav = Get.find<NavigationController>();
    nav.navigateTo(tabIndex: 2, route: '/portofolio');
  }

  void openDesignFromHome() {
    final nav = Get.find<NavigationController>();
    nav.changeIndex(1);
  }

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    fetchCatalogs();
    fetchArchitects();
  }

  Future<void> fetchCatalogs() async {
    try {
      isLoadingCatalog.value = true;
      catalogError.value = '';

      final result = await _catalogService.getCatalogs(perPage: 6);
      catalogs.assignAll(result);
    } catch (e) {
      catalogError.value = e.toString();
    } finally {
      isLoadingCatalog.value = false;
    }
  }

  Future<void> fetchArchitects() async {
    try {
      isLoadingArchitect.value = true;
      architectError.value = '';

      final result = await _architectService.getArchitects(perPage: 6);
      architects.assignAll(result);
    } catch (e) {
      architectError.value = e.toString();
    } finally {
      isLoadingArchitect.value = false;
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
