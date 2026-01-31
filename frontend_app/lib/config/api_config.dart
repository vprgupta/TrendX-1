import 'environment.dart';

class ApiConfig {
  // Dynamic URLs based on environment
  static String get serverUrl => EnvironmentConfig.apiBaseUrl;
  static String get baseUrl => '$serverUrl/api';
  static String get healthUrl => '$serverUrl/api/health';
  
  // API Endpoints
  static String get authRegister => '$baseUrl/auth/register';
  static String get authLogin => '$baseUrl/auth/login';
  static String get trends => '$baseUrl/trends';
  static String get users => '$baseUrl/users';
  
  // Request timeout
  static const Duration timeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}