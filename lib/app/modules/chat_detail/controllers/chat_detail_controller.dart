import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:halositek/app/data/network/chat_service.dart';

class ChatDetailController extends GetxController {
  final ChatService _chatService;
  final String conversationId;
  final String title;

  ChatDetailController(
    this._chatService, {
    required this.conversationId,
    required this.title,
  });

  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final errorMessage = ''.obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String get displayTitle => title.trim().isNotEmpty ? title : 'Chat';

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void goBack() {
    Get.back();
  }

  Future<void> fetchMessages() async {
    if (conversationId.trim().isEmpty) {
      errorMessage.value = 'Conversation ID tidak ditemukan';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _chatService.getMessages(conversationId);
      messages.assignAll(result);
      _scrollToBottom();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    if (isSending.value) return;

    final text = messageController.text.trim();
    if (text.isEmpty) return;

    isSending.value = true;
    messageController.clear();

    try {
      final message = await _chatService.sendMessage(
        conversationId: conversationId,
        body: text,
      );
      messages.add(message);
      _scrollToBottom();
    } catch (e) {
      messageController.text = text;
      Get.snackbar('Failed', e.toString());
    } finally {
      isSending.value = false;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}
