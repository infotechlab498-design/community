import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Raised for any non-success API response or network failure.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}

/// Raised when an admin request returns 401; the stored token is already cleared.
class SessionExpiredException extends ApiException {
  const SessionExpiredException()
      : super('Your session has expired. Please sign in again.',
            statusCode: 401);
}

class ApiClient {
  ApiClient({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const String tokenKey = 'auth_token';
  static const Duration _timeout = Duration(seconds: 20);

  /// Central host from [ApiConfig].
  /// Override any build with `--dart-define=API_BASE_URL=https://host`.
  static String get baseUrl => ApiConfig.baseUrl;

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: tokenKey);

  Future<dynamic> get(String path, {bool auth = false}) =>
      _send('GET', path, auth: auth);

  Future<dynamic> post(String path, {Object? body, bool auth = false}) =>
      _send('POST', path, body: body, auth: auth);

  Future<dynamic> put(String path, {Object? body, bool auth = false}) =>
      _send('PUT', path, body: body, auth: auth);

  Future<dynamic> delete(String path, {bool auth = false}) =>
      _send('DELETE', path, auth: auth);

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    required bool auth,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';

    if (auth) {
      final token = await readToken();
      if (token == null || token.isEmpty) {
        throw const SessionExpiredException();
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      final streamed = await _client.send(request).timeout(_timeout);
      response = await http.Response.fromStream(streamed).timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('The server took too long to respond.');
    } on http.ClientException {
      // Covers mobile socket failures and browser/web network errors.
      throw const ApiException(
          'Unable to reach the server. Check your connection.');
    } catch (error) {
      if (error is ApiException) rethrow;
      throw const ApiException(
          'Unable to reach the server. Check your connection.');
    }

    final decoded = _decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    if (response.statusCode == 401 && auth) {
      await clearToken();
      throw const SessionExpiredException();
    }

    throw ApiException(
      _errorMessage(response.statusCode, decoded),
      statusCode: response.statusCode,
    );
  }

  static dynamic _decode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  static String _errorMessage(int statusCode, dynamic decoded) {
    if (decoded is Map) {
      final errors = decoded['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      final message = decoded['message'] ?? decoded['title'];
      if (message != null) return message.toString();
    }
    return switch (statusCode) {
      403 => 'You are not allowed to perform this action.',
      404 => 'The requested data was not found.',
      _ => 'Request failed (HTTP $statusCode).',
    };
  }

  void dispose() => _client.close();
}

/// Converts API "HH:mm" to "hh:mm AM" for display.
String formatApiTime(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return hhmm;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return hhmm;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '${displayHour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')} $period';
}

/// Minutes since midnight for an API "HH:mm" value.
int apiTimeToMinutes(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return 0;
  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
}
