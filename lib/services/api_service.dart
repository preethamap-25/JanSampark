import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // change for prod

  /// Common method to get headers (with JWT if available)
  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await AuthService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Generic GET request
  static Future<http.Response> get(String endpoint, {bool auth = true}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders(withAuth: auth);
    return http.get(url, headers: headers);
  }

  /// Generic POST request
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body,
      {bool auth = true}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders(withAuth: auth);
    return http.post(url, headers: headers, body: jsonEncode(body));
  }

  /// Generic PUT request
  static Future<http.Response> put(String endpoint, Map<String, dynamic> body,
      {bool auth = true}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders(withAuth: auth);
    return http.put(url, headers: headers, body: jsonEncode(body));
  }

  /// Generic DELETE request
  static Future<http.Response> delete(String endpoint, {bool auth = true}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders(withAuth: auth);
    return http.delete(url, headers: headers);
  }

  /// Example: fetch user profile using token
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final response = await get('users/me');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch user profile: ${response.statusCode}');
      return null;
    }
  }

  /// Example: submit grievance
  static Future<bool> submitGrievance(Map<String, dynamic> grievanceData) async {
    final response = await post('grievances', grievanceData);
    return response.statusCode == 201;
  }
}
