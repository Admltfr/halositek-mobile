// To parse this JSON data, do
//
//     final conversationDetailModel = conversationDetailModelFromJson(jsonString);

import 'dart:convert';

ConversationDetailModel conversationDetailModelFromJson(String str) => ConversationDetailModel.fromJson(json.decode(str));

String conversationDetailModelToJson(ConversationDetailModel data) => json.encode(data.toJson());

class ConversationDetailModel {
  String? id;
  String? name;
  bool? isGroup;
  List<String>? participantIds;
  User? user;
  Architect? architect;
  DateTime? lastReadAt;
  String? consultationId;
  ConsultationSession? consultationSession;
  bool? canSendMessage;
  String? lastChatFormatted;
  DateTime? createdAt;
  DateTime? updatedAt;

  ConversationDetailModel({
    this.id,
    this.name,
    this.isGroup,
    this.participantIds,
    this.user,
    this.architect,
    this.lastReadAt,
    this.consultationId,
    this.consultationSession,
    this.canSendMessage,
    this.lastChatFormatted,
    this.createdAt,
    this.updatedAt,
  });

  factory ConversationDetailModel.fromJson(Map<String, dynamic> json) => ConversationDetailModel(
    id: json["id"],
    name: json["name"],
    isGroup: json["is_group"],
    participantIds: json["participant_ids"] == null ? [] : List<String>.from(json["participant_ids"]!.map((x) => x)),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    architect: json["architect"] == null ? null : Architect.fromJson(json["architect"]),
    lastReadAt: json["last_read_at"] == null ? null : DateTime.parse(json["last_read_at"]),
    consultationId: json["consultation_id"],
    consultationSession:
        json["consultation_session"] == null ? null : ConsultationSession.fromJson(json["consultation_session"]),
    canSendMessage: json["can_send_message"],
    lastChatFormatted: json["last_chat_formatted"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "is_group": isGroup,
    "participant_ids": participantIds == null ? [] : List<dynamic>.from(participantIds!.map((x) => x)),
    "user": user?.toJson(),
    "architect": architect?.toJson(),
    "last_read_at": lastReadAt?.toIso8601String(),
    "consultation_id": consultationId,
    "consultation_session": consultationSession?.toJson(),
    "can_send_message": canSendMessage,
    "last_chat_formatted": lastChatFormatted,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Architect {
  String? id;
  String? name;
  String? email;
  String? profilePicture;
  dynamic emailVerifiedAt;
  String? role;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic headline;
  dynamic bio;
  dynamic location;
  dynamic status;
  int? totalProjects;
  int? totalAwards;
  dynamic specialization;
  int? rating;
  int? yearOfExperience;
  int? consultationFee;
  int? consultationHours;
  int? consultationDuration;

  Architect({
    this.id,
    this.name,
    this.email,
    this.profilePicture,
    this.emailVerifiedAt,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.headline,
    this.bio,
    this.location,
    this.status,
    this.totalProjects,
    this.totalAwards,
    this.specialization,
    this.rating,
    this.yearOfExperience,
    this.consultationFee,
    this.consultationHours,
    this.consultationDuration,
  });

  factory Architect.fromJson(Map<String, dynamic> json) => Architect(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    profilePicture: json["profile_picture"],
    emailVerifiedAt: json["email_verified_at"],
    role: json["role"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    headline: json["headline"],
    bio: json["bio"],
    location: json["location"],
    status: json["status"],
    totalProjects: json["total_projects"],
    totalAwards: json["total_awards"],
    specialization: json["specialization"],
    rating: json["rating"],
    yearOfExperience: json["year_of_experience"],
    consultationFee: json["consultation_fee"],
    consultationHours: json["consultation_hours"],
    consultationDuration: json["consultation_duration"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "profile_picture": profilePicture,
    "email_verified_at": emailVerifiedAt,
    "role": role,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "headline": headline,
    "bio": bio,
    "location": location,
    "status": status,
    "total_projects": totalProjects,
    "total_awards": totalAwards,
    "specialization": specialization,
    "rating": rating,
    "year_of_experience": yearOfExperience,
    "consultation_fee": consultationFee,
    "consultation_hours": consultationHours,
    "consultation_duration": consultationDuration,
  };
}

class ConsultationSession {
  String? id;
  String? status;
  DateTime? startedAt;
  DateTime? expiresAt;
  int? remainingSeconds;
  RemainingDuration? remainingDuration;
  bool? isActive;

  ConsultationSession({
    this.id,
    this.status,
    this.startedAt,
    this.expiresAt,
    this.remainingSeconds,
    this.remainingDuration,
    this.isActive,
  });

  factory ConsultationSession.fromJson(Map<String, dynamic> json) => ConsultationSession(
    id: json["id"],
    status: json["status"],
    startedAt: json["started_at"] == null ? null : DateTime.parse(json["started_at"]),
    expiresAt: json["expires_at"] == null ? null : DateTime.parse(json["expires_at"]),
    remainingSeconds: json["remaining_seconds"],
    remainingDuration: json["remaining_duration"] == null ? null : RemainingDuration.fromJson(json["remaining_duration"]),
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "started_at": startedAt?.toIso8601String(),
    "expires_at": expiresAt?.toIso8601String(),
    "remaining_seconds": remainingSeconds,
    "remaining_duration": remainingDuration?.toJson(),
    "is_active": isActive,
  };
}

class RemainingDuration {
  int? days;
  int? hours;
  int? minutes;
  int? seconds;

  RemainingDuration({this.days, this.hours, this.minutes, this.seconds});

  factory RemainingDuration.fromJson(Map<String, dynamic> json) =>
      RemainingDuration(days: json["days"], hours: json["hours"], minutes: json["minutes"], seconds: json["seconds"]);

  Map<String, dynamic> toJson() => {"days": days, "hours": hours, "minutes": minutes, "seconds": seconds};
}

class User {
  String? id;
  String? name;
  String? email;
  dynamic photoProfile;
  dynamic photoProfileUrl;
  String? role;
  dynamic accountStatus;
  dynamic headline;
  DateTime? memberSince;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.photoProfile,
    this.photoProfileUrl,
    this.role,
    this.accountStatus,
    this.headline,
    this.memberSince,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    photoProfile: json["photo_profile"],
    photoProfileUrl: json["photo_profile_url"],
    role: json["role"],
    accountStatus: json["account_status"],
    headline: json["headline"],
    memberSince: json["member_since"] == null ? null : DateTime.parse(json["member_since"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "photo_profile": photoProfile,
    "photo_profile_url": photoProfileUrl,
    "role": role,
    "account_status": accountStatus,
    "headline": headline,
    "member_since": memberSince?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
