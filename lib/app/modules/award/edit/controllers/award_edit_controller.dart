import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/network/award_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

class AwardEditController extends GetxController {
  AwardEditController(
    this._awardService, {
    required this.awardId,
    this.initialAward,
  });

  final AwardService _awardService;
  final String awardId;
  final Award? initialAward;

  final nameController = TextEditingController();
  final projectController = TextEditingController();
  final dateController = TextEditingController();
  final roleController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedDate = Rxn<DateTime>();
  final award = Rxn<Award>();
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  String get resolvedAwardId => award.value?.id ?? initialAward?.id ?? awardId;
  String get fileName {
    final current = award.value ?? initialAward;
    return current?.verificationFile.isNotEmpty == true
        ? current!.verificationFile
        : '';
  }

  @override
  void onInit() {
    super.onInit();
    if (initialAward != null) {
      _fill(initialAward!);
    } else {
      fetchAward();
    }
  }

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

  Future<void> fetchAward() async {
    if (awardId.trim().isEmpty) return;

    try {
      isLoading.value = true;
      _fill(await _awardService.getAwardById(awardId));
    } catch (e) {
      Get.snackbar('Award gagal dimuat', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _fill(Award value) {
    award.value = value;
    nameController.text = value.name;
    projectController.text = value.projectName;
    roleController.text = value.role;
    descriptionController.text = value.description;
    selectedDate.value = value.awardDate;
    if (value.awardDate != null) {
      dateController.text = _displayDate(value.awardDate!);
    }
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
    if (isSubmitting.value || resolvedAwardId.trim().isEmpty) return;

    try {
      isSubmitting.value = true;
      await _awardService.updateAward(resolvedAwardId, _payload());
      Get.find<NavigationController>().onPop();
    } catch (e) {
      Get.snackbar('Award gagal diubah', e.toString());
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
