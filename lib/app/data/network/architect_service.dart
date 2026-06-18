import 'package:dio/dio.dart';
import 'package:halositek/app/data/models/architect.dart';
import 'package:halositek/app/data/models/architect_earnings.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/network/token_service.dart';

class ArchitectService {
  final ApiClient _apiClient;
  final TokenService _tokenService = TokenService();

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
    final useAuthenticatedRequest = await _shouldUseAuthenticatedDetail();
    final client =
        useAuthenticatedRequest ? _apiClient.private : _apiClient.public;

    final response = await client.get(
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

  Future<ArchitectPerformance> getArchitectPerformance(String id) async {
    final response = await _apiClient.public.get(
      '/architects/$id/performance',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'];
      if (raw is! Map) {
        throw Exception('Invalid architect performance response');
      }
      return ArchitectPerformance.fromJson(Map<String, dynamic>.from(raw));
    }, 'Fetch Architect Performance');
  }

  Future<bool> _shouldUseAuthenticatedDetail() async {
    final token = await _tokenService.getAccessToken();
    final role = (await _tokenService.getRole() ?? '').trim().toLowerCase();

    return token != null && token.trim().isNotEmpty && role == 'user';
  }

  Future<void> saveArchitect(String id) async {
    final response = await _apiClient.private.post(
      '/architects/$id/save',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {}, 'Save Architect');
  }

  Future<void> unsaveArchitect(String id) async {
    final response = await _apiClient.private.delete(
      '/architects/$id/save',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {}, 'Unsave Architect');
  }

  Future<ArchitectEarnings> getArchitectEarnings() async {
    final response = await _apiClient.private.get(
      '/architects/earnings',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'];
      if (raw is! Map) {
        throw Exception('Invalid architect earnings response');
      }
      return ArchitectEarnings.fromJson(Map<String, dynamic>.from(raw));
    }, 'Fetch Architect Earnings');
  }

  Future<Architect> updateArchitect(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.private.put(
      '/architects/$id',
      data: payload,
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'];
      if (raw is! Map) {
        throw Exception('Invalid architect update response');
      }

      final architectJson = raw['architect'] is Map ? raw['architect'] : raw;
      return Architect.fromJson(Map<String, dynamic>.from(architectJson));
    }, 'Update Architect');
  }

  Future<Architect> updateArchitectProfile(
    FormData payload,
    Architect current,
  ) async {
    final response = await _apiClient.private.post(
      '/architects/profile',
      data: payload,
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200) {
      final raw = response.data?['data'];
      if (raw is! Map) {
        throw Exception('Invalid architect profile update response');
      }

      final data = Map<String, dynamic>.from(raw);
      return current.copyWith(
        name: (data['name'] ?? current.name).toString(),
        email: (data['email'] ?? current.email).toString(),
        headline: (data['headline'] ?? current.headline).toString(),
        bio: (data['bio'] ?? current.bio).toString(),
        profilePicture:
            (data['photo_profile_url'] ??
                    data['profile_picture'] ??
                    current.profilePicture)
                .toString(),
        consultationFee:
            _toInt(data['consultation_fee']) == 0 &&
                    data['consultation_fee'] == null
                ? current.consultationFee
                : _toInt(data['consultation_fee']),
        consultationDuration:
            _toInt(data['consultation_hours']) == 0 &&
                    data['consultation_hours'] == null
                ? current.consultationDuration
                : _toInt(data['consultation_hours']),
        yearOfExperience:
            data['year_of_experience'] == null
                ? current.yearOfExperience
                : _toInt(data['year_of_experience']),
      );
    }

    if (response.statusCode == 422) {
      throw ArchitectValidationException.fromResponse(response.data);
    }

    return _apiClient.customResponse(
      response,
      () async => current,
      'Update Architect Profile',
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ArchitectValidationException implements Exception {
  ArchitectValidationException(this.message, this.errors);

  final String message;
  final Map<String, String> errors;

  factory ArchitectValidationException.fromResponse(dynamic data) {
    final fallback =
        (data is Map ? data['message'] : null)?.toString() ??
        'Validation failed.';
    final result = <String, String>{};
    final rawErrors = data is Map ? data['errors'] : null;

    if (rawErrors is Map) {
      rawErrors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          result[key.toString()] = value.first.toString();
        } else if (value != null) {
          result[key.toString()] = value.toString();
        }
      });
    }

    return ArchitectValidationException(fallback, result);
  }

  @override
  String toString() => message;
}
