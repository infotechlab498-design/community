import 'dart:convert';

import '../network/api_client.dart';

class AuthService {
  AuthService({ApiClient? client}) : _api = client ?? ApiClient();

  static String get baseUrl => ApiClient.baseUrl;

  static const String tokenKey = ApiClient.tokenKey;

  final ApiClient _api;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final dynamic data;
    try {
      data = await _api.post(
        '/api/auth/admin-login',
        body: {'email': email.trim(), 'password': password},
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        throw const ApiException('Invalid email or password.', statusCode: 401);
      }
      rethrow;
    }

    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final token = map['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ApiException(
          'Login succeeded, but the API did not return a token.');
    }

    await _api.saveToken(token);
    return map;
  }

  Future<String?> getToken() => _api.readToken();

  /// True when a token is stored and has not passed its JWT `exp` time.
  Future<bool> hasValidSession() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    final expiry = _tokenExpiry(token);
    if (expiry == null || DateTime.now().isAfter(expiry)) {
      await logout();
      return false;
    }
    return true;
  }

  Future<void> logout() => _api.clearToken();

  static DateTime? _tokenExpiry(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final exp = (jsonDecode(payload) as Map)['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
    } catch (_) {
      return null;
    }
  }
}
