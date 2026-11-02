import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/yeild_record.dart';

class ApiClient {
  String? _accessToken;

  bool get isAuthenticated => _accessToken != null;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    _ensureSuccess(response);
    return login(email: email, password: password);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    _ensureSuccess(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = body['access_token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Backend returned an invalid access token');
    }
    setAccessToken(token);
    return token;
  }

  Future<List<YieldRecord>> getYieldRecords() async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/yields'),
      headers: _headers,
    );
    _ensureSuccess(response);
    final body = jsonDecode(response.body);
    if (body is! List) {
      throw const FormatException('Backend returned invalid yield records');
    }
    return body
        .map((item) => YieldRecord.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<YieldRecord> createYieldRecord(YieldRecord record) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/yields'),
      headers: _headers,
      body: jsonEncode({
        'title': record.title,
        'kilograms': record.kilograms,
        'acres': record.acres,
        'recorded_date': record.date.toIso8601String().split('T').first,
      }),
    );
    _ensureSuccess(response);
    return YieldRecord.fromJson(Map<String, dynamic>.from(jsonDecode(response.body)));
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Backend request failed (${response.statusCode}): ${response.body}');
    }
  }
}
