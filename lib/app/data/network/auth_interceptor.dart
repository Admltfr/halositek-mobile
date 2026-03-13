import 'package:dio/dio.dart';
import 'package:halositek/app/data/network/auth_service.dart';
import 'package:halositek/app/data/network/token_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenService _tokenService;
  final AuthService _authService;

  AuthInterceptor(this._dio, this._tokenService, this._authService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenService.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _tokenService.getRefreshToken();

      if (refreshToken == null) {
        return handler.next(err);
      }

      final newAccessToken = await _authService.refreshToken(refreshToken);

      if (newAccessToken != null) {
        final requestOptions = err.requestOptions;

        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final response = await _dio.fetch(requestOptions);

        return handler.resolve(response);
      }
    }

    return handler.next(err);
  }
}
