import 'package:dio/dio.dart';
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
}
