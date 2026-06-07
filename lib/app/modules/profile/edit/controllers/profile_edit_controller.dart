import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/network/architect_service.dart';
import 'package:halositek/app/data/network/token_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';
import 'package:halositek/app/modules/profile/controllers/profile_controller.dart';

class ProfileEditController extends GetxController {
  ProfileEditController(
    this._architectService,
    this._tokenService, {
    this.initialArchitect,
  });

  final ArchitectService _architectService;
  final TokenService _tokenService;
  final Architect? initialArchitect;

  final nameController = TextEditingController();
  final headlineController = TextEditingController();
  final bioController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController(text: '************');
  final experienceController = TextEditingController();
  final feeController = TextEditingController();
  final durationController = TextEditingController();

  final architect = Rxn<Architect>();
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final userId = ''.obs;

  String get architectId =>
      architect.value?.id ?? initialArchitect?.id ?? userId.value;

  @override
  void onInit() {
    super.onInit();
    if (initialArchitect != null) {
      _fill(initialArchitect!);
    }
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    headlineController.dispose();
    bioController.dispose();
    emailController.dispose();
    passwordController.dispose();
    experienceController.dispose();
    feeController.dispose();
    durationController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    userId.value = await _tokenService.getUserId() ?? '';
    final id = architectId.trim();
    if (id.isEmpty || initialArchitect != null) return;

    try {
      isLoading.value = true;
      _fill(await _architectService.getArchitectById(id));
    } catch (e) {
      Get.snackbar('Profile gagal dimuat', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    Get.find<NavigationController>().onPop();
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    final id = architectId.trim();
    if (id.isEmpty) {
      Get.snackbar('Profile gagal disimpan', 'Architect id tidak ditemukan.');
      return;
    }

    final error = _validate();
    if (error != null) {
      Get.snackbar('Form belum lengkap', error);
      return;
    }

    try {
      isSubmitting.value = true;
      final updated = await _architectService.updateArchitect(id, _payload());
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().architect.value = updated;
      }
      Get.find<NavigationController>().onPop();
      Get.snackbar('Profile tersimpan', 'Perubahan profile berhasil disimpan.');
    } catch (e) {
      Get.snackbar('Profile gagal disimpan', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  void _fill(Architect value) {
    architect.value = value;
    nameController.text = value.name;
    headlineController.text = value.headline;
    bioController.text = value.bio;
    emailController.text = value.email;
    experienceController.text = '';
    feeController.text =
        value.consultationFee > 0 ? value.consultationFee.toString() : '';
    durationController.text =
        value.consultationDuration > 0
            ? value.consultationDuration.toString()
            : '';
  }

  Map<String, dynamic> _payload() {
    return {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'headline': headlineController.text.trim(),
      'bio': bioController.text.trim(),
      'consultation_fee': _digitsOnly(feeController.text),
      'consultation_duration':
          int.tryParse(durationController.text.trim()) ?? 0,
    };
  }

  String? _validate() {
    if (nameController.text.trim().isEmpty) return 'Full name wajib diisi.';
    if (headlineController.text.trim().isEmpty) {
      return 'Professional title wajib diisi.';
    }
    if (bioController.text.trim().isEmpty) return 'Bio wajib diisi.';
    if (!GetUtils.isEmail(emailController.text.trim())) {
      return 'Email address tidak valid.';
    }
    if (_digitsOnly(feeController.text) <= 0) return 'Fee wajib diisi.';
    if ((int.tryParse(durationController.text.trim()) ?? 0) <= 0) {
      return 'Durasi sesi wajib diisi.';
    }
    return null;
  }

  int _digitsOnly(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }
}
