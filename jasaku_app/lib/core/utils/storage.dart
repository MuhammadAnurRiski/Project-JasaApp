import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _tokenKey = 'jwt_token';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: false),
  );

  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      debugPrint('[StorageService] Token saved OK');
    } catch (e) {
      debugPrint('[StorageService] saveToken FAILED: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      debugPrint('[StorageService] getToken: ${token != null ? "found (${token.length} chars)" : "null"}');
      return token;
    } catch (e) {
      debugPrint('[StorageService] getToken FAILED: $e');
      return null;
    }
  }

  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      debugPrint('[StorageService] Token deleted');
    } catch (e) {
      debugPrint('[StorageService] deleteToken FAILED: $e');
    }
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null;
  }
}
