class ArchitectEarnings {
  final int totalGrossEarnings;
  final int totalTaxPaid;
  final int totalNetEarnings;
  final List<ArchitectEarningItem> earnings;
  final ArchitectEarningsMeta meta;

  const ArchitectEarnings({
    required this.totalGrossEarnings,
    required this.totalTaxPaid,
    required this.totalNetEarnings,
    required this.earnings,
    required this.meta,
  });

  factory ArchitectEarnings.fromJson(Map<String, dynamic> json) {
    final rawEarnings = json['earnings'];

    return ArchitectEarnings(
      totalGrossEarnings: _toInt(json['total_gross_earnings']),
      totalTaxPaid: _toInt(json['total_tax_paid']),
      totalNetEarnings: _toInt(json['total_net_earnings']),
      earnings:
          rawEarnings is List
              ? rawEarnings
                  .whereType<Map>()
                  .map(
                    (e) => ArchitectEarningItem.fromJson(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList()
              : <ArchitectEarningItem>[],
      meta:
          json['meta'] is Map
              ? ArchitectEarningsMeta.fromJson(
                Map<String, dynamic>.from(json['meta']),
              )
              : ArchitectEarningsMeta.empty(),
    );
  }

  factory ArchitectEarnings.empty() {
    return ArchitectEarnings(
      totalGrossEarnings: 0,
      totalTaxPaid: 0,
      totalNetEarnings: 0,
      earnings: const <ArchitectEarningItem>[],
      meta: ArchitectEarningsMeta.empty(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ArchitectEarningItem {
  final String consultationId;
  final ArchitectEarningUser user;
  final DateTime? date;
  final int grossFee;
  final int taxDeduction;
  final int netEarning;
  final DateTime? releasedAt;

  const ArchitectEarningItem({
    required this.consultationId,
    required this.user,
    required this.date,
    required this.grossFee,
    required this.taxDeduction,
    required this.netEarning,
    required this.releasedAt,
  });

  factory ArchitectEarningItem.fromJson(Map<String, dynamic> json) {
    return ArchitectEarningItem(
      consultationId: (json['consultation_id'] ?? '').toString(),
      user:
          json['user'] is Map
              ? ArchitectEarningUser.fromJson(
                Map<String, dynamic>.from(json['user']),
              )
              : ArchitectEarningUser.empty(),
      date: DateTime.tryParse((json['date'] ?? '').toString()),
      grossFee: ArchitectEarnings._toInt(json['gross_fee']),
      taxDeduction: ArchitectEarnings._toInt(json['tax_deduction']),
      netEarning: ArchitectEarnings._toInt(json['net_earning']),
      releasedAt: DateTime.tryParse((json['released_at'] ?? '').toString()),
    );
  }
}

class ArchitectEarningUser {
  final String id;
  final String name;
  final String email;

  const ArchitectEarningUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ArchitectEarningUser.fromJson(Map<String, dynamic> json) {
    return ArchitectEarningUser(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  factory ArchitectEarningUser.empty() {
    return const ArchitectEarningUser(id: '', name: '-', email: '');
  }
}

class ArchitectEarningsMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const ArchitectEarningsMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ArchitectEarningsMeta.fromJson(Map<String, dynamic> json) {
    return ArchitectEarningsMeta(
      currentPage: ArchitectEarnings._toInt(json['current_page']),
      lastPage: ArchitectEarnings._toInt(json['last_page']),
      perPage: ArchitectEarnings._toInt(json['per_page']),
      total: ArchitectEarnings._toInt(json['total']),
    );
  }

  factory ArchitectEarningsMeta.empty() {
    return const ArchitectEarningsMeta(
      currentPage: 1,
      lastPage: 1,
      perPage: 15,
      total: 0,
    );
  }
}
