import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class SessionService {
  static String? _sessionId;
  static String? get sessionId => _sessionId;

  static Future<void> syncSession(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/sessions/sync'),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode({'platform': 'mobile'}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _sessionId = data['sessionId'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_id', _sessionId!);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('session_id');
  }

  static Future<void> switchToDashboard(String token) async {
    if (_sessionId == null) return;
    
    try {
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/sessions/switch'),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode({
          'sessionId': _sessionId,
          'newPlatform': 'web'
        }),
      );
    } catch (e) {
      // Handle error silently
    }
  }
}