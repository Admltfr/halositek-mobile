import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/models/consultation_status.dart';
import 'package:halositek/app/data/network/architect_service.dart';
import 'package:halositek/app/data/network/award_service.dart';
import 'package:halositek/app/data/network/catalog_service.dart';
import 'package:halositek/app/data/network/chat_service.dart';
import 'package:halositek/app/data/network/payment_service.dart';
import 'package:halositek/app/modules/chat_detail/bindings/chat_detail_binding.dart';
import 'package:halositek/app/modules/chat_detail/views/chat_detail_view.dart';
import 'package:halositek/app/modules/navigation/controllers/navigation_controller.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';

class PortofolioController extends GetxController {
  final CatalogService _catalogService;
  final AwardService _awardService;
  final PaymentService _paymentService;
  final ChatService _chatService;
  final ArchitectService _architectService;
  final String architectId;

  PortofolioController(
    this._catalogService,
    this._awardService,
    this._paymentService,
    this._chatService,
    this._architectService, {
    required this.architectId,
  });

  MidtransSDK? _midtrans;
  String? _pendingTransactionId;

  final String? clientKey = dotenv.env['CLIENT_KEY'];

  final activeTab = 0.obs;

  final portfolios = <Catalog>[].obs;
  final awards = <Award>[].obs;

  final isLoadingPortfolio = false.obs;
  final isLoadingAward = false.obs;
  final isLoadingArchitect = false.obs;
  final isSavingArchitect = false.obs;
  final portfolioError = ''.obs;
  final awardError = ''.obs;
  final architectError = ''.obs;

  final isStartingChat = false.obs;
  final paymentError = ''.obs;
  final hasPendingPayment = false.obs;

  final consultationStatus = Rxn<ConsultationCheckStatus>();
  final isLoadingConsultationStatus = false.obs;

  final architectName = 'David Larsson'.obs;
  final architectTitle = 'Principal Architect'.obs;
  final experienceLabel = "15 Years Experience".obs;
  final architectPhoto = ''.obs;
  final architectBio =
      'Specializing in sustainable modern residential architecture and urban planning with a focus on minimalist aesthetics and eco-friendly materials.'
          .obs;
  final totalProjects = 0.obs;
  final totalAwards = 0.obs;
  final consultationFee = 25000.obs;
  final consultationDuration = 2.obs;
  final isWishlisted = RxnBool();

  @override
  void onInit() {
    super.onInit();
    fetchPortfolios();
    fetchAwards();
    fetchArchitect();
    fetchConsultationStatus();
    _initMidtrans();
  }

  void setTab(int index) => activeTab.value = index;

  void goBack() {
    final nav = Get.find<NavigationController>();
    nav.onPop();
  }

  Future<void> refreshPortofolio() async {
    await Future.wait([fetchArchitect(), fetchPortfolios(), fetchAwards(), fetchConsultationStatus()]);
  }

  Future<void> fetchArchitect() async {
    debugPrint('\x1B[31m $architectId\x1B[0m');
    try {
      isLoadingArchitect.value = true;
      architectError.value = '';
      final architect = await _architectService.getArchitectById(architectId);
      architectName.value = architect.name;
      architectPhoto.value = architect.profilePicture;
      architectTitle.value = architect.headline.isNotEmpty ? architect.headline : architectTitle.value;
      experienceLabel.value =
          architect.specialization.isNotEmpty ? architect.specialization : '${architect.totalProjects} Projects';
      architectBio.value = architect.bio.isNotEmpty ? architect.bio : architectBio.value;
      totalProjects.value = architect.totalProjects;
      totalAwards.value = architect.totalAwards;
      consultationFee.value = architect.consultationFee;
      consultationDuration.value =
          architect.consultationDuration > 0 ? architect.consultationDuration : consultationDuration.value;
      isWishlisted.value = architect.isWishlisted;
    } catch (e) {
      architectError.value = e.toString();
    } finally {
      isLoadingArchitect.value = false;
    }
  }

  Future<void> toggleSaveArchitect() async {
    if (isSavingArchitect.value) return;

    final architectIdValue = architectId.trim();
    if (architectIdValue.isEmpty) {
      Get.snackbar('Gagal', 'Architect ID tidak ditemukan');
      return;
    }

    isSavingArchitect.value = true;

    try {
      if (isWishlisted.value == true) {
        await _architectService.unsaveArchitect(architectIdValue);
      } else {
        await _architectService.saveArchitect(architectIdValue);
      }

      await fetchArchitect();
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
    } finally {
      isSavingArchitect.value = false;
    }
  }

  Future<void> fetchPortfolios() async {
    try {
      isLoadingPortfolio.value = true;
      portfolioError.value = '';
      final result = await _catalogService.getCatalogs(perPage: 12, architectId: architectId);
      portfolios.assignAll(result);
    } catch (e) {
      portfolioError.value = e.toString();
    } finally {
      isLoadingPortfolio.value = false;
    }
  }

  Future<void> fetchAwards() async {
    try {
      isLoadingAward.value = true;
      awardError.value = '';
      final result = await _awardService.getAwards(perPage: 12, architectId: architectId);
      awards.assignAll(result);
    } catch (e) {
      awardError.value = e.toString();
    } finally {
      isLoadingAward.value = false;
    }
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

  Future<void> fetchConsultationStatus() async {
    final architectIdValue = architectId.trim();
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

  /// Routes to the correct action based on consultation status
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

    final architectIdValue = architectId.trim();
    if (architectIdValue.isEmpty) {
      Get.snackbar('Gagal', 'Architect ID tidak ditemukan');
      return;
    }

    isStartingChat.value = true;
    paymentError.value = '';

    try {
      final initiation = await _paymentService.initiate(architectId: architectIdValue);
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

  Future<void> _onPaymentFinished(TransactionResult result) async {
    isStartingChat.value = true;
    paymentError.value = '';

    try {
      if (result.status == 'cancel') {
        Get.snackbar('Dibatalkan', 'Pembayaran dibatalkan.');
        return;
      }

      await _checkPaymentStatus();
    } catch (e) {
      paymentError.value = e.toString();
      Get.snackbar('Gagal', e.toString());
    } finally {
      isStartingChat.value = false;
      // Refresh consultation status after payment flow
      fetchConsultationStatus();
    }
  }

  Future<void> checkPaymentStatus() async {
    if (isStartingChat.value) return;

    final transactionId = _pendingTransactionId?.trim() ?? '';
    if (transactionId.isEmpty) {
      return;
    }

    isStartingChat.value = true;
    paymentError.value = '';

    try {
      await _checkPaymentStatus();
    } catch (e) {
      paymentError.value = e.toString();
      Get.snackbar('Gagal', e.toString());
    } finally {
      isStartingChat.value = false;
    }
  }

  Future<void> _checkPaymentStatus() async {
    final transactionId = _pendingTransactionId?.trim() ?? '';
    if (transactionId.isEmpty) {
      return;
    }

    final status = await _paymentService.getStatus(transactionId);

    if (status.canEnterConsultation) {
      hasPendingPayment.value = false;
      _pendingTransactionId = null;
      final conversationId =
          status.conversationId.isNotEmpty
              ? status.conversationId
              : (await _chatService.createConversation(participantIds: [architectId])).id;

      _openChat(conversationId);
    } else {
      hasPendingPayment.value = true;
      Get.snackbar('Pending', 'Pembayaran belum selesai.');
    }
  }

  void _openChat(String conversationId) {
    Get.to(
      () => const ChatDetailView(),
      binding: ChatDetailBinding(conversationId: conversationId, title: architectName.value),
    );
  }
}
