import 'package:halositek/app/core/constants/app_extensions.dart';

class Architect {
  final String id;
  final String name;
  final String email;
  final String profilePicture;
  final DateTime? emailVerifiedAt;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String headline;
  final String bio;
  final String location;
  final String status;
  final String specialization;
  final int totalProjects;
  final int totalAwards;
  final double rating;
  final int consultationFee;
  final int consultationDuration;
  final int yearOfExperience;
  final bool? isWishlisted;
  final List<ArchitectProject> projects;
  final List<ArchitectAward> awards;

  const Architect({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.emailVerifiedAt,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.headline,
    required this.bio,
    required this.location,
    required this.status,
    required this.specialization,
    required this.totalProjects,
    required this.totalAwards,
    required this.rating,
    required this.consultationFee,
    required this.consultationDuration,
    required this.yearOfExperience,
    required this.isWishlisted,
    required this.projects,
    required this.awards,
  });

  factory Architect.fromJson(Map<String, dynamic> json) {
    return Architect(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      profilePicture:
          (json['profile_picture'] ?? json['photo_profile_url'] ?? '')
              .toString(),
      emailVerifiedAt: DateTime.tryParse(
        (json['email_verified_at'] ?? '').toString(),
      ),
      role: (json['role'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
      headline: (json['headline'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      specialization: (json['specialization'] ?? '').toString(),
      totalProjects: _toInt(json['total_projects']),
      totalAwards: _toInt(json['total_awards']),
      rating: _toDouble(json['rating']),
      consultationFee: _toInt(json['consultation_fee']),
      consultationDuration: _toInt(
        json['consultation_duration'] ?? json['consultation_hours'],
      ),
      yearOfExperience: _toInt(json['year_of_experience']),
      isWishlisted: _toNullableBool(json['is_wishlisted']),
      projects:
          _toMapList(json['projects']).map(ArchitectProject.fromJson).toList(),
      awards: _toMapList(json['awards']).map(ArchitectAward.fromJson).toList(),
    );
  }

  factory Architect.dummy() {
    return const Architect(
      id: '',
      name: 'Loading...',
      email: '',
      profilePicture: '',
      emailVerifiedAt: null,
      role: 'architect',
      createdAt: null,
      updatedAt: null,
      headline: '',
      bio: '',
      location: '',
      status: 'approved',
      specialization: '',
      totalProjects: 0,
      totalAwards: 0,
      rating: 0,
      consultationFee: 0,
      consultationDuration: 0,
      yearOfExperience: 0,
      isWishlisted: null,
      projects: <ArchitectProject>[],
      awards: <ArchitectAward>[],
    );
  }

  Architect copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    DateTime? emailVerifiedAt,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? headline,
    String? bio,
    String? location,
    String? status,
    String? specialization,
    int? totalProjects,
    int? totalAwards,
    double? rating,
    int? consultationFee,
    int? consultationDuration,
    int? yearOfExperience,
    bool? isWishlisted,
    List<ArchitectProject>? projects,
    List<ArchitectAward>? awards,
  }) {
    return Architect(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      status: status ?? this.status,
      specialization: specialization ?? this.specialization,
      totalProjects: totalProjects ?? this.totalProjects,
      totalAwards: totalAwards ?? this.totalAwards,
      rating: rating ?? this.rating,
      consultationFee: consultationFee ?? this.consultationFee,
      consultationDuration: consultationDuration ?? this.consultationDuration,
      yearOfExperience: yearOfExperience ?? this.yearOfExperience,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      projects: projects ?? this.projects,
      awards: awards ?? this.awards,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool? _toNullableBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value == 1;

    final normalized = value.toString().toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  static List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}

class ArchitectProject {
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
  final String area;
  final int likesCount;
  final bool liked;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ArchitectProject({
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
    required this.area,
    required this.likesCount,
    required this.liked,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArchitectProject.fromJson(Map<String, dynamic> json) {
    return ArchitectProject(
      id: (json['id'] ?? '').toString(),
      architectId: (json['architect_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      style: (json['style'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      images: _toStringList(json['images']).map((e) => e.toImageUrl()).toList(),
      imageUrls:
          _toStringList(json['image_urls']).map((e) => e.toImageUrl()).toList(),
      estimatedCost: (json['estimated_cost'] ?? '').toString(),
      layoutImages:
          _toStringList(
            json['layout_images'],
          ).map((e) => e.toImageUrl()).toList(),
      layoutImageUrls:
          _toStringList(
            json['layout_image_urls'],
          ).map((e) => e.toImageUrl()).toList(),
      highlightFeatures: (json['highlight_features'] ?? '').toString(),
      area: (json['area'] ?? '').toString(),
      likesCount: Architect._toInt(json['likes_count']),
      liked: json['liked'] == true,
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return <String>[];
    return value.map((e) => e.toString()).toList();
  }
}

class ArchitectAward {
  final String id;
  final String name;
  final String projectName;
  final DateTime? awardDate;
  final String description;
  final String verificationFileUrl;
  final String status;

  const ArchitectAward({
    required this.id,
    required this.name,
    required this.projectName,
    required this.awardDate,
    required this.description,
    required this.verificationFileUrl,
    required this.status,
  });

  factory ArchitectAward.fromJson(Map<String, dynamic> json) {
    return ArchitectAward(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      projectName: (json['project_name'] ?? '').toString(),
      awardDate: DateTime.tryParse((json['award_date'] ?? '').toString()),
      description: (json['description'] ?? '').toString(),
      verificationFileUrl: (json['verification_file_url'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class ArchitectPerformance {
  final int likes;
  final int consultations;
  final int saved;

  const ArchitectPerformance({
    required this.likes,
    required this.consultations,
    required this.saved,
  });

  factory ArchitectPerformance.fromJson(Map<String, dynamic> json) {
    return ArchitectPerformance(
      likes: Architect._toInt(json['total_likes']),
      saved: Architect._toInt(json['total_saves']),
      consultations: Architect._toInt(json['total_consultations']),
    );
  }
}
