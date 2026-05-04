import 'package:get/get.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/award_service.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class PortofolioController extends GetxController {
  final CatalogService _catalogService;
  final AwardService _awardService;

  PortofolioController(this._catalogService, this._awardService);

  final activeTab = 0.obs;

  final portfolios = <Catalog>[].obs;
  final awards = <Award>[].obs;

  final isLoadingPortfolio = false.obs;
  final isLoadingAward = false.obs;
  final portfolioError = ''.obs;
  final awardError = ''.obs;

  final architectId = ''.obs;
  final architectName = 'David Larsson'.obs;
  final architectTitle = 'Principal Architect'.obs;
  final experienceLabel = "15 Years Experience".obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      architectId.value = (args['architectId'] ?? '').toString();
      architectName.value = (args['name'] ?? architectName.value).toString();
      architectTitle.value =
          (args['headline'] ?? architectTitle.value).toString();
    } else if (args is String) {
      architectId.value = args;
    }

    fetchPortfolios();
    fetchAwards();
  }

  void setTab(int index) => activeTab.value = index;

  void goBack() {
    final nav = Get.find<NavigationController>();
    nav.onPop();
  }

  Future<void> fetchPortfolios() async {
    try {
      isLoadingPortfolio.value = true;
      portfolioError.value = '';
      final result = await _catalogService.getCatalogs(
        perPage: 12,
        architectId: architectId.value,
      );
      portfolios.assignAll(result);
    } catch (e) {
      portfolioError.value = e.toString();
    } finally {
      isLoadingPortfolio.value = false;
    }
  }

  Future<void> fetchAwards() async {
    try {
      isLoadingAward.value = true;
      awardError.value = '';
      final result = await _awardService.getAwards(
        perPage: 12,
        architectId: architectId.value,
      );
      awards.assignAll(result);
    } catch (e) {
      awardError.value = e.toString();
    } finally {
      isLoadingAward.value = false;
    }
  }
}
