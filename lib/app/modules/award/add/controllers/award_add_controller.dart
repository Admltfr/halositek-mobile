import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/network/award_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class AwardAddController extends GetxController {
  AwardAddController(this._awardService);

  final AwardService _awardService;

  final nameController = TextEditingController();
  final projectController = TextEditingController();
  final dateController = TextEditingController();
  final roleController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedDate = Rxn<DateTime>();
  final isSubmitting = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    projectController.dispose();
    dateController.dispose();
    roleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void goBack() {
    Get.find<NavigationController>().onPop();
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? now,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 10),
    );

    if (picked == null) return;
    selectedDate.value = picked;
    dateController.text = _displayDate(picked);
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;

    try {
      isSubmitting.value = true;
      await _awardService.createAward(_payload());
      Get.find<NavigationController>().onPop();
    } catch (e) {
      Get.snackbar('Award gagal disimpan', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  Map<String, dynamic> _payload() {
    return {
      'name': nameController.text.trim(),
      'project_name': projectController.text.trim(),
      'role': roleController.text.trim(),
      'award_date': selectedDate.value?.toIso8601String(),
      'description': descriptionController.text.trim(),
    };
  }

  String _displayDate(DateTime value) {
    return '${value.month.toString().padLeft(2, '0')}/'
        '${value.day.toString().padLeft(2, '0')}/${value.year}';
  }
}
