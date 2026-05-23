import 'package:get/get.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/network/award_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class AwardDetailController extends GetxController {
  AwardDetailController(this._awardService, {required this.awardId});

  final AwardService _awardService;
  final String awardId;

  final award = Rxn<Award>();
  final isLoading = false.obs;
  final isDeleting = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAward();
  }

  void goBack() {
    Get.find<NavigationController>().onPop();
  }

  Future<void> fetchAward() async {
    if (awardId.trim().isEmpty) {
      errorMessage.value = 'Award ID tidak ditemukan';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      award.value = await _awardService.getAwardById(awardId);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void openEdit() {
    Get.find<NavigationController>().navigateTo(
      tabIndex: 2,
      route: '/award/edit',
      arguments: award.value ?? awardId,
    );
  }

  Future<void> deleteAward() async {
    final id = award.value?.id ?? awardId;
    if (id.trim().isEmpty || isDeleting.value) return;

    try {
      isDeleting.value = true;
      await _awardService.deleteAward(id);
      Get.find<NavigationController>().onPop();
    } catch (e) {
      Get.snackbar('Delete gagal', e.toString());
    } finally {
      isDeleting.value = false;
    }
  }
}
