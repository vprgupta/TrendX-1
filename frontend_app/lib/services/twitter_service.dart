import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class TwitterService {
  static const String _baseUrl = 'https://api.twitter.com/2';

  Future<List<Map<String, dynamic>>> getTrendingTopics() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trends/by/woeid/1?max_results=10'),
        headers: {
          'Authorization': 'Bearer ${Secrets.twitterBearerToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> trends = data['data'] ?? [];
        
        return trends.map<Map<String, dynamic>>((trend) {
          return {
            'name': trend['name'] ?? 'No Name',
            'tweet_volume': trend['tweet_volume'] ?? 0,
            'url': trend['url'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load trends: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Twitter data: $e');
    }
  }
}