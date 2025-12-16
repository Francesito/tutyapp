import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class ApiClient {
  ApiClient({String? token}) : _token = token;

  final String? _token;

  String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$apiBaseUrl$path');
    final res = await http.post(uri, headers: _headers, body: jsonEncode(body));
    _throwOnError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse('$apiBaseUrl$path');
    final res = await http.get(uri, headers: _headers);
    _throwOnError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  void _throwOnError(http.Response res) {
    if (res.statusCode >= 400) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
