import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/core/constants/app_colors.dart';
import 'package:halositek/app/core/constants/app_extensions.dart';
import 'package:halositek/app/core/constants/app_typography.dart';
import 'package:halositek/app/modules/profile/controllers/profile_controller.dart';
import 'package:halositek/app/modules/profile/widgets/profile_common_widgets.dart';
import 'package:halositek/app/modules/profile/widgets/profile_top_bar.dart';

class PaymentHistoryView extends GetView<ProfileController> {
  const PaymentHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.01),
          child: Column(
            children: [
              ProfileTopBar(title: 'Payment History', onBack: controller.goBack),
              Expanded(
                child: Obx(() {
                  final items = controller.paymentHistories;
                  if (items.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        16.0.sh,
                        Icon(Icons.payment_outlined, size: 32, color: AppColors.textBodyColor),
                        12.0.sh,
                        Text(
                          'Belum ada riwayat pembayaran.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textBodyColor),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => 10.0.sh,
                    itemBuilder: (_, index) => PaymentHistoryCard(payment: items[index], positive: true),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
