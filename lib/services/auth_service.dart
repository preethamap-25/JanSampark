import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // platform-aware secure storage; on web this falls back to in-memory if not available
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';

  // In-memory cache so we don't read storage repeatedly
  static String? _cachedToken;

  /// Save token to secure storage and memory
  static Future<void> saveToken(String token) async {
    _cachedToken = token;
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {
      // On some platforms (web) secure storage may not be available; keep in memory
      debugPrint('Secure storage write failed; token cached in memory only.');
    }
  }

  /// Keep token in memory only (session until app close)
  static void setSessionToken(String token) {
    _cachedToken = token;
  }

  /// Read token (checks memory first, then secure storage)
  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    try {
      final t = await _storage.read(key: _tokenKey);
      _cachedToken = t;
      return t;
    } catch (_) {
      debugPrint('Secure storage read failed; returning in-memory token (if any).');
      return _cachedToken;
    }
  }

  /// Clear stored token (logout)
  static Future<void> clearToken() async {
    _cachedToken = null;
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {
      debugPrint('Secure storage delete failed; cleared in-memory token.');
    }
  }
}
