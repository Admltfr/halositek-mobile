import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/chat.dart';
import 'package:halositek/app/data/network/chat_service.dart';

class ChatDetailController extends GetxController {
  final ChatService _chatService;
  final String conversationId;
  final String consultationId;
  final String title;
  final int durationHours;
  final String conversationStatus;

  ChatDetailController(
    this._chatService, {
    required this.conversationId,
    required this.consultationId,
    required this.title,
    this.durationHours = 0,
    this.conversationStatus = '',
  });

  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final errorMessage = ''.obs;
  final isSessionExpired = false.obs;
  final sessionExpiredAt = Rxn<DateTime>();
  final reports = <ChatReport>[].obs;
  final isSubmittingReport = false.obs;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController reportController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Timer? _expiryTimer;

  String get displayTitle => title.trim().isNotEmpty ? title : 'Chat';

  String get currentStatus => conversationStatus.toLowerCase();

  bool get hasApproved => currentStatus == 'approved';
  bool get hasDeclined => currentStatus == 'declined';
  bool get hasReported => currentStatus == 'new';

  @override
  void onInit() {
    super.onInit();
    _initSessionExpiry();
    fetchMessages();
  }

  @override
  void onClose() {
    _expiryTimer?.cancel();
    messageController.dispose();
    reportController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _initSessionExpiry() {
    if (durationHours <= 0) {
      isSessionExpired.value = false;
      return;
    }

    _scheduleExpiryCheck();
  }

  void _scheduleExpiryCheck() {
    _expiryTimer?.cancel();
    if (durationHours <= 0) return;

    _expiryTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkExpiry();
    });

    _checkExpiry();
  }

  void _checkExpiry() {
    final expiry = sessionExpiredAt.value;
    if (expiry == null) return;
    isSessionExpired.value = DateTime.now().isAfter(expiry);
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

      if (result.isNotEmpty && result.first.createdAt != null) {
        final sessionStart = result.first.createdAt!;
        final expiry = sessionStart.add(Duration(hours: durationHours));
        sessionExpiredAt.value = expiry;
        _scheduleExpiryCheck();
      }

      _scrollToBottom();

      try {
        await _chatService.markAsRead(conversationId);
      } catch (e) {
        debugPrint('Failed to mark as read: $e');
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    if (isSending.value) return;
    if (isSessionExpired.value) return;

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
      Get.snackbar(
        'Gagal mengirim',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> pickAndSendImage() async {
    if (isSending.value) return;
    if (isSessionExpired.value) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;

      await sendImage(File(path));
    } catch (e) {
      Get.snackbar(
        'Gagal memilih gambar',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> sendImage(File imageFile) async {
    if (isSending.value) return;

    isSending.value = true;

    try {
      final message = await _chatService.sendImage(
        conversationId: conversationId,
        imageFile: imageFile,
      );
      messages.add(message);
      _scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'Gagal mengirim gambar',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> submitReport() async {
    final reason = reportController.text.trim();
    if (reason.isEmpty) return;
    if (isSubmittingReport.value) return;

    isSubmittingReport.value = true;

    try {
      await _chatService.submitReport(
        consultationId: consultationId,
        reason: reason,
      );
      reportController.clear();
      Get.back(); // Close modal
      Get.snackbar(
        'Laporan Terkirim',
        'Laporan konsultasi Anda telah berhasil dikirim.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Mengirim Laporan',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmittingReport.value = false;
    }
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
