import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/user.dart';
import 'package:halositek/app/data/network/auth_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';
import 'package:halositek/app/modules/profile/controllers/profile_controller.dart';

class UserProfileEditController extends GetxController {
  UserProfileEditController(this._authService, {this.initialUser});

  final AuthService _authService;
  final UserProfile? initialUser;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController(text: '************');

  final user = Rxn<UserProfile>();
  final selectedPhoto = Rxn<PlatformFile>();
  final fieldErrors = <String, String>{}.obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _attachRevalidators();
    if (initialUser != null) {
      _fill(initialUser!);
    } else {
      loadProfile();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      _fill(await _authService.getMe());
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
    if (!_validate()) return;

    try {
      isSubmitting.value = true;
      final updated = await _authService.updateMe(
        await _payload(),
        user.value ?? initialUser ?? UserProfile.empty(),
      );
      user.value = updated;

      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        profileController.user.value = updated;
        profileController.refreshProfile();
      }

      Get.find<NavigationController>().onPop();
      Get.snackbar('Profile tersimpan', 'Perubahan profile berhasil disimpan.');
    } on UserValidationException catch (e) {
      fieldErrors.assignAll(e.errors);
      Get.snackbar('Profile gagal disimpan', e.message);
    } catch (e) {
      Get.snackbar('Profile gagal disimpan', e.toString());
    } finally {
      isSubmitting.value = false;
    }
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
      fieldErrors['photo_profile'] =
          'File tidak bisa dibaca dari perangkat ini.';
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

  void _fill(UserProfile value) {
    user.value = value;
    nameController.text = value.name;
    emailController.text = value.email;
  }

  Future<dio.FormData> _payload() async {
    final data = <String, dynamic>{
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
    };
    final photo = selectedPhoto.value;
    if (photo?.path != null && photo!.path!.isNotEmpty) {
      data['photo_profile'] = await dio.MultipartFile.fromFile(
        photo.path!,
        filename: photo.name,
      );
    }

    return dio.FormData.fromMap(data);
  }

  bool _validate() {
    final errors = <String, String>{};
    _validateField('name', errors);
    _validateField('email', errors);
    fieldErrors.assignAll(errors);
    return errors.isEmpty;
  }

  void _attachRevalidators() {
    nameController.addListener(() => _revalidateField('name'));
    emailController.addListener(() => _revalidateField('email'));
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
          errors[field] = 'Username wajib diisi.';
        }
        break;
      case 'email':
        if (!GetUtils.isEmail(emailController.text.trim())) {
          errors[field] = 'Email address tidak valid.';
        }
        break;
    }
  }
}
