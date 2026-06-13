import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';

enum DesignFormMode { add, edit }

class DesignFormController extends GetxController {
  DesignFormController(
    CatalogService catalogService, {
    required this.mode,
    this.catalogId,
    this.initialCatalog,
  }) : _catalogService = catalogService;

  static const styles = [
    'modern',
    'traditional',
    'minimalist',
    'futuristik',
    'industrial',
  ];

  final CatalogService _catalogService;
  final DesignFormMode mode;
  final String? catalogId;
  final Catalog? initialCatalog;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final estimatedCostController = TextEditingController();
  final areaController = TextEditingController();
  final highlightFeaturesController = TextEditingController();

  final selectedStyle = styles.first.obs;
  final mediaFiles = <PlatformFile>[].obs;
  final layoutFiles = <PlatformFile>[].obs;
  final catalog = Rxn<Catalog>();
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  bool get isEdit => mode == DesignFormMode.edit;
  String get title => isEdit ? 'Edit Design' : 'New Design';
  String get submitLabel => isEdit ? 'Save Design' : 'Submit Design';
  String get cancelLabel => isEdit ? 'Cancel Edit' : 'Cancel Design';
  String get resolvedCatalogId =>
      catalog.value?.id ?? initialCatalog?.id ?? catalogId ?? '';

  @override
  void onInit() {
    super.onInit();
    if (initialCatalog != null) {
      _fill(initialCatalog!);
    } else if (isEdit) {
      fetchCatalog();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    estimatedCostController.dispose();
    areaController.dispose();
    highlightFeaturesController.dispose();
    super.onClose();
  }

  void goBack() {
    Get.find<NavigationController>().onPop();
  }

  Future<void> fetchCatalog() async {
    final id = resolvedCatalogId.trim();
    if (id.isEmpty) return;

    try {
      isLoading.value = true;
      _fill(await _catalogService.getCatalogById(id));
    } catch (e) {
      Get.snackbar('Design gagal dimuat', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void changeStyle(String? value) {
    if (value == null || !styles.contains(value)) return;
    selectedStyle.value = value;
  }

  Future<void> pickMediaDesign() async {
    await _pickImages(mediaFiles);
  }

  Future<void> pickLayoutDesign() async {
    await _pickImages(layoutFiles);
  }

  void removeMediaFile(PlatformFile file) {
    mediaFiles.remove(file);
  }

  void removeLayoutFile(PlatformFile file) {
    layoutFiles.remove(file);
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
      final payload = await _payload();
      final saved =
          isEdit
              ? await _catalogService.updateCatalog(resolvedCatalogId, payload)
              : await _catalogService.createCatalog(payload);
      Get.find<NavigationController>().onPop(saved);
    } catch (e) {
      Get.snackbar(
        isEdit ? 'Design gagal diubah' : 'Design gagal disimpan',
        e.toString(),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _fill(Catalog value) {
    catalog.value = value;
    nameController.text = value.name;
    descriptionController.text = value.description;
    estimatedCostController.text = value.estimatedCost;
    areaController.text = value.areaRaw;
    highlightFeaturesController.text = value.highlightFeatures;
    if (styles.contains(value.style.toLowerCase().trim())) {
      selectedStyle.value = value.style.toLowerCase().trim();
    }
  }

  Future<void> _pickImages(RxList<PlatformFile> target) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
      withData: false,
    );

    final files = result?.files ?? <PlatformFile>[];
    if (files.isEmpty) return;

    final validFiles = <PlatformFile>[];
    for (final file in files) {
      if (file.path == null || file.path!.isEmpty) {
        Get.snackbar(
          'File tidak valid',
          'Ada file yang tidak bisa dibaca dari perangkat ini.',
        );
        continue;
      }
      if (file.size > 5 * 1024 * 1024) {
        Get.snackbar('File terlalu besar', '${file.name} melebihi batas 5 MB.');
        continue;
      }
      validFiles.add(file);
    }

    target.addAll(validFiles);
  }

  Future<dio.FormData> _payload() async {
    final data = <String, dynamic>{
      'name': nameController.text.trim(),
      'style': selectedStyle.value,
      'description': descriptionController.text.trim(),
      'estimated_cost': estimatedCostController.text.trim(),
      'area': areaController.text.trim(),
      'highlight_features': highlightFeaturesController.text.trim(),
    };

    final images = await _multipartFiles(mediaFiles);
    final layoutImages = await _multipartFiles(layoutFiles);

    if (images.isNotEmpty) data['images[]'] = images;
    if (layoutImages.isNotEmpty) data['layout_images[]'] = layoutImages;

    return dio.FormData.fromMap(data);
  }

  Future<List<dio.MultipartFile>> _multipartFiles(
    List<PlatformFile> files,
  ) async {
    final result = <dio.MultipartFile>[];
    for (final file in files) {
      result.add(
        await dio.MultipartFile.fromFile(file.path!, filename: file.name),
      );
    }
    return result;
  }

  String? _validate() {
    if (isEdit && resolvedCatalogId.trim().isEmpty) {
      return 'Design ID tidak ditemukan.';
    }
    if (nameController.text.trim().isEmpty) return 'Design title wajib diisi.';
    if (descriptionController.text.trim().isEmpty) {
      return 'Description wajib diisi.';
    }
    if (estimatedCostController.text.trim().isEmpty) {
      return 'Estimated cost wajib diisi.';
    }
    if (areaController.text.trim().isEmpty) return 'Area wajib diisi.';
    if (highlightFeaturesController.text.trim().isEmpty) {
      return 'Highlight features wajib diisi.';
    }
    if (!styles.contains(selectedStyle.value)) {
      return 'Architectural style wajib dipilih.';
    }
    if (!isEdit && mediaFiles.isEmpty) return 'Media design wajib diupload.';
    if (!isEdit && layoutFiles.isEmpty) return 'Layout design wajib diupload.';
    return null;
  }
}
