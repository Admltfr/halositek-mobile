import 'package:get/get.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class DetailController extends GetxController {
  final CatalogService _catalogService;
  final String catalogId;

  DetailController(this._catalogService, {required this.catalogId});

  final catalog = Rxn<Catalog>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final activeImageIndex = 0.obs;
  final activeLayoutIndex = 0.obs;
  final isLiking = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCatalogDetail();
  }

  void goBack() {
    final nav = Get.find<NavigationController>();
    nav.onPop();
  }

  Future<void> fetchCatalogDetail() async {
    if (catalogId.trim().isEmpty) {
      errorMessage.value = 'Project ID tidak ditemukan';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _catalogService.getCatalogById(catalogId);
      catalog.value = result;
      activeImageIndex.value = 0;
      activeLayoutIndex.value = 0;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike() async {
    final current = catalog.value;
    if (current == null || current.id.isEmpty || isLiking.value) return;

    isLiking.value = true;

    final liked = !current.liked;
    catalog.value = current.copyWith(
      liked: liked,
      likesCount: (current.likesCount + (liked ? 1 : -1)).clamp(0, 999999),
    );

    try {
      if (liked) {
        await _catalogService.likeCatalog(current.id);
      } else {
        await _catalogService.unlikeCatalog(current.id);
      }
    } catch (_) {
      catalog.value = current;
    } finally {
      isLiking.value = false;
    }
  }

  void setActiveImageIndex(int index) {
    activeImageIndex.value = index;
  }

  void setActiveLayoutIndex(int index) {
    activeLayoutIndex.value = index;
  }

  List<String> get projectImages {
    final p = catalog.value;
    if (p == null) return const <String>[];
    return p.imageUrls.isNotEmpty ? p.imageUrls : p.images;
  }

  List<String> get projectLayoutImages {
    final p = catalog.value;
    if (p == null) return const <String>[];
    return p.layoutImageUrls.isNotEmpty ? p.layoutImageUrls : p.layoutImages;
  }

  String get architectName {
    final p = catalog.value;
    return p?.architect?.name.isNotEmpty == true ? p!.architect!.name : '-';
  }

  String get architectEmail {
    final p = catalog.value;
    return p?.architect?.email.isNotEmpty == true ? p!.architect!.email : '-';
  }

  String get areaDisplay {
    final p = catalog.value;
    if (p == null || p.areaRaw.trim().isEmpty) return '-';
    return p.areaRaw;
  }

  String get estimatedCostDisplay {
    final p = catalog.value;
    if (p == null || p.estimatedCost.trim().isEmpty) return '-';
    return p.estimatedCost;
  }
}
