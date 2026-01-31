import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_item.dart';
import 'cache_service.dart';

class NewsService {
  // Use your computer's IP address for physical device, or 10.0.2.2 for Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; 
  static const String baseUrl = 'http://10.22.31.214:3000/api'; 

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
        final items = data.map((json) => NewsItem.fromJson(json)).toList();
        
        // 2. Cache the result on success
        await CacheService.cacheNews(category, items);
        
        return items;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      // 3. Fallback to Cache on ANY error (Exception, Timeout, SocketException)
      print('Network failed ($e), falling back to cache for $category');
      
      final cached = await CacheService.getCachedNews(category);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      
      // 4. If no cache, rethrow (to show error UI)
      // We might want to return dummy data here if you still want the app to look populated during development?
      // For "Production Grade" we usually show an error, but for this demo I'll fallback to dummy if cache is empty too 
      // allows you to test UI without backend running.
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
