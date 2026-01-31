import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class AIExplainerService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> explainTrend(String title, String content, String platform, [String language = 'English']) async {
    print('🔍 Starting AI Explanation Request');
    print('📝 Title: $title');
    print('📄 Content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
    print('🌐 Platform: $platform');
    print('🗣️ Language: $language');
    print('🔑 API Key exists: ${Secrets.geminiApiKey.isNotEmpty}');
    
    try {
      print('⏳ Calling Gemini API...');
      final result = await _explainWithGemini(title, content, platform, language);
      print('✅ Gemini API Success!');
      print('📤 Response Preview: ${result.substring(0, result.length > 100 ? 100 : result.length)}...');
      return result;
    } catch (e) {
      print('❌ Gemini API Failed!');
      print('🚨 Error Type: ${e.runtimeType}');
      print('🚨 Error Message: $e');
      print('🔄 Using fallback explanation');
      return _getFallbackExplanation(title, content, platform, language);
    }
  }

  Future<String> _explainWithGemini(String title, String content, String platform, String language) async {
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${Secrets.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [{
            'parts': [{
              'text': 'Provide a concise explanation (60-70 words) in $language language about why this $platform post is trending. Focus on the key reasons, context, and significance. Make it clear and engaging.\n\nTitle: "$title"\nContent: "$content"'
            }]
          }],
          'generationConfig': {
            'maxOutputTokens': 150,
            'temperature': 0.7
          }
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'].trim();
        } else {
          print('Gemini API Empty Candidates: ${response.body}');
          throw Exception('No response from Gemini');
        }
      } else {
        print('Gemini API Error Status: ${response.statusCode}');
        print('Gemini API Error Body: ${response.body}');
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Gemini API Exception: $e');
      throw Exception('Network error or API unavailable');
    }
  }

  Future<String> _explainWithOpenAI(String title, String content, String platform, String language) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer ${Secrets.openAIApiKey}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful assistant that explains trending social media content in simple terms. Explain why this content is trending, its context, and significance. Respond in $language language.'
          },
          {
            'role': 'user',
            'content': 'Analyze this trending $platform post using 5W+1H principle. Provide detailed explanations (2-3 sentences each). Format each point on new line:\n\nWHO: [who is involved - be specific about creators, influencers, or communities]\nWHAT: [what happened - describe the content and its significance]\nWHEN: [when it occurred - timing and context]\nWHERE: [where it\'s happening - platform, geographic reach]\nWHY: [why it\'s trending - detailed reasons for popularity]\nHOW: [how it\'s spreading - mechanisms of viral growth]\n\nTitle: "$title" Content: "$content"'
          }
        ],
        'max_tokens': 800,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('OpenAI API Error: ${response.statusCode}');
    }
  }

  String _getFallbackExplanation(String title, String content, String platform, String language) {
    return 'This trending $platform post "$title" has gained significant attention due to its relevance and engagement with users. The content resonates with current interests, spreading through platform algorithms, user shares, and viral mechanisms. It reflects timely topics that the community finds valuable and entertaining.';
  }

  String _detectLanguage() {
    // Simple language detection based on system locale
    // In a real app, you'd use proper language detection
    return 'English';
  }
}