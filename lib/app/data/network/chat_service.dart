import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:halositek/app/data/models/conversation_detail.dart';
import 'package:halositek/app/data/network/api_client.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService(this._apiClient);

  Future<AiChatMessagesPage> getAiMessages({
    int perPage = 10,
    String? cursor,
  }) async {
    final response = await _apiClient.private.get(
      '/chat/ai/messages',
      queryParameters: {
        'per_page': perPage,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor,
      },
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final rawList = response.data?['data'];
      final messages =
          rawList is List
              ? rawList
                  .whereType<Map>()
                  .map(
                    (e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : <ChatMessage>[];

      final rawMeta = response.data?['meta'];
      final meta =
          rawMeta is Map
              ? Map<String, dynamic>.from(rawMeta)
              : <String, dynamic>{};

      return AiChatMessagesPage(
        messages: messages,
        perPage: _toInt(meta['per_page']),
        nextCursor: meta['next_cursor']?.toString(),
        hasMore: meta['has_more'] == true,
      );
    }, 'Fetch AI Messages');
  }

  Future<ChatMessage> sendAiMessage(String message) async {
    final response = await _apiClient.private.post(
      '/chat/ai/messages',
      data: {'message': message},
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'] ?? response.data;
      if (raw is! Map) {
        throw Exception('Invalid AI message response format');
      }

      final data = Map<String, dynamic>.from(raw);
      final content = (data['content'] ?? '').toString();
      final now = DateTime.now();

      return ChatMessage(
        id: now.microsecondsSinceEpoch.toString(),
        conversationId: 'ai_conversation',
        userId: 'sitek_ai',
        body: content,
        content: content,
        role: 'assistant',
        type: (data['type'] ?? 'text').toString(),
        attachment: null,
        readAt: null,
        isMine: false,
        sender: const ChatSender(
          id: 'sitek_ai',
          name: 'Sitek AI',
          email: 'ai@halositek.com',
        ),
        createdAt: now,
        updatedAt: now,
      );
    }, 'Send AI Message');
  }

  Future<ConversationsPage> getConversations({
    int page = 1,
    int perPage = 10,
    String search = '',
  }) async {
    final response = await _apiClient.private.get(
      '/chat/conversations',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search.trim().isNotEmpty) 'search': search,
      },
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final rawList = response.data?['data'];
      final conversations = rawList is List
          ? rawList
              .whereType<Map>()
              .map((e) => ChatConversation.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <ChatConversation>[];
          
      final rawMeta = response.data?['meta'];
      final meta = rawMeta is Map
          ? ChatMeta.fromJson(Map<String, dynamic>.from(rawMeta))
          : const ChatMeta(currentPage: 1, lastPage: 1, perPage: 10, total: 0);

      return ConversationsPage(conversations: conversations, meta: meta);
    }, 'Fetch Conversations');
  }

  Future<ConversationDetailModel> getConversationDetail(String conversationId) async {
    final response = await _apiClient.private.get(
      '/chat/conversations/$conversationId',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final data = response.data?['data'];
      if (data == null || data is! Map) {
        throw Exception('Invalid conversation detail response format');
      }
      return ConversationDetailModel.fromJson(Map<String, dynamic>.from(data));
    }, 'Fetch Conversation Detail');
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final response = await _apiClient.private.get(
      '/chat/conversations/$conversationId/messages',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    debugPrint('Fetch Messages Response: ${response.data}');

    return _apiClient.customResponse(response, () async {
      final rawList = response.data?['data'];
      if (rawList is! List) return <ChatMessage>[];

      return rawList
          .whereType<Map>()
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }, 'Fetch Messages');
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final response = await _apiClient.private.post(
      '/chat/messages',
      data: {'conversation_id': conversationId, 'body': body},
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    debugPrint('\x1B[31m ${response.data}\x1B[0m');

    final isCreated = response.statusCode == 201;

    return _apiClient.customResponse(
      response,
      () async {
        final rawData = response.data?['data'];
        if (rawData is! Map) {
          throw Exception('Invalid send message response format');
        }

        return ChatMessage.fromJson(Map<String, dynamic>.from(rawData));
      },
      'Send Message',
      isCreated: isCreated,
    );
  }

  Future<void> sendTypingStatus(String conversationId, bool isTyping) async {
    final response = await _apiClient.private.post(
      '/chat/conversations/$conversationId/typing',
      data: {'is_typing': isTyping},
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(
      response,
      () async {},
      'Send Typing Status',
    );
  }

  Future<ChatMessage> sendImage({
    required String conversationId,
    required File imageFile,
    String? body,
  }) async {
    final fileName = imageFile.path.split('/').last.split('\\').last;
    final formData = FormData.fromMap({
      'conversation_id': conversationId,
      'type': 'image',
      if (body != null && body.trim().isNotEmpty) 'body': body.trim(),
      'attachment': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final response = await _apiClient.private.post(
      '/chat/messages',
      data: formData,
      options: Options(
        validateStatus: (status) => status != null && status < 500,
        contentType: 'multipart/form-data',
      ),
    );

    debugPrint('\x1B[32m Send Image Response: ${response.data}\x1B[0m');

    final isCreated = response.statusCode == 201;

    return _apiClient.customResponse(
      response,
      () async {
        final rawData = response.data?['data'];
        if (rawData is! Map) {
          throw Exception('Invalid send image response format');
        }
        return ChatMessage.fromJson(Map<String, dynamic>.from(rawData));
      },
      'Send Image',
      isCreated: isCreated,
    );
  }

  Future<ChatConversation> createConversation({
    required List<String> participantIds,
    String? name,
    bool isGroup = false,
  }) async {
    final response = await _apiClient.private.post(
      '/chat/conversations',
      data: {
        'name': name,
        'is_group': isGroup,
        'participant_ids': participantIds,
      },
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(
      response,
      () async {
        final raw = response.data?['data'];
        if (raw is! Map) {
          throw Exception('Invalid create conversation response');
        }
        return ChatConversation.fromJson(Map<String, dynamic>.from(raw));
      },
      'Create Conversation',
      isCreated: true,
    );
  }

  Future<ChatReport> submitReport({
    required String consultationId,
    required String reason,
  }) async {
    final response = await _apiClient.private.post(
      '/consultations/$consultationId/reports',
      data: {'consultation_id': consultationId, 'reason': reason},
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    debugPrint('\x1B[31m ${response.data}\x1B[0m');

    return _apiClient.customResponse(
      response,
      () async {
        final rawData = response.data?['data'];
        if (rawData is! Map) {
          throw Exception('Invalid report response format');
        }
        return ChatReport.fromJson(Map<String, dynamic>.from(rawData));
      },
      'Submit Report',
      isCreated: true,
    );
  }

  Future<ReportsPage> getReports(
    String userId, {
    int page = 1,
    int perPage = 10,
    String search = '',
  }) async {
    final response = await _apiClient.private.get(
      '/consultations/reports/users/$userId',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search.trim().isNotEmpty) 'search': search,
      },
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final rawList = response.data is List
          ? response.data
          : response.data?['data'];
      final reports = rawList is List
          ? rawList
              .whereType<Map>()
              .map((e) => ChatReport.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <ChatReport>[];

      final rawMeta = response.data?['meta'];
      final meta = rawMeta is Map
          ? ChatMeta.fromJson(Map<String, dynamic>.from(rawMeta))
          : const ChatMeta(currentPage: 1, lastPage: 1, perPage: 10, total: 0);

      return ReportsPage(reports: reports, meta: meta);
    }, 'Fetch Reports');
  }

  Future<void> markAsRead(String conversationId) async {
    final response = await _apiClient.private.post(
      '/chat/conversations/$conversationId/read',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(
      response,
      () async {},
      'Mark as Read',
    );
  }
  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AiChatMessagesPage {
  final List<ChatMessage> messages;
  final int perPage;
  final String? nextCursor;
  final bool hasMore;

  const AiChatMessagesPage({
    required this.messages,
    required this.perPage,
    required this.nextCursor,
    required this.hasMore,
  });
}

class ChatMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const ChatMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ChatMeta.fromJson(Map<String, dynamic> json) {
    return ChatMeta(
      currentPage: _toInt(json['current_page']),
      lastPage: _toInt(json['last_page']),
      perPage: _toInt(json['per_page']),
      total: _toInt(json['total']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ConversationsPage {
  final List<ChatConversation> conversations;
  final ChatMeta meta;

  const ConversationsPage({required this.conversations, required this.meta});
}

class ReportsPage {
  final List<ChatReport> reports;
  final ChatMeta meta;

  const ReportsPage({required this.reports, required this.meta});
}
