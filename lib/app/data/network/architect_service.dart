import 'package:dio/dio.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/network/api_client.dart';

class ArchitectService {
  final ApiClient _apiClient;

  ArchitectService(this._apiClient);

  Future<List<Architect>> getArchitects({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    final response = await _apiClient.public.get(
      '/architects',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    return _apiClient.customResponse(response, () async {
      final rawList = response.data?['data'];
      if (rawList is! List) return <Architect>[];

      return rawList
          .whereType<Map>()
          .map((e) => Architect.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }, 'Fetch Architects');
  }

  Future<Architect> getArchitectById(String id) async {
    final response = await _apiClient.public.get(
      '/architects/$id',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'];
      if (raw is! Map) {
        throw Exception('Invalid architect detail response');
      }
      return Architect.fromJson(Map<String, dynamic>.from(raw));
    }, 'Fetch Architect Detail');
  }
}
