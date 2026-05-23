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
    String? search,
    String? status,
  }) async {
    final response = await _apiClient.public.get(
      '/awards',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (architectId != null && architectId.trim().isNotEmpty) 'architect_id': architectId.trim(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },

      options: Options(validateStatus: (s) => s != null && s < 500),
    );

    return _apiClient.customResponse(response, () async {
      final rawList = response.data?['data'];
      if (rawList is! List) return <Award>[];

      return rawList.whereType<Map>().map((e) => Award.fromJson(Map<String, dynamic>.from(e))).toList();
    }, 'Fetch Awards');
  }

  Future<Award> getAwardById(String id) async {
    final response = await _apiClient.public.get(
      '/awards/$id',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'];

      if (raw is! Map) {
        throw Exception('Invalid award detail response');
      }
      return Award.fromJson(Map<String, dynamic>.from(raw['award'] ?? {}));
    }, 'Fetch Award Detail');
  }

  Future<Award> createAward(FormData payload) async {
    final response = await _apiClient.private.post(
      '/awards',
      data: payload,
      options: Options(validateStatus: (s) => s != null && s < 500),
    );

    return _apiClient.customResponse(
      response,
      () async {
        final raw = response.data?['data'];
        if (raw is! Map) {
          throw Exception('Invalid award create response');
        }
        return Award.fromJson(Map<String, dynamic>.from(raw));
      },
      'Create Award',
      isCreated: true,
    );
  }

  Future<Award> updateAward(String id, FormData payload) async {
    payload.fields.add(const MapEntry('_method', 'PUT'));

    final response = await _apiClient.private.post(
      '/awards/$id',
      data: payload,
      options: Options(validateStatus: (s) => s != null && s < 500),
    );

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'];
      if (raw is! Map) {
        throw Exception('Invalid award update response');
      }
      return Award.fromJson(Map<String, dynamic>.from(raw));
    }, 'Update Award');
  }

  Future<void> deleteAward(String id) async {
    final response = await _apiClient.private.delete(
      '/awards/$id',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );

    await _apiClient.customResponse(response, () async {}, 'Delete Award');
  }
}
