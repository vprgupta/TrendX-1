import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AIExplainerService {
  Future<String> explainTrend(String title, String content, String platform, [String language = 'English']) async {
    print('🔍 Starting AI Explanation Request (Proxy via backend)');
    print('📝 Title: $title');
    print('🌐 Platform: $platform');
    print('🗣️ Language: $language');
    
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.aiExplain),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'title': title,
          'content': content,
          'platform': platform,
          'language': language
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['explanation'] != null) {
          return data['explanation'];
        } else {
          print('Backend API Missing Explanation: ${response.body}');
          throw Exception('Invalid response format from backend');
        }
      } else {
        print('Backend API Error Status: ${response.statusCode}');
        print('Backend API Error Body: ${response.body}');
        throw Exception('Backend API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ AI Explanation Failed via backend!');
      print('🚨 Error Message: $e');
      print('🔄 Using fallback explanation');
      return _getFallbackExplanation(title, content, platform, language);
    }
  }

  String _getFallbackExplanation(String title, String content, String platform, String language) {
    return 'This trending $platform post "$title" has gained significant attention due to its relevance and engagement with users. The content resonates with current interests, spreading through platform algorithms, user shares, and viral mechanisms. It reflects timely topics that the community finds valuable and entertaining.';
  }
}