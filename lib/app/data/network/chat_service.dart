import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:halositek/app/data/models/chat_conversation.dart';
import 'package:halositek/app/data/models/chat_message.dart';
import 'package:halositek/app/data/network/api_client.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService(this._apiClient);

  Future<List<ChatConversation>> getConversations() async {
    final response = await _apiClient.private.get(
      '/chat/conversations',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final rawList = response.data?['data'];
      if (rawList is! List) return <ChatConversation>[];

      return rawList
          .whereType<Map>()
          .map((e) => ChatConversation.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }, 'Fetch Conversations');
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
    debugPrint('\x1B[31m ${conversationId}\x1B[0m');
    final response = await _apiClient.private.post(
      '/chat/messages',
      data: {'conversation_id': conversationId, 'body': body},
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    debugPrint('\x1B[31m ${response.data['data']}\x1B[0m');

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
}
