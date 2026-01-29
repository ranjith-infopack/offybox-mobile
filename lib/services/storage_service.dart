import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _subdomainKey = 'subdomain';
  static const String _tenantCodeKey = 'tenant_code';
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _tenantDataKey = 'tenant_data';

  // Subdomain
  static Future<String?> getSubdomain() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_subdomainKey);
  }

  static Future<void> setSubdomain(String subdomain) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_subdomainKey, subdomain);
  }

  // Tenant Code (e.g., ORG-DEMO)
  static Future<String?> getTenantCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tenantCodeKey);
  }

  static Future<void> setTenantCode(String tenantCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tenantCodeKey, tenantCode);
  }

  // Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // User Data
  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  static Future<void> setUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData);
  }

  // Tenant Data
  static Future<String?> getTenantData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tenantDataKey);
  }

  static Future<void> setTenantData(String tenantData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tenantDataKey, tenantData);
  }

  // Clear session data only (keeps subdomain for next login)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_tenantDataKey);
  }

  // Clear all data including subdomain
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
