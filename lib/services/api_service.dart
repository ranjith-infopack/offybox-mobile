import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static const String _baseUrl = 'https://api.offybox.com';

  static const String ENDPOINT_OUTLETS = '/v1/outlet';
  static const String ENDPOINT_LEDGER_GROUPS = '/v1/outlet/categories';
  static const String ENDPOINT_ORDERS = '/v1/orders';
  static const String ENDPOINT_INVOICES = '/v1/invoices';
  static const String ENDPOINT_LOOKUP = '//lookup';
  static const String ENDPOINT_PAYMENTS = '/v1/payments';
  static const String ENDPOINT_PRODUCTS = '/v1/products';
  static const String ENDPOINT_USERS = '/v1/users';

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
      print('ApiService GET: $uri');
      
      final response = await http.get(uri, headers: headers);
      print('ApiService Status Code: ${response.statusCode}');
      
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('ApiService: Failed to decode JSON: ${response.body}');
        return {
          'success': false,
          'message': 'Server error: Invalid response format (${response.statusCode})',
          'body': response.body,
        };
      }
      
      print('ApiService Data: $data');

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
          'message': data is Map ? (data['message'] ?? data['error'] ?? 'Request failed') : 'Request failed',
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
      
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('ApiService POST: Failed to decode JSON: ${response.body}');
        return {
          'success': false,
          'message': 'Server error: Invalid response format (${response.statusCode})',
          'body': response.body,
        };
      }

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
          'message': data is Map ? (data['message'] ?? data['error'] ?? 'Request failed') : 'Request failed',
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
