import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static const String _baseUrl = 'https://api.offybox.com/v1';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
      final headers = await _getHeaders();
      
      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 401) {
        // Token expired - clear storage
        await StorageService.clearAll();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'unauthorized': true,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 401) {
        await StorageService.clearAll();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'unauthorized': true,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
