import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';
import '../models/news_item.dart';
import 'cache_service.dart';

class NewsService {
  // Use your computer's IP address for physical device, or 10.0.2.2 for Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; 
  static const String baseUrl = 'https://trendx-1.onrender.com/api'; 

  Future<List<NewsItem>> getNews(String category, {String country = 'US'}) async {
    try {
      // 1. Try to fetch from Network
      final uri = Uri.parse('$baseUrl/news').replace(queryParameters: {
        'category': category.toLowerCase(),
        'country': country,
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final rawItems = data.map((json) => NewsItem.fromJson(json)).toList();

        // Deduplicate by title
        final seen = <String>{};
        final items = rawItems.where((item) => seen.add(item.title)).toList();
        
        // 2. Cache the result on success (key = category + country)
        await CacheService.cacheNews(category, country, items);
        
        return items;
      } else {
        Logger.error('Server returned ${response.statusCode} for $category', tag: 'NewsService');
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      // 3. Fallback to Cache on ANY error (Exception, Timeout, SocketException)
      Logger.error('Network failed, falling back to cache for $category', error: e, stackTrace: stackTrace, tag: 'NewsService');
      
      final cached = await CacheService.getCachedNews(category, country);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      
      // 4. If no cache either, show offline placeholder
      return _generateDummyNews(category, country); 
    }
  }

  Future<List<NewsItem>> getTopNews({String country = 'US'}) async {
    return getNews('top', country: country);
  }

  // Fallback for development/demo (if backend is not running)
  List<NewsItem> _generateDummyNews(String category, String country) {
     print('Generating dummy data for $category');
    final List<NewsItem> items = [];
    final int count = category.toLowerCase().contains('world') ? 50 : 20;

    for (int i = 0; i < count; i++) {
      items.add(NewsItem(
        title: 'Offline/Demo: ${category.toUpperCase()} News Title #$i',
        link: 'https://example.com',
        pubDate: DateTime.now().subtract(Duration(hours: i * 2)).toIso8601String(),
        content: 'This is offline content generated because the backend could not be reached.',
        contentSnippet: 'Backend unreachable. Showing demo content...',
        source: 'Demo Source',
        imageUrl: 'https://picsum.photos/seed/${category}_$i/800/600',
        author: 'System',
        authorAvatarUrl: null,
        likes: 0,
        comments: 0,
        shares: 0,
        rank: i + 1,
      ));
    }
    return items;
  }
}
