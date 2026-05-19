import 'chat_sender.dart';

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
