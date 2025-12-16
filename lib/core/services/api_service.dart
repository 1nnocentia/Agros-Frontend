import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api/';

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {"Accept": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal kirim data: ${response.statusCode}");
    }
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal ambil data");
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {"Accept": "application/json"},
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {"Accept": "application/json"},
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return true; 
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal Request: ${response.statusCode}");
    }
  }
}