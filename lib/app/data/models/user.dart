class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String accountStatus;
  final String photoProfileUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<SavedProject> savedProjects;
  final List<SavedArchitect> savedArchitects;
  final List<PaymentHistory> paymentHistories;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accountStatus,
    required this.photoProfileUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.savedProjects,
    required this.savedArchitects,
    required this.paymentHistories,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      accountStatus: (json['account_status'] ?? '').toString(),
      photoProfileUrl: (json['photo_profile_url'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
      savedProjects:
          _toMapList(
            json['saved_projects'],
          ).map(SavedProject.fromJson).toList(),
      savedArchitects:
          _toMapList(
            json['saved_architects'],
          ).map(SavedArchitect.fromJson).toList(),
      paymentHistories:
          _toMapList(
            json['payment_histories'],
          ).map(PaymentHistory.fromJson).toList(),
    );
  }

  factory UserProfile.empty() {
    return const UserProfile(
      id: '',
      name: '',
      email: '',
      role: 'user',
      accountStatus: '',
      photoProfileUrl: '',
      createdAt: null,
      updatedAt: null,
      savedProjects: <SavedProject>[],
      savedArchitects: <SavedArchitect>[],
      paymentHistories: <PaymentHistory>[],
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? accountStatus,
    String? photoProfileUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SavedProject>? savedProjects,
    List<SavedArchitect>? savedArchitects,
    List<PaymentHistory>? paymentHistories,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      photoProfileUrl: photoProfileUrl ?? this.photoProfileUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      savedProjects: savedProjects ?? this.savedProjects,
      savedArchitects: savedArchitects ?? this.savedArchitects,
      paymentHistories: paymentHistories ?? this.paymentHistories,
    );
  }

  static int toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}

class SavedProject {
  final String id;
  final String title;
  final String style;
  final String imageUrl;
  final UserArchitectSummary architect;

  const SavedProject({
    required this.id,
    required this.title,
    required this.style,
    required this.imageUrl,
    required this.architect,
  });

  factory SavedProject.fromJson(Map<String, dynamic> json) {
    final architectJson = json['architect'];
    return SavedProject(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      style: (json['style'] ?? '').toString(),
      imageUrl:
          (json['image_url'] ??
                  json['thumbnail_url'] ??
                  json['photo_url'] ??
                  '')
              .toString(),
      architect:
          architectJson is Map
              ? UserArchitectSummary.fromJson(
                Map<String, dynamic>.from(architectJson),
              )
              : UserArchitectSummary.empty(),
    );
  }
}

class SavedArchitect {
  final String id;
  final String name;
  final String photoProfileUrl;
  final SavedArchitectProfile architectProfile;
  final int totalProjects;
  final int totalAwards;

  const SavedArchitect({
    required this.id,
    required this.name,
    required this.photoProfileUrl,
    required this.architectProfile,
    required this.totalProjects,
    required this.totalAwards,
  });

  factory SavedArchitect.fromJson(Map<String, dynamic> json) {
    final profileJson = json['architect_profile'];
    return SavedArchitect(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      photoProfileUrl: (json['photo_profile_url'] ?? '').toString(),
      architectProfile:
          profileJson is Map
              ? SavedArchitectProfile.fromJson(
                Map<String, dynamic>.from(profileJson),
              )
              : SavedArchitectProfile.empty(),
      totalProjects: UserProfile.toInt(json['total_projects']),
      totalAwards: UserProfile.toInt(json['total_awards']),
    );
  }
}

class SavedArchitectProfile {
  final String id;
  final String bio;
  final String location;

  const SavedArchitectProfile({
    required this.id,
    required this.bio,
    required this.location,
  });

  factory SavedArchitectProfile.fromJson(Map<String, dynamic> json) {
    return SavedArchitectProfile(
      id: (json['id'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
    );
  }

  factory SavedArchitectProfile.empty() {
    return const SavedArchitectProfile(id: '', bio: '', location: '');
  }
}

class PaymentHistory {
  final String id;
  final String orderId;
  final String status;
  final String refundStatus;
  final int amount;
  final int taxAmount;
  final int totalPaidAmount;
  final int durationHours;
  final String paymentMethod;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final String consultationId;
  final String conversationId;
  final UserArchitectSummary architect;

  const PaymentHistory({
    required this.id,
    required this.orderId,
    required this.status,
    required this.refundStatus,
    required this.amount,
    required this.taxAmount,
    required this.totalPaidAmount,
    required this.durationHours,
    required this.paymentMethod,
    required this.paidAt,
    required this.createdAt,
    required this.consultationId,
    required this.conversationId,
    required this.architect,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    final architectJson = json['architect'];
    return PaymentHistory(
      id: (json['id'] ?? '').toString(),
      orderId: (json['order_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      refundStatus: (json['refund_status'] ?? '').toString(),
      amount: UserProfile.toInt(json['amount']),
      taxAmount: UserProfile.toInt(json['tax_amount']),
      totalPaidAmount: UserProfile.toInt(json['total_paid_amount']),
      durationHours: UserProfile.toInt(json['duration_hours']),
      paymentMethod: (json['payment_method'] ?? '').toString(),
      paidAt: DateTime.tryParse((json['paid_at'] ?? '').toString()),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      consultationId: (json['consultation_id'] ?? '').toString(),
      conversationId: (json['conversation_id'] ?? '').toString(),
      architect:
          architectJson is Map
              ? UserArchitectSummary.fromJson(
                Map<String, dynamic>.from(architectJson),
              )
              : UserArchitectSummary.empty(),
    );
  }
}

class UserArchitectSummary {
  final String id;
  final String name;
  final String photoProfileUrl;

  const UserArchitectSummary({
    required this.id,
    required this.name,
    required this.photoProfileUrl,
  });

  factory UserArchitectSummary.fromJson(Map<String, dynamic> json) {
    return UserArchitectSummary(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      photoProfileUrl: (json['photo_profile_url'] ?? '').toString(),
    );
  }

  factory UserArchitectSummary.empty() {
    return const UserArchitectSummary(id: '', name: '', photoProfileUrl: '');
  }
}
