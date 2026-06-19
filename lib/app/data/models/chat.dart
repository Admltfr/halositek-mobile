import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/data/network/api_client.dart';

class ChatConversation {
  final String id;
  final String name;
  final bool isGroup;
  final List<String> participantIds;
  final DateTime? lastReadAt;
  final int unreadCount;
  final ChatMessage? lastMessage;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int durationHours;
  final String status; // e.g. '', 'approved', 'declined', 'reported'
  final String consultationId;
  final ChatParticipant? user;
  final ChatParticipant? architect;
  final ChatSession? session;
  final bool canSendMessage;

  const ChatConversation({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.participantIds,
    required this.lastReadAt,
    required this.unreadCount,
    required this.lastMessage,
    required this.updatedAt,
    required this.createdAt,
    required this.durationHours,
    required this.status,
    required this.consultationId,
    this.user,
    this.architect,
    this.session,
    this.canSendMessage = false,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final lastMessageRaw = json['last_message'];
    final lastMessage = lastMessageRaw is Map ? ChatMessage.fromJson(lastMessageRaw.cast<String, dynamic>()) : null;

    final architectRaw = json['architect'];
    final userRaw = json['user'];
    final sessionRaw = json['consultation_session'];

    return ChatConversation(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      isGroup: json['is_group'] == true,
      participantIds: _toStringList(json['participant_ids']),
      lastReadAt: _parseDate(json['last_read_at']),
      unreadCount: _toInt(json['unread_count']),
      lastMessage: lastMessage,
      updatedAt: _parseDate(json['updated_at']),
      createdAt: _parseDate(json['created_at']),
      durationHours: _toInt(json['duration_hours']),
      status: (json['status'] ?? '').toString().toLowerCase(),
      consultationId: (json['consultation_id'] ?? '').toString(),
      user: userRaw is Map ? ChatParticipant.fromJson(Map<String, dynamic>.from(userRaw)) : null,
      architect: architectRaw is Map ? ChatParticipant.fromJson(Map<String, dynamic>.from(architectRaw)) : null,
      session: sessionRaw is Map ? ChatSession.fromJson(Map<String, dynamic>.from(sessionRaw)) : null,
      canSendMessage: json['can_send_message'] == true,
    );
  }

  String get displayName {
    if (architect?.name != null && architect!.name.trim().isNotEmpty) {
      return architect!.name;
    }
    if (name.trim().isNotEmpty) return name;
    return isGroup ? 'Group Chat' : 'Conversation';
  }

  String? get displayImageUrl {
    if (architect?.displayImageUrl != null) return architect!.displayImageUrl;
    return user?.displayImageUrl;
  }

  String get lastMessagePreview {
    if (lastMessage == null) return '';

    if (lastMessage!.type == 'image') {
      return 'Image';
    }

    return lastMessage!.displayBody;
  }

  DateTime? get lastActivityAt => lastMessage?.createdAt ?? updatedAt;

  /// Returns the datetime when this session expires (null if no duration set)
  DateTime? get sessionExpiredAt {
    if (createdAt == null || durationHours <= 0) return null;
    return createdAt!.add(Duration(hours: durationHours));
  }

  /// Whether the consultation session has expired
  bool get isExpired {
    final expiry = sessionExpiredAt;
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry);
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return <String>[];
    return value.map((e) => e.toString()).toList();
  }

  static DateTime? _parseDate(dynamic value) {
    return DateTime.tryParse((value ?? '').toString());
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String userId;
  final String body;
  final String content;
  final String role;
  final String type;
  final String? attachment;
  final DateTime? readAt;
  final bool isMine;
  final ChatSender? sender;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.body,
    required this.content,
    required this.role,
    required this.type,
    required this.attachment,
    required this.readAt,
    required this.isMine,
    required this.sender,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final body = (json['body'] ?? '').toString();
    final content = (json['content'] ?? '').toString();

    return ChatMessage(
      id: (json['id'] ?? '').toString(),
      conversationId: (json['conversation_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      body: body,
      content: content,
      role: (json['role'] ?? '').toString(),
      type: (json['type'] ?? 'text').toString(),
      attachment: (json['attachment_url'] ?? '').toString(),
      readAt: _parseDate(json['read_at']),
      isMine: json['is_mine'] == true,
      sender: json['sender'] is Map ? ChatSender.fromJson((json['sender'] as Map).cast<String, dynamic>()) : null,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  String get displayBody => body.isNotEmpty ? body : content;

  String? get attachmentUrl {
    if (attachment == null || attachment!.isEmpty) return null;
    if (attachment!.startsWith('http://') || attachment!.startsWith('https://')) {
      return attachment;
    }
    final base = ApiClient.baseUrl ?? '';
    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final cleanAttachment = attachment!.startsWith('/') ? attachment! : '/$attachment';
    return '$cleanBase$cleanAttachment';
  }

  /// True if this message contains an image (attachment or type == 'image')
  bool get hasImage => (type == 'image') || (attachment != null && attachment!.isNotEmpty);

  static DateTime? _parseDate(dynamic value) {
    return DateTime.tryParse((value ?? '').toString());
  }

  // Add this method to ChatMessage model
  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? userId,
    String? body,
    String? content,
    String? role,
    String? type,
    String? attachment,
    DateTime? readAt,
    bool? isMine,
    ChatSender? sender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      body: body ?? this.body,
      content: content ?? this.content,
      role: role ?? this.role,
      type: type ?? this.type,
      attachment: attachment ?? this.attachment,
      readAt: readAt ?? this.readAt,
      isMine: isMine ?? this.isMine,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChatSender {
  final String id;
  final String name;
  final String email;

  const ChatSender({required this.id, required this.name, required this.email});

  factory ChatSender.fromJson(Map<String, dynamic> json) {
    return ChatSender(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}

class ChatReport {
  final String id;
  final ChatParticipant requester;
  final String reason;
  final DateTime? consultationDate;
  final ChatParticipant opposingParty;
  final double nominal;
  final String transcript;
  final String actionReport; // 'new', 'approved', 'declined'

  const ChatReport({
    required this.id,
    required this.requester,
    required this.reason,
    required this.consultationDate,
    required this.opposingParty,
    required this.nominal,
    required this.transcript,
    required this.actionReport,
  });

  factory ChatReport.fromJson(Map<String, dynamic> json) {
    return ChatReport(
      id: (json['id'] ?? '').toString(),
      requester: ChatParticipant.fromJson(
        json['requester'] is Map ? Map<String, dynamic>.from(json['requester'] as Map) : <String, dynamic>{},
      ),
      reason: (json['reason'] ?? '').toString(),
      consultationDate: DateTime.tryParse((json['consultation_date'] ?? '').toString()),
      opposingParty: ChatParticipant.fromJson(
        json['opposing_party'] is Map ? Map<String, dynamic>.from(json['opposing_party'] as Map) : <String, dynamic>{},
      ),
      nominal: _toDouble(json['nominal']),
      transcript: (json['transcript'] ?? '').toString(),
      actionReport: (json['action_report'] ?? 'new').toString().toLowerCase(),
    );
  }

  /// Display name: show the opposing party's name
  String get displayName => opposingParty.name.isNotEmpty ? opposingParty.name : 'Unknown User';

  /// Preview text from the reason
  String get reasonPreview => reason;

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ChatParticipant {
  final String id;
  final String name;
  final String role;
  final String email;
  final String? photoProfile;
  final String? photoProfileUrl;
  final String? profilePicture;
  final Map<String, dynamic> rawData;

  const ChatParticipant({
    required this.id,
    required this.name,
    this.role = '',
    this.email = '',
    this.photoProfile,
    this.photoProfileUrl,
    this.profilePicture,
    this.rawData = const {},
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      photoProfile: (json['photo_profile'] ?? json['profile_picture'])?.toString(),
      photoProfileUrl: (json['photo_profile_url'] ?? json['profile_picture_url'])?.toString(),
      profilePicture: (json['profile_picture'] ?? json['profile_picture_url'])?.toString(),
      rawData: json,
    );
  }

  String? get displayImageUrl {
    if (photoProfileUrl != null && photoProfileUrl!.isNotEmpty) {
      if (photoProfileUrl!.startsWith('http')) {
        return photoProfileUrl;
      }
      final base = ApiClient.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? '';
      return '$base/$photoProfileUrl';
    }
    if (photoProfile != null && photoProfile!.isNotEmpty) {
      if (photoProfile!.startsWith('http')) return photoProfile;
      final base = ApiClient.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? '';
      return '$base/storage/$photoProfile';
    }
    if (profilePicture != null && profilePicture!.isNotEmpty) {
      if (profilePicture!.startsWith('http')) return profilePicture;
      final base = ApiClient.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? '';
      return '$base/storage/$profilePicture';
    }
    return null;
  }
}

class ChatSession {
  final String id;
  final String status;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final int remainingSeconds;
  final bool isActive;

  const ChatSession({
    required this.id,
    required this.status,
    required this.startedAt,
    required this.expiresAt,
    required this.remainingSeconds,
    required this.isActive,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: (json['id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'].toString()) : null,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString()) : null,
      remainingSeconds:
          json['remaining_seconds'] is int
              ? json['remaining_seconds']
              : int.tryParse(json['remaining_seconds']?.toString() ?? '') ?? 0,
      isActive: json['is_active'] == true,
    );
  }
}
