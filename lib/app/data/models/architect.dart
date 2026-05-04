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
      status: (json['status'] ?? '').toString(),
      specialization: (json['specialization'] ?? '').toString(),
      totalProjects: _toInt(json['total_projects']),
      totalAwards: _toInt(json['total_awards']),
      rating: _toDouble(json['rating']),
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
}
