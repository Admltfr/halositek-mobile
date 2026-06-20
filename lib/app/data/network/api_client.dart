import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_interceptor.dart';
import 'auth_service.dart';
import 'token_service.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

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
    final responseData = response.data;
    if (responseData is Map) {
      debugPrint('\x1B[31m ${responseData['message']}\x1B[0m');
    }

    if (isCreated ? response.statusCode == 201 : response.statusCode == 200) {
      return await onSuccess();
    } else if (response.statusCode == 422) {
      final errors = responseData is Map ? responseData['errors'] : null;

      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          throw ApiException(firstError.first.toString());
        }
      }

      throw ApiException('Validation error');
    } else if (response.statusCode == 500) {
      throw ApiException('Server error: ${responseData is Map ? responseData['message'] : 'Internal Server Error'}');
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized: ${responseData is Map ? responseData['message'] : 'Unauthorized'}');
    } else if (response.statusCode == 403) {
      throw ApiException('Forbidden: ${responseData is Map ? responseData['message'] : 'Forbidden'}');
    } else if (response.statusCode == 404) {
      throw ApiException('Not found: ${responseData is Map ? responseData['message'] : 'Not Found'}');
    } else if (response.statusCode == 409) {
      throw ApiException('Conflict: ${responseData is Map ? responseData['message'] : 'Conflict'}');
    } else if (response.statusCode == 503) {
      throw ApiException(responseData is Map ? (responseData['message'] ?? 'Service Unavailable') : 'Service Unavailable');
    } else {
      final String errMsg = responseData is Map ? (responseData['message'] ?? 'Failed to $message') : 'Failed to $message';
      throw ApiException(errMsg);
    }
  }
}
