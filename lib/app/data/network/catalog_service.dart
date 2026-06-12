import 'package:dio/dio.dart';
import 'package:halositek/app/data/models/catalog.dart';
import 'package:halositek/app/data/network/api_client.dart';

class CatalogService {
  final ApiClient _apiClient;

  CatalogService(this._apiClient);

  Future<List<Catalog>> getCatalogs({
    int page = 1,
    int perPage = 10,
    String? search,
    String? style,
    String? architectId,
    String? status,
  }) async {
    final response = await _apiClient.public.get(
      '/projects',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (style != null && style.trim().isNotEmpty) 'style': style.trim(),
        if (architectId != null && architectId.trim().isNotEmpty) 'architect_id': architectId.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // queryParameters
    print('Query Parameters: ${response.requestOptions.queryParameters}');

    return _apiClient.customResponse(response, () async {
      final rawList = response.data?['data'];
      if (rawList is! List) return <Catalog>[];

      return rawList.whereType<Map>().map((e) => Catalog.fromJson(Map<String, dynamic>.from(e))).toList();
    }, 'Fetch Catalogs');
  }

  Future<Catalog> getCatalogById(String catalogId) async {
    final response = await _apiClient.private.get(
      '/projects/$catalogId',
      options: Options(validateStatus: (status) => status != null && status < 500),
    );

    return _apiClient.customResponse(response, () async {
      final rawData = response.data?['data'];

      if (rawData is Map && rawData['project'] is Map) {
        return Catalog.fromJson(Map<String, dynamic>.from(rawData['project'] as Map));
      }

      if (rawData is Map) {
        return Catalog.fromJson(Map<String, dynamic>.from(rawData));
      }

      throw Exception('Invalid project detail response format');
    }, 'Fetch Catalog Detail');
  }

  Future<void> likeCatalog(String catalogId) async {
    final response = await _apiClient.private.post(
      '/projects/$catalogId/like',
      options: Options(validateStatus: (status) => status != null && status < 500),
    );

    return _apiClient.customResponse(response, () async {}, 'Like Catalog');
  }

  Future<void> unlikeCatalog(String catalogId) async {
    final response = await _apiClient.private.delete(
      '/projects/$catalogId/like',
      options: Options(validateStatus: (status) => status != null && status < 500),
    );

    return _apiClient.customResponse(response, () async {}, 'Unlike Catalog');
  }

  Future<void> saveCatalog(String catalogId) async {
    final response = await _apiClient.private.post(
      '/projects/$catalogId/save',
      options: Options(validateStatus: (status) => status != null && status < 500),
    );

    return _apiClient.customResponse(response, () async {}, 'Save Catalog');
  }

  Future<void> unsaveCatalog(String catalogId) async {
    final response = await _apiClient.private.delete(
      '/projects/$catalogId/save',
      options: Options(validateStatus: (status) => status != null && status < 500),
    );

    return _apiClient.customResponse(response, () async {}, 'Unsave Catalog');
  }
}
