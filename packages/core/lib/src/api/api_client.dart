import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

/// Thin HTTP wrapper around Madadgaar's demo backend (`backend/local-server`).
/// Every one of the three apps points this at the same running instance, so
/// live state is genuinely shared across Customer/Helper/Admin during a demo.
///
/// This is intentionally the *only* place that knows about HTTP — swapping
/// to a real Supabase-backed API later means replacing this one class, not
/// the screens that use it (see `backend/supabase` for that target shape).
class ApiClient {
  final String baseUrl;
  final http.Client _http;
  String? _token;

  ApiClient({required this.baseUrl, http.Client? httpClient}) : _http = httpClient ?? http.Client();

  void setToken(String? token) => _token = token;
  String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final clean = path.startsWith('/') ? path : '/$path';
    final q = query?.map((k, v) => MapEntry(k, v?.toString())) ?? {};
    q.removeWhere((_, v) => v == null);
    return Uri.parse('$baseUrl$clean').replace(queryParameters: q.isEmpty ? null : q);
  }

  Future<dynamic> _decode(http.Response res) async {
    dynamic body;
    try {
      body = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      body = null;
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final message = (body is Map && body['error'] is String) ? body['error'] as String : 'Something went wrong (${res.statusCode}).';
    throw ApiException(message, statusCode: res.statusCode);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _http.get(_uri(path, query), headers: _headers).timeout(const Duration(seconds: 12));
      return _decode(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw NetworkUnavailableException();
    }
  }

  Future<dynamic> post(String path, {Object? body}) async {
    try {
      final res = await _http.post(_uri(path), headers: _headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 12));
      return _decode(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw NetworkUnavailableException();
    }
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    try {
      final res = await _http.patch(_uri(path), headers: _headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 12));
      return _decode(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw NetworkUnavailableException();
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final res = await _http.delete(_uri(path), headers: _headers).timeout(const Duration(seconds: 12));
      return _decode(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw NetworkUnavailableException();
    }
  }
}
