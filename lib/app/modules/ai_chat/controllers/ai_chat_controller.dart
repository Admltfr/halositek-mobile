import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:halositek/app/data/network/chat_service.dart';

class AiChatController extends GetxController {
  final ChatService _chatService;

  AiChatController(this._chatService);

  final messages = <ChatMessage>[].obs;
  final isLoadingHistory = false.obs;
  final isLoadingMore = false.obs;
  final isAiThinking = false.obs;
  final thinkingText = 'Just a sec, looking that up...'.obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Timer? _thinkingTimer;
  String? _nextCursor;
  bool _hasMore = true;

  static const int _perPage = 10;

  final List<String> suggestions = [
    'Konsep rumah minimalis modern 2 lantai',
    'Estimasi biaya bangun rumah tipe 36',
    'Rekomendasi gaya interior lahan sempit',
    'Berapa lama proyek desain arsitektur?',
  ];

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);
    fetchHistory();
  }

  @override
  void onClose() {
    _thinkingTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void goBack() {
    Get.back();
  }

  ChatMessage _createMessage({required String text, required bool isMine}) {
    final now = DateTime.now();

    return ChatMessage(
      id: now.microsecondsSinceEpoch.toString(),
      conversationId: 'ai_conversation',
      userId: isMine ? 'user' : 'sitek_ai',
      body: text,
      content: text,
      role: isMine ? 'user' : 'assistant',
      type: 'text',
      attachment: null,
      readAt: null,
      isMine: isMine,
      sender:
          isMine
              ? const ChatSender(
                id: 'user',
                name: 'User',
                email: 'user@halositek.com',
              )
              : const ChatSender(
                id: 'sitek_ai',
                name: 'Sitek AI',
                email: 'ai@halositek.com',
              ),
      createdAt: now,
      updatedAt: now,
    );
  }

  void selectSuggestion(String suggestion) {
    if (isAiThinking.value) return;
    sendMessage(customText: suggestion);
  }

  Future<void> fetchHistory() async {
    if (isLoadingHistory.value) return;

    try {
      isLoadingHistory.value = true;
      final page = await _chatService.getAiMessages(perPage: _perPage);
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;

      final orderedMessages = page.messages.reversed.toList();
      if (orderedMessages.isEmpty) {
        messages.assignAll([_welcomeMessage()]);
      } else {
        messages.assignAll(orderedMessages);
      }
      _scrollToBottom();
    } catch (e) {
      Get.snackbar('Failed', e.toString());
      if (messages.isEmpty) {
        messages.assignAll([_welcomeMessage()]);
      }
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> loadMoreHistory() async {
    if (isLoadingMore.value || !_hasMore || _nextCursor == null) return;

    final previousMaxExtent =
        scrollController.hasClients
            ? scrollController.position.maxScrollExtent
            : 0.0;
    final previousOffset =
        scrollController.hasClients ? scrollController.offset : 0.0;

    try {
      isLoadingMore.value = true;
      final page = await _chatService.getAiMessages(
        perPage: _perPage,
        cursor: _nextCursor,
      );
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;

      messages.insertAll(0, page.messages.reversed);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        final delta =
            scrollController.position.maxScrollExtent - previousMaxExtent;
        scrollController.jumpTo(previousOffset + delta);
      });
    } catch (e) {
      Get.snackbar('Failed', e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> sendMessage({String? customText}) async {
    if (isAiThinking.value) return;

    final text = customText ?? messageController.text.trim();
    if (text.isEmpty) return;

    if (customText == null) {
      messageController.clear();
    }

    messages.add(_createMessage(text: text, isMine: true));
    _scrollToBottom();

    _startThinking();
    try {
      final response = await _chatService.sendAiMessage(text);
      messages.add(response);
    } catch (e) {
      Get.snackbar('Failed', e.toString());
      messageController.text = text;
    } finally {
      _stopThinking();
      _scrollToBottom();
    }
  }

  ChatMessage _welcomeMessage() {
    return _createMessage(
      text:
          'Halo! Saya Sitek AI, asisten arsitektur digital Anda. Ada yang bisa saya bantu hari ini mengenai desain rumah impian atau estimasi biaya konstruksi?',
      isMine: false,
    );
  }

  void _handleScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.offset <= 80) {
      loadMoreHistory();
    }
  }

  void _startThinking() {
    const texts = [
      'Just a sec, looking that up...',
      'Give me a moment to think...',
      'Working on it...',
    ];
    var index = 0;

    thinkingText.value = texts[index];
    isAiThinking.value = true;
    _scrollToBottom();

    _thinkingTimer?.cancel();
    _thinkingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      index = (index + 1) % texts.length;
      thinkingText.value = texts[index];
    });
  }

  void _stopThinking() {
    _thinkingTimer?.cancel();
    _thinkingTimer = null;
    isAiThinking.value = false;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
