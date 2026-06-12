import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/network/architect_service.dart';
import 'package:halositek/app/data/network/token_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';
import 'package:halositek/app/modules/profile/controllers/profile_controller.dart';

class ProfileEditController extends GetxController {
  ProfileEditController(this._architectService, this._tokenService, {this.initialArchitect});

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
  final selectedPhoto = Rxn<PlatformFile>();
  final fieldErrors = <String, String>{}.obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final userId = ''.obs;

  String get architectId => architect.value?.id ?? initialArchitect?.id ?? userId.value;

  @override
  void onInit() {
    super.onInit();
    _attachRevalidators();
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

    if (!_validate()) {
      return;
    }

    try {
      isSubmitting.value = true;

      final updated = await _architectService.updateArchitectProfile(
        await _payload(),
        architect.value ?? initialArchitect ?? Architect.dummy(),
      );
      architect.value = updated;
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().architect.value = updated;
        Get.find<ProfileController>().refreshProfile();
      }
      Get.find<NavigationController>().onPop();
      Get.snackbar('Profile tersimpan', 'Perubahan profile berhasil disimpan.');
    } on ArchitectValidationException catch (e) {
      fieldErrors.assignAll(e.errors);
      Get.snackbar('Profile gagal disimpan', e.message);
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
    experienceController.text = value.yearOfExperience > 0 ? value.yearOfExperience.toString() : '';
    feeController.text = value.consultationFee > 0 ? value.consultationFee.toString() : '';
    durationController.text = value.consultationDuration > 0 ? value.consultationDuration.toString() : '';
  }

  Future<dio.FormData> _payload() async {
    final data = <String, dynamic>{
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'headline': headlineController.text.trim(),
      'bio': bioController.text.trim(),
      'year_of_experience': _nullableInt(experienceController.text),
      'consultation_fee': _digitsOnly(feeController.text),
      'consultation_hours': int.tryParse(durationController.text.trim()) ?? 0,
    };
    final photo = selectedPhoto.value;
    if (photo?.path != null && photo!.path!.isNotEmpty) {
      data['photo_profile'] = await dio.MultipartFile.fromFile(photo.path!, filename: photo.name);
    }

    return dio.FormData.fromMap(data);
  }

  Future<void> pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      withData: false,
    );
    final file = result?.files.single;
    if (file == null) return;
    if (file.path == null || file.path!.isEmpty) {
      fieldErrors['photo_profile'] = 'File tidak bisa dibaca dari perangkat ini.';
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      fieldErrors['photo_profile'] = 'Maksimal ukuran foto adalah 5 MB.';
      return;
    }

    fieldErrors.remove('photo_profile');
    selectedPhoto.value = file;
  }

  void removePhoto() {
    selectedPhoto.value = null;
    fieldErrors.remove('photo_profile');
  }

  bool _validate() {
    final errors = <String, String>{};
    _validateField('name', errors);
    _validateField('email', errors);
    _validateField('headline', errors);
    _validateField('bio', errors);
    _validateField('year_of_experience', errors);
    _validateField('consultation_fee', errors);
    _validateField('consultation_hours', errors);
    fieldErrors.assignAll(errors);
    return errors.isEmpty;
  }

  void _attachRevalidators() {
    nameController.addListener(() => _revalidateField('name'));
    emailController.addListener(() => _revalidateField('email'));
    headlineController.addListener(() => _revalidateField('headline'));
    bioController.addListener(() => _revalidateField('bio'));
    experienceController.addListener(() => _revalidateField('year_of_experience'));
    feeController.addListener(() => _revalidateField('consultation_fee'));
    durationController.addListener(() => _revalidateField('consultation_hours'));
  }

  void _revalidateField(String field) {
    if (!fieldErrors.containsKey(field)) return;
    final errors = Map<String, String>.from(fieldErrors);
    errors.remove(field);
    _validateField(field, errors);
    fieldErrors.assignAll(errors);
  }

  void _validateField(String field, Map<String, String> errors) {
    switch (field) {
      case 'name':
        if (nameController.text.trim().isEmpty) {
          errors[field] = 'Full name wajib diisi.';
        }
        break;
      case 'email':
        if (!GetUtils.isEmail(emailController.text.trim())) {
          errors[field] = 'Email address tidak valid.';
        }
        break;
      case 'headline':
        if (headlineController.text.trim().length > 255) {
          errors[field] = 'Professional title maksimal 255 karakter.';
        }
        break;
      case 'bio':
        break;
      case 'year_of_experience':
        final value = _nullableInt(experienceController.text);
        if (value != null && (value < 0 || value > 100)) {
          errors[field] = 'Pengalaman harus 0 sampai 100 tahun.';
        }
        break;
      case 'consultation_fee':
        if (_digitsOnly(feeController.text) < 0) {
          errors[field] = 'Fee tidak valid.';
        }
        break;
      case 'consultation_hours':
        final value = int.tryParse(durationController.text.trim());
        if (value == null || value < 1 || value > 24) {
          errors[field] = 'Durasi sesi harus 1 sampai 24 jam.';
        }
        break;
    }
  }

  int _digitsOnly(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  int? _nullableInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }
}
