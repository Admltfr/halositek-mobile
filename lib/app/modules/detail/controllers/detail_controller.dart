import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/data/network/payment_service.dart';
import 'package:halositek/app/data/network/token_service.dart';
import 'package:halositek/app/modules/chat_detail/bindings/chat_detail_binding.dart';
import 'package:halositek/app/modules/chat_detail/views/chat_detail_view.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';

class DetailController extends GetxController {
  final CatalogService _catalogService;
  final PaymentService _paymentService;
  final ChatService _chatService;
  final TokenService _tokenService;
  final String catalogId;

  DetailController(
    this._catalogService,
    this._paymentService,
    this._chatService,
    this._tokenService, {
    required this.catalogId,
  });

  MidtransSDK? _midtrans;
  final String? clientKey = dotenv.env['CLIENT_KEY'];

  final catalog = Rxn<Catalog>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final activeImageIndex = 0.obs;
  final activeLayoutIndex = 0.obs;
  final isLiking = false.obs;
  final isSaving = false.obs;
  final isStartingChat = false.obs;
  final isArchitectRole = false.obs;
  final paymentError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRole();
    _initMidtrans();
    fetchCatalogDetail();
  }

  void goBack() {
    final nav = Get.find<NavigationController>();
    nav.onPop();
  }

  Future<void> fetchCatalogDetail() async {
    if (catalogId.trim().isEmpty) {
      errorMessage.value = 'Project ID tidak ditemukan';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _catalogService.getCatalogById(catalogId);
      catalog.value = result;
      activeImageIndex.value = 0;
      activeLayoutIndex.value = 0;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike() async {
    final current = catalog.value;
    if (current == null || current.id.isEmpty || isLiking.value) return;

    isLiking.value = true;

    final liked = !current.liked;
    catalog.value = current.copyWith(
      liked: liked,
      likesCount: (current.likesCount + (liked ? 1 : -1)).clamp(0, 999999),
    );

    try {
      if (liked) {
        await _catalogService.likeCatalog(current.id);
      } else {
        await _catalogService.unlikeCatalog(current.id);
      }
    } catch (_) {
      catalog.value = current;
    } finally {
      isLiking.value = false;
    }
  }

  Future<void> toggleSave() async {
    final current = catalog.value;
    if (current == null || current.id.isEmpty || isSaving.value) return;

    isSaving.value = true;
    final saved = !current.saved;
    catalog.value = current.copyWith(saved: saved);

    try {
      if (saved) {
        await _catalogService.saveCatalog(current.id);
      } else {
        await _catalogService.unsaveCatalog(current.id);
      }
    } catch (e) {
      catalog.value = current;
      Get.snackbar('Gagal', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> startConsultationChat() async {
    if (isStartingChat.value) return;

    final architectIdValue = (catalog.value?.architectId ?? '').trim();
    if (architectIdValue.isEmpty) {
      Get.snackbar('Gagal', 'Architect ID tidak ditemukan');
      return;
    }

    isStartingChat.value = true;
    paymentError.value = '';

    try {
      final initiation = await _paymentService.initiate(
        architectId: architectIdValue,
      );

      await _midtrans?.startPaymentUiFlow(token: initiation.snapToken);
    } catch (e) {
      paymentError.value = e.toString();
      Get.snackbar('Gagal', e.toString());
    } finally {
      isStartingChat.value = false;
    }
  }

  void setActiveImageIndex(int index) {
    activeImageIndex.value = index;
  }

  void setActiveLayoutIndex(int index) {
    activeLayoutIndex.value = index;
  }

  List<String> get projectImages {
    final p = catalog.value;
    if (p == null) return const <String>[];
    return p.imageUrls.isNotEmpty ? p.imageUrls : p.images;
  }

  List<String> get projectLayoutImages {
    final p = catalog.value;
    if (p == null) return const <String>[];
    return p.layoutImageUrls.isNotEmpty ? p.layoutImageUrls : p.layoutImages;
  }

  String get architectName {
    final p = catalog.value;
    return p?.architect?.name.isNotEmpty == true ? p!.architect!.name : '-';
  }

  String get architectEmail {
    final p = catalog.value;
    return p?.architect?.email.isNotEmpty == true ? p!.architect!.email : '-';
  }

  String get architectPhoto {
    final p = catalog.value;
    return p?.architect?.profilePicture.isNotEmpty == true
        ? p!.architect!.profilePicture
        : '';
  }

  int get consultationFee {
    final value = catalog.value?.architect?.consultationFee ?? 0;
    return value > 0 ? value : 25000;
  }

  int get consultationDuration {
    final value = catalog.value?.architect?.consultationDuration ?? 0;
    return value > 0 ? value : 2;
  }

  String get areaDisplay {
    final p = catalog.value;
    if (p == null || p.areaRaw.trim().isEmpty) return '-';
    return p.areaRaw;
  }

  String get estimatedCostDisplay {
    final p = catalog.value;
    if (p == null || p.estimatedCost.trim().isEmpty) return '-';
    return p.estimatedCost;
  }

  Future<void> _loadRole() async {
    final role = (await _tokenService.getRole() ?? '').trim().toLowerCase();
    isArchitectRole.value = role == 'architect';
  }

  Future<void> _initMidtrans() async {
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: clientKey ?? '',
        merchantBaseUrl: 'https://app.sandbox.midtrans.com/',
        colorTheme: ColorTheme(
          colorPrimary: AppColors.primaryColor,
          colorPrimaryDark: AppColors.primaryColor,
          colorSecondary: AppColors.secondaryColor,
        ),
        language: 'id',
        enableLog: true,
      ),
    );

    _midtrans?.setTransactionFinishedCallback((result) {
      _onPaymentFinished(result);
      debugPrint('\x1B[31m STATUS: ${result.status}\x1B[0m');
      debugPrint('\x1B[31m TRANSACTION ID: ${result.transactionId}\x1B[0m');
      debugPrint('\x1B[31m TRANSACTION ID: ${result.message}\x1B[0m');
    });
  }

  Future<void> _onPaymentFinished(TransactionResult result) async {
    if (result.status == 'cancel') {
      Get.snackbar('Dibatalkan', 'Pembayaran dibatalkan.');
      return;
    }

    final transactionId = result.transactionId ?? '';
    if (transactionId.isEmpty) return;

    final status = await _paymentService.getStatus(transactionId);

    if (status.canEnterConsultation) {
      final conversationId =
          status.conversationId.isNotEmpty
              ? status.conversationId
              : (await _chatService.createConversation(
                participantIds: [catalog.value?.architectId ?? ''],
              )).id;

      _openChat(conversationId);
    } else {
      Get.snackbar('Pending', 'Pembayaran belum selesai.');
    }
  }

  void _openChat(String conversationId) {
    Get.to(
      () => const ChatDetailView(),
      binding: ChatDetailBinding(
        conversationId: conversationId,
        title: architectName,
      ),
    );
  }
}
