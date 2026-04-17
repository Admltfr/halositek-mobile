import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_interceptor.dart';
import 'auth_service.dart';
import 'token_service.dart';
import 'package:flutter/material.dart';

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

  void customResponse(
    Response<dynamic> response,
    Function onSuccess,
    String message, {
    bool isCreated = false,
  }) {
    if (isCreated ? response.statusCode == 201 : response.statusCode == 200) {
      onSuccess();
    } else if (response.statusCode == 422) {
      throw Exception('Validation error: ${response.data['message']}');
    } else if (response.statusCode == 500) {
      throw Exception('Server error: ${response.data['message']}');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: ${response.data['message']}');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden: ${response.data['message']}');
    } else if (response.statusCode == 404) {
      throw Exception('Not found: ${response.data['message']}');
    } else {
      debugPrint(
        'Login failed with status code: ${response.statusCode}, response: ${response.data}',
      );
      throw Exception('Failed to $message');
    }
  }
}
