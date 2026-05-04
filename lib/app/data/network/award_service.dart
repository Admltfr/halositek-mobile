import 'package:dio/dio.dart';
import 'package:halositek/app/data/models/award.dart';
import 'package:halositek/app/data/network/api_client.dart';

class AwardService {
  final ApiClient _apiClient;
  AwardService(this._apiClient);

  Future<List<Award>> getAwards({
    int page = 1,
    int perPage = 10,
    String? architectId,
  }) async {
    final response = await _apiClient.public.get(
      '/awards',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (architectId != null && architectId.trim().isNotEmpty)
          'architect_id': architectId.trim(),
      },

      options: Options(validateStatus: (s) => s != null && s < 500),
    );

    return _apiClient.customResponse(response, () async {
      final rawList = response.data?['data'];
      if (rawList is! List) return <Award>[];

      return rawList
          .whereType<Map>()
          .map((e) => Award.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }, 'Fetch Awards');
  }
}
