import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class SecureStorage {
  // ---------------- STORAGE ----------------
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'access_token';

  // ---------------- SESSION (MEMORY) ----------------
  static String? _role; // set after login

  // ---------------- TOKEN ----------------

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    _role = null;
  }

  // ---------------- ROLE ----------------

  static void setRole(String role) {
    _role = role;
  }

  static String? get role => _role;

  // ---------------- SESSION VALIDATION ----------------

  /// Returns true if token exists AND is not expired
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    return !Jwt.isExpired(token);
  }

  /// Checks whether current user has required role
  static bool hasRole(String requiredRole) {
    return _role == requiredRole;
  }

  /// Clears session completely
  static Future<void> logout() async {
    await deleteToken();
  }
}
