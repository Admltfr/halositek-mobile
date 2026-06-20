import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_dimensions.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/models/consultation_status.dart';
import 'package:halositek/app/data/network/architect_service.dart';
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
  final ArchitectService _architectService;
  final String catalogId;

  DetailController(
    this._catalogService,
    this._paymentService,
    this._chatService,
    this._tokenService,
    this._architectService, {
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
  final isDeleting = false.obs;
  final isStartingChat = false.obs;
  final isArchitectRole = false.obs;
  final paymentError = ''.obs;
  bool _hasCatalogChange = false;
  final architect = Rxn<Architect>();

  final consultationStatus = Rxn<ConsultationCheckStatus>();
  final isLoadingConsultationStatus = false.obs;
  String? _pendingTransactionId;
  final hasPendingPayment = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRole();
    _initMidtrans();
    fetchCatalogDetail();
  }

  void goBack() {
    final nav = Get.find<NavigationController>();
    nav.onPop(_hasCatalogChange ? catalog.value ?? true : null);
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
      architect.value = await _architectService.getArchitectById(
        result.architectId,
      );
      catalog.value = result;
      activeImageIndex.value = 0;
      activeLayoutIndex.value = 0;
      
      // Fetch consultation status
      await fetchConsultationStatus();
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
      _hasCatalogChange = true;
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
      _hasCatalogChange = true;
    } catch (e) {
      catalog.value = current;
      Get.snackbar('Gagal', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> openEdit() async {
    final nav = Get.find<NavigationController>().keyForTab(1)?.currentState;
    final result = await nav?.pushNamed(
      '/design/edit',
      arguments: catalog.value ?? catalogId,
    );

    if (result != null) {
      _hasCatalogChange = true;
      await fetchCatalogDetail();
    }
  }

  Future<void> confirmDeleteCatalog() async {
    if (isDeleting.value) return;

    await Get.dialog<void>(
      Dialog(
        backgroundColor: AppColors.whiteColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.errorColor,
                  size: 44,
                ),
                18.0.sh,
                Text(
                  'Confirm Delete',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textHeadingColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                16.0.sh,
                Text(
                  'Are you sure you want to delete this\ndesign ?',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textBodyColor,
                    height: 1.5,
                  ),
                ),
                32.0.sh,
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isDeleting.value ? null : deleteCatalog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3F46),
                      disabledBackgroundColor: const Color(
                        0xFFFF3F46,
                      ).withValues(alpha: 0.72),
                      foregroundColor: AppColors.textWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSmall,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isDeleting.value ? 'Deleting...' : 'Delete Design',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textWhiteColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                12.0.sh,
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isDeleting.value ? null : () => Get.back<void>(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8F7F6),
                      disabledBackgroundColor: const Color(0xFFF8F7F6),
                      foregroundColor: AppColors.textBodyColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSmall,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> deleteCatalog() async {
    final id = catalog.value?.id ?? catalogId;
    if (id.trim().isEmpty || isDeleting.value) return;

    try {
      isDeleting.value = true;
      await _catalogService.deleteCatalog(id);
      if (Get.isDialogOpen == true) {
        Get.back<void>();
      }
      Get.find<NavigationController>().onPop(true);
    } catch (e) {
      Get.snackbar('Delete gagal', e.toString());
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> fetchConsultationStatus() async {
    final architectIdValue = catalog.value?.architectId.trim() ?? '';
    if (architectIdValue.isEmpty) return;

    try {
      isLoadingConsultationStatus.value = true;
      final status = await _paymentService.checkConsultationStatus(architectIdValue);
      consultationStatus.value = status;

      // Sync pending payment data if status is pending_payment
      if (status.isPendingPayment && status.transactionId != null) {
        _pendingTransactionId = status.transactionId;
        hasPendingPayment.value = true;
      }
    } catch (e) {
      debugPrint('\x1B[31m CHECK STATUS ERROR: $e\x1B[0m');
    } finally {
      isLoadingConsultationStatus.value = false;
    }
  }

  void handleChatButtonAction() {
    final status = consultationStatus.value;
    if (status == null) return;

    if (status.isSessionActive) {
      // Open existing chat
      final conversationId = status.conversationId ?? '';
      if (conversationId.isNotEmpty) {
        _openChat(conversationId);
      } else {
        Get.snackbar('Gagal', 'Conversation ID tidak ditemukan');
      }
    } else if (status.isPendingPayment) {
      // Resume pending payment via Midtrans
      _resumePendingPayment(status);
    } else {
      // no_session: initiate new payment
      startConsultationChat();
    }
  }

  Future<void> _resumePendingPayment(ConsultationCheckStatus status) async {
    if (isStartingChat.value) return;

    final snapToken = status.snapToken ?? '';
    if (snapToken.isEmpty) {
      Get.snackbar('Gagal', 'Snap token tidak ditemukan');
      return;
    }

    isStartingChat.value = true;
    paymentError.value = '';

    try {
      _pendingTransactionId = status.transactionId;
      await _midtrans?.startPaymentUiFlow(token: snapToken);
    } catch (e) {
      paymentError.value = e.toString();
      Get.snackbar('Gagal', e.toString());
    } finally {
      isStartingChat.value = false;
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

      _pendingTransactionId = initiation.transactionId;
      hasPendingPayment.value = initiation.transactionId.isNotEmpty;

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
    return p.layoutImages;
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
    isStartingChat.value = true;
    paymentError.value = '';

    try {
      if (result.status == 'cancel') {
        Get.snackbar('Dibatalkan', 'Pembayaran dibatalkan.');
        return;
      }

      final transactionId = _pendingTransactionId?.trim() ?? '';
      if (transactionId.isEmpty) return;

      final status = await _paymentService.getStatus(transactionId);

      if (status.canEnterConsultation) {
        hasPendingPayment.value = false;
        _pendingTransactionId = null;
        final conversationId =
            status.conversationId.isNotEmpty
                ? status.conversationId
                : (await _chatService.createConversation(
                  participantIds: [catalog.value?.architectId ?? ''],
                )).id;

        _openChat(conversationId);
      } else {
        hasPendingPayment.value = true;
        Get.snackbar('Pending', 'Pembayaran belum selesai.');
      }
    } catch (e) {
      paymentError.value = e.toString();
      Get.snackbar('Gagal', e.toString());
    } finally {
      isStartingChat.value = false;
      // Refresh consultation status after payment flow
      fetchConsultationStatus();
    }
  }

  void _openChat(String conversationId) {
    Get.to(
      () => const ChatDetailView(),
      binding: ChatDetailBinding(
        conversationId: conversationId,
        title: architect.value?.name ?? 'Chat',
      ),
    );
  }
}
