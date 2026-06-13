import 'package:dio/dio.dart';
import 'package:halositek/app/data/models/user.dart';
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

  Future<int> requestPasswordOtp({required String email}) async {
    final response = await _apiClient.public.post(
      '/auth/mobile/password/request-otp',
      data: {'email': email},
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    return _apiClient.customResponse(response, () async {
      final data = response.data['data'];
      final expiresInMinutes =
          data is Map ? int.tryParse('${data['expires_in_minutes']}') : null;
      return expiresInMinutes ?? 10;
    }, 'Request password OTP');
  }

  Future<void> verifyPasswordOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _apiClient.public.post(
      '/auth/mobile/password/verify-otp',
      data: {'email': email, 'otp': otp},
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    return _apiClient.customResponse(
      response,
      () async {},
      'Verify password OTP',
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.public.post(
      '/auth/mobile/password/reset',
      data: {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    return _apiClient.customResponse(response, () async {}, 'Reset password');
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

  Future<UserProfile> getMe() async {
    final response = await _apiClient.private.get(
      '/me',
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    return _apiClient.customResponse(response, () async {
      final data = response.data['data'];
      final raw = data is Map ? data : response.data;
      return UserProfile.fromJson(Map<String, dynamic>.from(raw));
    }, 'Get profile');
  }

  Future<UserProfile> updateMe(FormData payload, UserProfile current) async {
    final response = await _apiClient.private.post(
      '/me',
      data: payload,
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      final raw =
          data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      final userJson =
          raw['user'] is Map ? Map<String, dynamic>.from(raw['user']) : raw;

      return current.copyWith(
        id: (userJson['id'] ?? current.id).toString(),
        name: (userJson['name'] ?? current.name).toString(),
        email: (userJson['email'] ?? current.email).toString(),
        role: (userJson['role'] ?? current.role).toString(),
        accountStatus:
            (userJson['account_status'] ?? current.accountStatus).toString(),
        photoProfileUrl:
            (userJson['photo_profile_url'] ??
                    userJson['photo_profile'] ??
                    current.photoProfileUrl)
                .toString(),
      );
    }

    if (response.statusCode == 422) {
      throw UserValidationException.fromResponse(response.data);
    }

    return _apiClient.customResponse(
      response,
      () async => current,
      'Update profile',
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _apiClient.private.post(
      '/auth/change-password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    if (response.statusCode == 422) {
      throw UserValidationException.fromResponse(response.data);
    }

    return _apiClient.customResponse(response, () async {}, 'Change password');
  }
}

class UserValidationException implements Exception {
  UserValidationException(this.message, this.errors);

  final String message;
  final Map<String, String> errors;

  factory UserValidationException.fromResponse(dynamic data) {
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

    return UserValidationException(fallback, result);
  }

  @override
  String toString() => message;
}
