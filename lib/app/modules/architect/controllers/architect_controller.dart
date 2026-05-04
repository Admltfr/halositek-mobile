import 'package:get/get.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/network/architect_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class ArchitectController extends GetxController {
  final ArchitectService _architectService;

  ArchitectController(this._architectService);

  final architects = <Architect>[].obs;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  bool get hasData => architects.isNotEmpty;

  void goBack() {
    final nav = Get.find<NavigationController>();
    nav.onPop();
  }

  @override
  void onInit() {
    super.onInit();
    fetchArchitects();
  }

  Future<void> fetchArchitects() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _architectService.getArchitects(perPage: 12);
      architects.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  int projectCompletedCount(Architect architect) {
    return architect.totalProjects;
  }

  void openPortofolio(Architect architect) {
    final nav = Get.find<NavigationController>();
    nav.navigateTo(
      tabIndex: 2,
      route: '/portofolio',
      arguments: {
        'architectId': architect.id,
        'name': architect.name,
        'headline': architect.headline,
        'profile_picture': architect.profilePicture,
      },
    );
  }

  int hiddenProjectsCount(Architect architect) {
    final total = projectCompletedCount(architect);
    if (total <= 2) return 0;
    return total - 2;
  }
}
