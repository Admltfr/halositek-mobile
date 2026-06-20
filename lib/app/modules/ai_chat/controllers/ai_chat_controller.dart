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

  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final searchResults = <int>[].obs;
  final currentSearchIndex = (-1).obs;
  final TextEditingController searchInputController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final Map<int, GlobalKey> messageKeys = {};

  Timer? _thinkingTimer;
  String? _nextCursor;
  bool _hasMore = true;
  bool _canLoadMoreHistory = false;
  bool _isRestoringLoadMoreScroll = false;
  int _scrollToBottomToken = 0;

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
    searchInputController.dispose();
    searchFocusNode.dispose();
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

  GlobalKey getKeyForMessage(int index) {
    if (!messageKeys.containsKey(index)) {
      messageKeys[index] = GlobalKey();
    }
    return messageKeys[index]!;
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchInputController.clear();
      searchQuery.value = '';
      searchResults.clear();
      currentSearchIndex.value = -1;
    } else {
      searchFocusNode.requestFocus();
    }
  }

  void performSearch(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      currentSearchIndex.value = -1;
      return;
    }
    
    final results = <int>[];
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].displayBody.toLowerCase().contains(query.toLowerCase())) {
        results.add(i);
      }
    }
    
    searchResults.assignAll(results);
    if (results.isNotEmpty) {
      currentSearchIndex.value = 0;
      _scrollToSearchResult(results[0]);
    } else {
      currentSearchIndex.value = -1;
    }
  }

  void nextSearchResult() {
    if (searchResults.isEmpty || currentSearchIndex.value >= searchResults.length - 1) return;
    currentSearchIndex.value++;
    _scrollToSearchResult(searchResults[currentSearchIndex.value]);
  }

  void previousSearchResult() {
    if (searchResults.isEmpty || currentSearchIndex.value <= 0) return;
    currentSearchIndex.value--;
    _scrollToSearchResult(searchResults[currentSearchIndex.value]);
  }

  void _scrollToSearchResult(int index) {
    final key = messageKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(key!.currentContext!, duration: const Duration(milliseconds: 300), alignment: 0.5);
    } else {
      if (scrollController.hasClients) {
        final total = messages.length;
        if (total == 0) return;
        final maxOffset = scrollController.position.maxScrollExtent;
        final offset = (index / total) * maxOffset;
        scrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut).then((_) {
          if (key?.currentContext != null) {
            Scrollable.ensureVisible(key!.currentContext!, duration: const Duration(milliseconds: 300), alignment: 0.5);
          }
        });
      }
    }
  }

  Future<void> clearChat() async {
    try {
      await _chatService.clearAiMessages();
      messages.clear();
      _nextCursor = null;
      _hasMore = true;
      _canLoadMoreHistory = false;
      messageKeys.clear();
      if (isSearching.value) toggleSearch();
      await fetchHistory();
    } catch (e) {
      Get.snackbar('Failed', e.toString());
    }
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
      await _scrollToBottom(animated: false);
      _canLoadMoreHistory = true;
    } catch (e) {
      Get.snackbar('Failed', e.toString());
      if (messages.isEmpty) {
        messages.assignAll([_welcomeMessage()]);
      }
      await _scrollToBottom(animated: false);
      _canLoadMoreHistory = true;
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> loadMoreHistory() async {
    if (isLoadingMore.value ||
        _isRestoringLoadMoreScroll ||
        !_canLoadMoreHistory ||
        !_hasMore ||
        _nextCursor == null) {
      return;
    }

    _scrollToBottomToken++;
    final previousMaxExtent =
        scrollController.hasClients
            ? scrollController.position.maxScrollExtent
            : 0.0;
    final previousPixels =
        scrollController.hasClients ? scrollController.position.pixels : 0.0;

    try {
      isLoadingMore.value = true;
      final page = await _chatService.getAiMessages(
        perPage: _perPage,
        cursor: _nextCursor,
      );
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;

      messages.insertAll(0, page.messages.reversed);
    } catch (e) {
      Get.snackbar('Failed', e.toString());
    } finally {
      await _restoreScrollAfterLoadMore(
        previousMaxExtent: previousMaxExtent,
        previousPixels: previousPixels,
      );
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
    if (!scrollController.hasClients ||
        !_canLoadMoreHistory ||
        isLoadingHistory.value ||
        isLoadingMore.value ||
        _isRestoringLoadMoreScroll) {
      return;
    }
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

  Future<void> _restoreScrollAfterLoadMore({
    required double previousMaxExtent,
    required double previousPixels,
  }) async {
    _isRestoringLoadMoreScroll = true;

    try {
      for (var attempt = 0; attempt < 4; attempt++) {
        await WidgetsBinding.instance.endOfFrame;
        if (!scrollController.hasClients) return;

        final addedHeight =
            scrollController.position.maxScrollExtent - previousMaxExtent;
        final target = previousPixels + addedHeight;
        final safeTarget = target.clamp(
          scrollController.position.minScrollExtent,
          scrollController.position.maxScrollExtent,
        );
        scrollController.jumpTo(safeTarget);
      }
    } finally {
      _isRestoringLoadMoreScroll = false;
    }
  }

  Future<void> _scrollToBottom({bool animated = true}) async {
    final token = ++_scrollToBottomToken;
    await WidgetsBinding.instance.endOfFrame;
    if (!scrollController.hasClients ||
        isLoadingMore.value ||
        _isRestoringLoadMoreScroll ||
        token != _scrollToBottomToken) {
      return;
    }

    final bottom = scrollController.position.maxScrollExtent;
    if (animated) {
      await scrollController.animateTo(
        bottom,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      scrollController.jumpTo(bottom);
      await WidgetsBinding.instance.endOfFrame;
      if (scrollController.hasClients && token == _scrollToBottomToken) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    }
  }
}
