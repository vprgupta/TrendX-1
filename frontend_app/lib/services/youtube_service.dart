import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class YoutubeService {
  Future<List<Map<String, dynamic>>> getTrendingVideos([String regionCode = 'US']) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/integrations/youtube/trending?country=$regionCode&category=0'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['trends'] ?? [];
        
        return items.map<Map<String, dynamic>>((item) {
          return {
            'id': item['videoId'] ?? item['id'] ?? '',
            'title': item['title'] ?? 'No Title',
            'thumbnail': item['imageUrl'] ?? item['thumbnail'] ?? '',
            'channelTitle': item['author'] ?? item['channelTitle'] ?? 'Unknown Channel',
            'publishedAt': item['publishedAt'] ?? item['createdAt'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load trending videos from backend: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching YouTube data from backend: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingShorts([String regionCode = 'US']) async {
    try {
      // 24 corresponds to Entertainment/Shorts algorithm logic or similar category
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/integrations/youtube/trending?country=$regionCode&category=24'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['trends'] ?? [];
        
        return items.map<Map<String, dynamic>>((item) {
          return {
            'id': item['videoId'] ?? item['id'] ?? '',
            'title': item['title'] ?? 'No Title',
            'thumbnail': item['imageUrl'] ?? item['thumbnail'] ?? '',
            'channelTitle': item['author'] ?? item['channelTitle'] ?? 'Unknown Channel',
            'publishedAt': item['publishedAt'] ?? item['createdAt'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load trending shorts from backend: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching YouTube shorts from backend: $e');
    }
  }
}