import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_interceptor.dart';
import 'auth_service.dart';
import 'token_service.dart';

class ApiClient {
  static final String? baseUrl = dotenv.env['BASEURL'];
  static final String url = '$baseUrl/api/v1';

  final Dio public = Dio(BaseOptions(baseUrl: url));
  final Dio private = Dio(BaseOptions(baseUrl: url));

  ApiClient() {
    final tokenService = TokenService();
    final authService = AuthService(this, tokenService);
    final authInterceptor = AuthInterceptor(private, tokenService, authService);

    private.interceptors.add(authInterceptor);
  }

  Future<T> customResponse<T>(
    Response<dynamic> response,
    Future<T> Function() onSuccess,
    String message, {
    bool isCreated = false,
  }) async {
    debugPrint('\x1B[31m ${response.data['message']}\x1B[0m');
    if (isCreated ? response.statusCode == 201 : response.statusCode == 200) {
      return await onSuccess();
    } else if (response.statusCode == 422) {
      final errors = response.data['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first.toString());
        }
      }

      throw Exception('Validation error');
    } else if (response.statusCode == 500) {
      throw Exception('Server error: ${response.data['message']}');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: ${response.data['message']}');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden: ${response.data['message']}');
    } else if (response.statusCode == 404) {
      throw Exception('Not found: ${response.data['message']}');
    } else if (response.statusCode == 409) {
      throw Exception('Conflict: ${response.data['message']}');
    } else {
      throw Exception('Failed to $message');
    }
  }
}
