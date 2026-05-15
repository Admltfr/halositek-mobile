import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static final _storage = FlutterSecureStorage();

  Future<void> setAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> clearAccessToken() async {
    await _storage.delete(key: 'access_token');
  }

  Future<void> clearRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }

  Future<void> setRole(String role) async {
    await _storage.write(key: 'role', value: role);
  }

  Future<String?> getRole() async {
    return _storage.read(key: 'role');
  }

  Future<void> clearRole() async {
    await _storage.delete(key: 'role');
  }
}
