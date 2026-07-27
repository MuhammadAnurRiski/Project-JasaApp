import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _tokenKey = 'jwt_token';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: false),
  );

  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {}
  }

  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token;
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {}
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  static Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }
}
