import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
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
  final selectedFile = Rxn<PlatformFile>();
  final isSubmitting = false.obs;

  String get fileName => selectedFile.value?.name ?? '';
  String get fileSizeLabel => _formatBytes(selectedFile.value?.size ?? 0);

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
    final error = _validate();
    if (error != null) {
      Get.snackbar('Form belum lengkap', error);
      return;
    }

    try {
      isSubmitting.value = true;
      await _awardService.createAward(await _payload());
      Get.find<NavigationController>().onPop();
    } catch (e) {
      Get.snackbar('Award gagal disimpan', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );

    final file = result?.files.single;
    if (file == null) return;

    if (file.path == null || file.path!.isEmpty) {
      Get.snackbar(
        'File tidak valid',
        'File tidak bisa dibaca dari perangkat ini.',
      );
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      Get.snackbar('File terlalu besar', 'Maksimal ukuran file adalah 5 MB.');
      return;
    }

    selectedFile.value = file;
  }

  void removeFile() {
    selectedFile.value = null;
  }

  Future<dio.FormData> _payload() async {
    final date = selectedDate.value!;
    final file = selectedFile.value!;

    return dio.FormData.fromMap({
      'name': nameController.text.trim(),
      'project_name': projectController.text.trim(),
      'role': roleController.text.trim(),
      'award_date': _apiDate(date),
      'description': descriptionController.text.trim(),
      'verification_file': await dio.MultipartFile.fromFile(
        file.path!,
        filename: file.name,
      ),
    });
  }

  String? _validate() {
    if (nameController.text.trim().isEmpty) return 'Award name wajib diisi.';
    if (_wordCount(nameController.text) > 12) {
      return 'Award name maksimal 12 kata.';
    }
    if (projectController.text.trim().isEmpty) {
      return 'Project name wajib diisi.';
    }
    if (_wordCount(projectController.text) > 12) {
      return 'Project name maksimal 12 kata.';
    }
    if (selectedDate.value == null) return 'Award date wajib dipilih.';
    if (roleController.text.trim().isEmpty) return 'Role wajib diisi.';
    if (_wordCount(descriptionController.text) > 30) {
      return 'Award description maksimal 30 kata.';
    }
    if (selectedFile.value == null) return 'Verification proof wajib diupload.';
    return null;
  }

  int _wordCount(String value) {
    return value.trim().isEmpty ? 0 : value.trim().split(RegExp(r'\s+')).length;
  }

  String _apiDate(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  String _displayDate(DateTime value) {
    return '${value.month.toString().padLeft(2, '0')}/'
        '${value.day.toString().padLeft(2, '0')}/${value.year}';
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '';
    final mb = bytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
}
