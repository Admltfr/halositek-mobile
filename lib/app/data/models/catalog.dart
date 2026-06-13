import 'package:halositek/app/data/models/architect.dart';

class Catalog {
  final String id;
  final String architectId;
  final String name;
  final String style;
  final String description;

  final List<String> images;
  final List<String> imageUrls;

  final String estimatedCost;

  final List<String> layoutImages;
  final List<String> layoutImageUrls;

  final String highlightFeatures;
  final String areaRaw;

  final int likesCount;
  final bool liked;
  final bool saved;
  final String status;

  final Architect? architect;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Catalog({
    required this.id,
    required this.architectId,
    required this.name,
    required this.style,
    required this.description,
    required this.images,
    required this.imageUrls,
    required this.estimatedCost,
    required this.layoutImages,
    required this.layoutImageUrls,
    required this.highlightFeatures,
    required this.areaRaw,
    required this.likesCount,
    required this.liked,
    required this.saved,
    required this.status,
    required this.architect,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Catalog.fromJson(Map<String, dynamic> json) {
    return Catalog(
      id: (json['id'] ?? '').toString(),
      architectId: (json['architect_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      style: (json['style'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      images: _toStringList(json['images']),
      imageUrls: _toStringList(json['image_urls']),
      estimatedCost: (json['estimated_cost'] ?? '').toString(),
      layoutImages: _toStringList(json['layout_images']),
      layoutImageUrls: _toStringList(json['layout_image_urls']),
      highlightFeatures: (json['highlight_features'] ?? '').toString(),
      areaRaw: (json['area'] ?? '').toString(),
      likesCount: _toInt(json['likes_count']),
      liked: _toBool(json['is_liked']) ?? _toBool(json['liked']) ?? false,
      saved:
          _toBool(json['is_saved']) ??
          _toBool(json['saved']) ??
          _toBool(json['is_wishlisted']) ??
          false,
      status: (json['status'] ?? '').toString(),
      architect:
          json['architect'] is Map
              ? Architect.fromJson(
                (json['architect'] as Map).cast<String, dynamic>(),
              )
              : null,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  Catalog copyWith({
    String? id,
    String? architectId,
    String? name,
    String? style,
    String? description,
    List<String>? images,
    List<String>? imageUrls,
    String? estimatedCost,
    List<String>? layoutImages,
    List<String>? layoutImageUrls,
    String? highlightFeatures,
    String? areaRaw,
    int? likesCount,
    bool? liked,
    bool? saved,
    String? status,
    Architect? architect,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Catalog(
      id: id ?? this.id,
      architectId: architectId ?? this.architectId,
      name: name ?? this.name,
      style: style ?? this.style,
      description: description ?? this.description,
      images: images ?? this.images,
      imageUrls: imageUrls ?? this.imageUrls,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      layoutImages: layoutImages ?? this.layoutImages,
      layoutImageUrls: layoutImageUrls ?? this.layoutImageUrls,
      highlightFeatures: highlightFeatures ?? this.highlightFeatures,
      areaRaw: areaRaw ?? this.areaRaw,
      likesCount: likesCount ?? this.likesCount,
      liked: liked ?? this.liked,
      saved: saved ?? this.saved,
      status: status ?? this.status,
      architect: architect ?? this.architect,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Catalog.dummy() {
    return const Catalog(
      id: '',
      architectId: '',
      name: 'Loading...',
      style: '',
      description: '',
      images: <String>[],
      imageUrls: <String>[],
      estimatedCost: '',
      layoutImages: <String>[],
      layoutImageUrls: <String>[],
      highlightFeatures: '',
      areaRaw: '0',
      likesCount: 0,
      liked: false,
      saved: false,
      status: '',
      architect: null,
      createdAt: null,
      updatedAt: null,
    );
  }

  double get area => _toDouble(areaRaw);

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return <String>[];
    return value.map((e) => e.toString()).toList();
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();

    final raw = value?.toString() ?? '';
    final match = RegExp(r'[-+]?[0-9]*\.?[0-9]+').firstMatch(raw);
    if (match == null) return 0;
    return double.tryParse(match.group(0) ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value == 1;

    final normalized = value.toString().toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }
}
