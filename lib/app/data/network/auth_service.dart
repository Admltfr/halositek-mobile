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

    if (response.statusCode == 201) {
      _tokenService.setAccessToken(response.data['data']['access_token']);
      _tokenService.setRefreshToken(response.data['data']['refresh_token']);
    } else if (response.statusCode == 422) {
      throw Exception('Validation error: ${response.data['message']}');
    } else if (response.statusCode == 500) {
      throw Exception('Server error: ${response.data['message']}');
    } else {
      throw Exception('Failed to register: ${response.statusCode}');
    }
  }

  Future<void> login({required String email, required String password}) async {
    final response = await _apiClient.public.post(
      '/login',
      data: {'email': email, 'password': password},
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    if (response.statusCode == 200) {
      _tokenService.setAccessToken(response.data['data']['access_token']);
      _tokenService.setRefreshToken(response.data['data']['refresh_token']);
    } else if (response.statusCode == 422) {
      throw Exception('Validation error: ${response.data['message']}');
    } else if (response.statusCode == 500) {
      throw Exception('Server error: ${response.data['message']}');
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<String?> refreshToken(String token) async {
    final response = await _apiClient.public.post(
      '/refresh-token',
      data: {'refresh_token': token},
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    if (response.statusCode == 200) {
      final newAccessToken = response.data['data']['access_token'];
      final newRefreshToken = response.data['data']['refresh_token'];

      await _tokenService.setAccessToken(newAccessToken);
      await _tokenService.setRefreshToken(newRefreshToken);

      return newAccessToken;
    } else if (response.statusCode == 422) {
      throw Exception('Validation error: ${response.data['message']}');
    } else if (response.statusCode == 500) {
      throw Exception('Server error: ${response.data['message']}');
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}
