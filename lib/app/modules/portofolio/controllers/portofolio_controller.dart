import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/api_client.dart';
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

  final String? client_key = dotenv.env['CLIENT_KEY'];

  final activeTab = 0.obs;

  final portfolios = <Catalog>[].obs;
  final awards = <Award>[].obs;

  final isLoadingPortfolio = false.obs;
  final isLoadingAward = false.obs;
  final isLoadingArchitect = false.obs;
  final portfolioError = ''.obs;
  final awardError = ''.obs;
  final architectError = ''.obs;

  final isStartingChat = false.obs;
  final paymentError = ''.obs;

  final architectName = 'David Larsson'.obs;
  final architectTitle = 'Principal Architect'.obs;
  final experienceLabel = "15 Years Experience".obs;

  @override
  void onInit() {
    super.onInit();
    fetchPortfolios();
    fetchAwards();
    fetchArchitect();
    _initMidtrans();
  }

  void setTab(int index) => activeTab.value = index;

  void goBack() {
    final nav = Get.find<NavigationController>();
    nav.onPop();
  }

  Future<void> fetchArchitect() async {
    debugPrint('\x1B[31m ${architectId}\x1B[0m');
    try {
      isLoadingArchitect.value = true;
      architectError.value = '';
      final architect = await _architectService.getArchitectById(architectId);
      architectName.value = architect.name;
      architectTitle.value =
          architect.headline.isNotEmpty
              ? architect.headline
              : architectTitle.value;
      experienceLabel.value = '${architect.totalProjects} Projects';
    } catch (e) {
      architectError.value = e.toString();
    } finally {
      isLoadingArchitect.value = false;
    }
  }

  Future<void> fetchPortfolios() async {
    try {
      isLoadingPortfolio.value = true;
      portfolioError.value = '';
      final result = await _catalogService.getCatalogs(
        perPage: 12,
        architectId: architectId,
      );
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
      final result = await _awardService.getAwards(
        perPage: 12,
        architectId: architectId,
      );
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
        clientKey: client_key ?? '',
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

  Future<void> _onPaymentFinished(TransactionResult result) async {
    if (result.status == 'cancel') {
      Get.snackbar('Dibatalkan', 'Pembayaran dibatalkan.');
      return;
    }

    final transactionId = result.transactionId ?? '';
    if (transactionId.isEmpty) {
      return;
    }

    final status = await _paymentService.getStatus(transactionId);

    if (status.canEnterConsultation) {
      final conversationId =
          status.conversationId.isNotEmpty
              ? status.conversationId
              : (await _chatService.createConversation(
                participantIds: [architectId],
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
        title: architectName.value,
      ),
    );
  }
}
