import 'package:dio/dio.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/api_client.dart';

class DashboardSummary {
  final int totalSavedDesigns;
  final int totalSavedArchitects;
  final int totalConsultations;

  const DashboardSummary({
    required this.totalSavedDesigns,
    required this.totalSavedArchitects,
    required this.totalConsultations,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalSavedDesigns: _toInt(json['total_saved_designs']),
      totalSavedArchitects: _toInt(json['total_saved_architects']),
      totalConsultations: _toInt(json['total_consultations']),
    );
  }

  factory DashboardSummary.empty() {
    return const DashboardSummary(
      totalSavedDesigns: 0,
      totalSavedArchitects: 0,
      totalConsultations: 0,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  Future<DashboardSummary> getSummary() async {
    final response = await _apiClient.private.get(
      '/dashboard/summary',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'] ?? response.data;
      if (raw is Map) {
        return DashboardSummary.fromJson(Map<String, dynamic>.from(raw));
      }
      return DashboardSummary.empty();
    }, 'Fetch dashboard summary');
  }

  Future<Catalog?> getFeaturedDesign({String style = 'all'}) async {
    final response = await _apiClient.private.get(
      '/dashboard/design/featured',
      queryParameters: {'style': style},
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'] ?? response.data;
      final designJson = raw is Map ? (raw['design'] ?? raw) : null;
      if (designJson is Map) {
        return Catalog.fromJson(Map<String, dynamic>.from(designJson));
      }
      return null;
    }, 'Fetch featured design');
  }

  Future<List<Catalog>> getRecommendedDesigns() async {
    final response = await _apiClient.private.get(
      '/dashboard/design/recommend',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'] ?? response.data;
      final designsJson = raw is Map ? (raw['designs'] ?? raw) : raw;
      if (designsJson is List) {
        return designsJson
            .whereType<Map>()
            .map((e) => Catalog.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return <Catalog>[];
    }, 'Fetch recommended designs');
  }
}
