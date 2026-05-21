class ChatConversation {
  final String id;
  final String name;
  final bool isGroup;
  final List<String> participantIds;
  final DateTime? lastReadAt;
  final int unreadCount;
  final ChatMessage? lastMessage;
  final DateTime? updatedAt;

  const ChatConversation({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.participantIds,
    required this.lastReadAt,
    required this.unreadCount,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final lastMessageRaw = json['last_message'];
    final lastMessage =
        lastMessageRaw is Map
            ? ChatMessage.fromJson(lastMessageRaw.cast<String, dynamic>())
            : null;

    return ChatConversation(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      isGroup: json['is_group'] == true,
      participantIds: _toStringList(json['participant_ids']),
      lastReadAt: _parseDate(json['last_read_at']),
      unreadCount: _toInt(json['unread_count']),
      lastMessage: lastMessage,
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  String get displayName {
    if (name.trim().isNotEmpty) return name;
    return isGroup ? 'Group Chat' : 'Conversation';
  }

  String get lastMessagePreview => lastMessage?.displayBody ?? '';

  DateTime? get lastActivityAt => lastMessage?.createdAt ?? updatedAt;

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
      attachment: json['attachment']?.toString(),
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
