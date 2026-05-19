import 'chat_message.dart';

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
