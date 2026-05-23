import 'package:dio/dio.dart';
import 'api_client.dart';
import 'token_service.dart';

class AuthService {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  AuthService(this._apiClient, this._tokenService);

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    final response = await _apiClient.public.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
      },
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    return _apiClient.customResponse(
      response,
      () async {
        _tokenService.setAccessToken(response.data['data']['access_token']);
        _tokenService.setRefreshToken(response.data['data']['refresh_token']);
      },
      'Register',
      isCreated: true,
    );
  }

  Future<void> login({required String email, required String password}) async {
    final response = await _apiClient.public.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    return _apiClient.customResponse(response, () async {
      final data = response.data['data'];
      _tokenService.setAccessToken(data['access_token']);
      _tokenService.setRefreshToken(data['refresh_token']);
      _tokenService.setRole(data['role']);
      final userId = (data['id'] ?? '').toString();
      if (userId.trim().isNotEmpty) {
        await _tokenService.setUserId(userId);
      }
    }, 'Login');
  }

  Future<String?> refreshToken(String token) async {
    final response = await _apiClient.public.post(
      '/auth/refresh-token',
      data: {'refresh_token': token},
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    return _apiClient.customResponse(response, () async {
      final newAccessToken = response.data['data']['access_token'];
      final newRefreshToken = response.data['data']['refresh_token'];

      await _tokenService.setAccessToken(newAccessToken);
      await _tokenService.setRefreshToken(newRefreshToken);

      return newAccessToken;
    }, 'Refresh token');
  }

  Future<void> logout() async {
    final response = await _apiClient.private.post(
      '/logout',
      data: {'refresh_token': await _tokenService.getRefreshToken()},
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    return _apiClient.customResponse(response, () async {
      await _tokenService.clearAccessToken();
      await _tokenService.clearRefreshToken();
      await _tokenService.clearRole();
      await _tokenService.clearUserId();
    }, 'Logout');
  }

  Future<void> validateSession() async {
    final response = await _apiClient.private.get(
      '/me',
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );
    return _apiClient.customResponse(response, () async {}, 'Validate session');
  }
}
