import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> getPreferences(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.users}/preferences'),
      headers: ApiConfig.getAuthHeaders(token),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load preferences');
  }

  static Future<void> updatePreferences(String token, Map<String, dynamic> preferences) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.users}/preferences'),
      headers: ApiConfig.getAuthHeaders(token),
      body: json.encode(preferences),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update preferences');
    }
  }
}