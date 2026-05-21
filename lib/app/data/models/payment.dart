class PaymentDetails {
  final String architectId;
  final String architectName;
  final String architectPhoto;
  final int durationHours;
  final int consultationAmount;
  final int taxAmount;
  final int totalAmount;

  const PaymentDetails({
    required this.architectId,
    required this.architectName,
    required this.architectPhoto,
    required this.durationHours,
    required this.consultationAmount,
    required this.taxAmount,
    required this.totalAmount,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      architectId: (json['architect_id'] ?? '').toString(),
      architectName: (json['architect_name'] ?? '').toString(),
      architectPhoto: (json['architect_photo'] ?? '').toString(),
      durationHours: _toInt(json['duration_hours']),
      consultationAmount: _toInt(json['consultation_amount']),
      taxAmount: _toInt(json['tax_amount']),
      totalAmount: _toInt(json['total_amount']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class Payment {
  final String paymentId;
  final String orderId;
  final String status;
  final String snapToken;
  final String redirectUrl;
  final PaymentDetails? details;

  const Payment({
    required this.paymentId,
    required this.orderId,
    required this.status,
    required this.snapToken,
    required this.redirectUrl,
    required this.details,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final detailsRaw = json['consultation_details'];
    return Payment(
      paymentId: (json['payment_id'] ?? '').toString(),
      orderId: (json['order_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      snapToken: (json['snap_token'] ?? '').toString(),
      redirectUrl: (json['redirect_url'] ?? '').toString(),
      details:
          detailsRaw is Map
              ? PaymentDetails.fromJson(detailsRaw.cast<String, dynamic>())
              : null,
    );
  }
}

class PaymentStatus {
  final String paymentId;
  final String orderId;
  final String status;
  final String transactionId;
  final String consultationId;
  final String conversationId;
  final bool canEnterConsultation;
  final DateTime? paidAt;

  const PaymentStatus({
    required this.paymentId,
    required this.orderId,
    required this.status,
    required this.transactionId,
    required this.consultationId,
    required this.conversationId,
    required this.canEnterConsultation,
    required this.paidAt,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      paymentId: (json['payment_id'] ?? '').toString(),
      orderId: (json['order_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      transactionId: (json['transaction_id'] ?? '').toString(),
      consultationId: (json['consultation_id'] ?? '').toString(),
      conversationId: (json['conversation_id'] ?? '').toString(),
      canEnterConsultation: json['can_enter_consultation'] == true,
      paidAt: DateTime.tryParse((json['paid_at'] ?? '').toString()),
    );
  }

  bool get isCompleted => status == 'completed';
}
