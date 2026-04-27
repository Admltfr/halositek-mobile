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
  }) async {
    final response = await _apiClient.public.get(
      '/projects',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (style != null && style.trim().isNotEmpty) 'style': style.trim(),
      },
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    return _apiClient.customResponse(response, () async {
      final rawList = response.data?['data'];
      if (rawList is! List) return <Catalog>[];

      return rawList
          .whereType<Map>()
          .map((e) => Catalog.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }, 'Fetch Catalogs');
  }

  Future<void> likeCatalog(String catalogId) async {
    final response = await _apiClient.private.post(
      '/projects/$catalogId/like',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {}, 'Like Catalog');
  }

  Future<void> unlikeCatalog(String catalogId) async {
    final response = await _apiClient.private.delete(
      '/projects/$catalogId/like',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {}, 'Unlike Catalog');
  }
}
