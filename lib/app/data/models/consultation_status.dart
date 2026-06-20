class ConsultationCheckStatus {
  final String status;
  final String? consultationId;
  final String? conversationId;
  final String? transactionId;
  final String? consultationDate;
  final RemainingTime? remainingTime;
  final String? paymentId;
  final String? orderId;
  final String? snapToken;
  final String? redirectUrl;
  final int? amount;
  final ConsultationArchitect? architect;
  final int? consultationFee;
  final int? durationHours;

  const ConsultationCheckStatus({
    required this.status,
    this.consultationId,
    this.conversationId,
    this.transactionId,
    this.consultationDate,
    this.remainingTime,
    this.paymentId,
    this.orderId,
    this.snapToken,
    this.redirectUrl,
    this.amount,
    this.architect,
    this.consultationFee,
    this.durationHours,
  });

  factory ConsultationCheckStatus.fromJson(Map<String, dynamic> json) {
    return ConsultationCheckStatus(
      status: (json['status'] ?? '').toString(),
      consultationId: json['consultation_id']?.toString(),
      conversationId: json['conversation_id']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      consultationDate: json['consultation_date']?.toString(),
      remainingTime:
          json['remaining_time'] is Map ? RemainingTime.fromJson(Map<String, dynamic>.from(json['remaining_time'])) : null,
      paymentId: json['payment_id']?.toString(),
      orderId: json['order_id']?.toString(),
      snapToken: json['snap_token']?.toString(),
      redirectUrl: json['redirect_url']?.toString(),
      amount: _toIntOrNull(json['amount']),
      architect:
          json['architect'] is Map ? ConsultationArchitect.fromJson(Map<String, dynamic>.from(json['architect'])) : null,
      consultationFee: _toIntOrNull(json['consultation_fee']),
      durationHours: _toIntOrNull(json['duration_hours']),
    );
  }

  bool get isNoSession => status == 'no_session';
  bool get isPendingPayment => status == 'pending_payment';
  bool get isSessionActive => status == 'session_active';

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class RemainingTime {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  const RemainingTime({required this.days, required this.hours, required this.minutes, required this.seconds});

  factory RemainingTime.fromJson(Map<String, dynamic> json) {
    return RemainingTime(
      days: _toInt(json['days']),
      hours: _toInt(json['hours']),
      minutes: _toInt(json['minutes']),
      seconds: _toInt(json['seconds']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ConsultationArchitect {
  final String id;
  final String name;
  final String photoProfileUrl;

  const ConsultationArchitect({required this.id, required this.name, required this.photoProfileUrl});

  factory ConsultationArchitect.fromJson(Map<String, dynamic> json) {
    return ConsultationArchitect(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      photoProfileUrl: (json['photo_profile_url'] ?? '').toString(),
    );
  }
}
