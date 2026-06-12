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
  final String? architectName;
  final String? architectHeadline;
  final String? userName;

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
    this.architectName,
    this.architectHeadline,
    this.userName,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final lastMessageRaw = json['last_message'];
    final lastMessage =
        lastMessageRaw is Map
            ? ChatMessage.fromJson(lastMessageRaw.cast<String, dynamic>())
            : null;

    final architectRaw = json['architect'];
    final userRaw = json['user'];

    final parsedArchitectName =
        architectRaw is Map ? (architectRaw['name'] ?? '').toString() : null;
    final parsedArchitectHeadline =
        architectRaw is Map ? (architectRaw['headline'] ?? '').toString() : null;
    final parsedUserName =
        userRaw is Map ? (userRaw['name'] ?? '').toString() : null;

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
      architectName: parsedArchitectName,
      architectHeadline: parsedArchitectHeadline,
      userName: parsedUserName,
    );
  }

  String get displayName {
    if (architectName != null && architectName!.trim().isNotEmpty) {
      return architectName!;
    }
    if (name.trim().isNotEmpty) return name;
    return isGroup ? 'Group Chat' : 'Conversation';
  }

  String get lastMessagePreview => lastMessage?.displayBody ?? '';

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
    final attachmentVal = json['attachment_url']?.toString() ?? json['attachment']?.toString();

    return ChatMessage(
      id: (json['id'] ?? '').toString(),
      conversationId: (json['conversation_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      body: body,
      content: content,
      role: (json['role'] ?? '').toString(),
      type: (json['type'] ?? 'text').toString(),
      attachment: attachmentVal,
      readAt: _parseDate(json['read_at']),
      isMine: json['is_mine'] == true,
      sender:
          json['sender'] is Map
              ? ChatSender.fromJson(
                (json['sender'] as Map).cast<String, dynamic>(),
              )
              : null,
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
  bool get hasImage =>
      (type == 'image') ||
      (attachment != null &&
          attachment!.isNotEmpty &&
          _isImageUrl(attachment!));

  static bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.contains('/image') ||
        lower.contains('images/');
  }

  static DateTime? _parseDate(dynamic value) {
    return DateTime.tryParse((value ?? '').toString());
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
  final String conversationId;
  final String reason;
  final String status; // 'pending', 'resolved', etc.
  final DateTime? createdAt;

  const ChatReport({
    required this.id,
    required this.conversationId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory ChatReport.fromJson(Map<String, dynamic> json) {
    return ChatReport(
      id: (json['id'] ?? '').toString(),
      conversationId: (json['conversation_id'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }
}
