import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class AuthService {
  static const String _baseUrl = 'https://api.offybox.com/v1';

  /// Convert subdomain to tenant_code format
  /// e.g., "demo" -> "ORG-DEMO"
  static String _subdomainToTenantCode(String subdomain) {
    return 'ORG-${subdomain.toUpperCase()}';
  }

  static Future<Map<String, dynamic>> login({
    required String subdomain,
    required String email,
    required String password,
  }) async {
    final url = '$_baseUrl/auth/login';
    final tenantCode = _subdomainToTenantCode(subdomain);
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tenant_code': tenantCode,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save subdomain (as tenant_code) and token
        await StorageService.setSubdomain(subdomain);
        await StorageService.setTenantCode(tenantCode);
        if (data['token'] != null) {
          await StorageService.setToken(data['token']);
        }
        // Store user data
        if (data['user'] != null) {
          await StorageService.setUserData(jsonEncode(data['user']));
        }
        // Store tenant data
        if (data['tenant'] != null) {
          await StorageService.setTenantData(jsonEncode(data['tenant']));
        }
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<void> logout() async {
    await StorageService.clearSession();
  }
}
