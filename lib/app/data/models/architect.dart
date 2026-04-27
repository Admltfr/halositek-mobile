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
  final String catalogsFileUrl;
  final String awardsFileUrl;
  final String status;
  final String specialization;
  final int likesCount;

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
    required this.catalogsFileUrl,
    required this.awardsFileUrl,
    required this.status,
    required this.specialization,
    required this.likesCount,
  });

  factory Architect.fromJson(Map<String, dynamic> json) {
    return Architect(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      profilePicture: (json['profile_picture'] ?? '').toString(),
      emailVerifiedAt: DateTime.tryParse(
        (json['email_verified_at'] ?? '').toString(),
      ),
      role: (json['role'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
      headline: (json['headline'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      catalogsFileUrl: (json['catalogs_file_url'] ?? '').toString(),
      awardsFileUrl: (json['awards_file_url'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      specialization: (json['specialization'] ?? '').toString(),
      likesCount: _toInt(json['likes_count']),
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
      catalogsFileUrl: '',
      awardsFileUrl: '',
      status: 'approved',
      specialization: '',
      likesCount: 0,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
