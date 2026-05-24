import 'package:halositek/app/data/models/architect.dart';

class Award {
  final String id;
  final String architectId;
  final String name;
  final String projectName;
  final String role;
  final DateTime? awardDate;
  final String description;
  final String verificationFile;
  final String verificationFileUrl;
  final String status;
  final Architect? architect;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Award({
    required this.id,
    required this.architectId,
    required this.name,
    required this.projectName,
    required this.role,
    required this.awardDate,
    required this.description,
    required this.verificationFile,
    required this.verificationFileUrl,
    required this.status,
    required this.architect,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Award.fromJson(Map<String, dynamic> json) {
    final architectJson = json['architect'];

    return Award(
      id: (json['id'] ?? '').toString(),
      architectId: (json['architect_id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      projectName: (json['project_name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      awardDate: DateTime.tryParse((json['award_date'] ?? '').toString()),
      description: (json['description'] ?? '').toString(),
      verificationFile: (json['verification_file'] ?? '').toString(),
      verificationFileUrl: (json['verification_file_url'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      architect:
          architectJson is Map
              ? Architect.fromJson(Map<String, dynamic>.from(architectJson))
              : null,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  factory Award.dummy() {
    return Award(
      id: '',
      architectId: '',
      name: 'Loading Award',
      projectName: 'Loading Project',
      role: 'Lead Architect',
      awardDate: DateTime(2026, 1, 1),
      description: 'Loading award description',
      verificationFile: '',
      verificationFileUrl: '',
      status: 'approved',
      architect: Architect.dummy(),
      createdAt: null,
      updatedAt: null,
    );
  }

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'pending';
  String get title => name;
  String get imageUrl => verificationFileUrl;
  String get dateLabel {
    if (awardDate == null) return '';
    return awardDate!.year.toString();
  }
}
