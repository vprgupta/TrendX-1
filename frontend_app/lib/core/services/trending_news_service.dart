import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trending_story.dart';

class TrendingNewsService {
  static const String _baseUrl = 'https://trendx-1.onrender.com/api';

  // In-memory cache (trending data changes often — don't persist to SharedPrefs)
  static List<TrendingStory>? _memoryCache;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 10);

  Future<List<TrendingStory>> getTrending({int limit = 25}) async {
    // Return memory cache if fresh
    if (_memoryCache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _memoryCache!;
    }

    try {
      final uri = Uri.parse('$_baseUrl/news/trending').replace(
        queryParameters: {'limit': limit.toString()},
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final stories = data.map((j) => TrendingStory.fromJson(j as Map<String, dynamic>)).toList();

        _memoryCache = stories;
        _cacheTime = DateTime.now();
        return stories;
      }
    } catch (e) {
      // Return stale cache if available rather than crashing
      if (_memoryCache != null) return _memoryCache!;
    }

    return [];
  }

  static void clearCache() {
    _memoryCache = null;
    _cacheTime = null;
  }
}
