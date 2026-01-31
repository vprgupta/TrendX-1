import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class YoutubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  Future<List<Map<String, dynamic>>> getTrendingVideos([String regionCode = 'US']) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/videos?part=snippet&chart=mostPopular&maxResults=10&regionCode=$regionCode&key=${Secrets.youtubeApiKey}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        return items.map<Map<String, dynamic>>((item) {
          final snippet = item['snippet'] ?? {};
          return {
            'id': item['id'] ?? '',
            'title': snippet['title'] ?? 'No Title',
            'thumbnail': snippet['thumbnails']?['medium']?['url'] ?? '',
            'channelTitle': snippet['channelTitle'] ?? 'Unknown Channel',
            'publishedAt': snippet['publishedAt'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load trending videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching YouTube data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingShorts([String regionCode = 'US']) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/videos?part=snippet&chart=mostPopular&maxResults=20&regionCode=$regionCode&videoCategoryId=24&key=${Secrets.youtubeApiKey}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        return items.map<Map<String, dynamic>>((item) {
          final snippet = item['snippet'] ?? {};
          return {
            'id': item['id'] ?? '',
            'title': snippet['title'] ?? 'No Title',
            'thumbnail': snippet['thumbnails']?['medium']?['url'] ?? '',
            'channelTitle': snippet['channelTitle'] ?? 'Unknown Channel',
            'publishedAt': snippet['publishedAt'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load shorts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching YouTube shorts: $e');
    }
  }
}