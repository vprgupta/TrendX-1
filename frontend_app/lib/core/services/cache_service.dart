import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_item.dart';

class CacheService {
  static const String _trendsPrefix = 'trends_';
  static const String _newsPrefix = 'news_';
  static const Duration _cacheExpiry = Duration(minutes: 60); // Increased to 60 mins for news

  // --- Trends APIs ---
  static Future<void> cacheTrends(String platform, String countryCode, List<Map<String, dynamic>> trends) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_trendsPrefix${platform}_$countryCode';
    final cacheData = {
      'data': trends,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(key, jsonEncode(cacheData));
  }

  static Future<List<Map<String, dynamic>>?> getCachedTrends(String platform, String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_trendsPrefix${platform}_$countryCode';
    final cached = prefs.getString(key);
    
    if (cached == null) return null;
    
    final cacheData = jsonDecode(cached);
    final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
    
    if (DateTime.now().difference(timestamp) > _cacheExpiry) {
      // Don't auto delete for now, maybe stale data is better than no data?
      // But adhering to expiry for API freshness
      await prefs.remove(key);
      return null;
    }
    
    return List<Map<String, dynamic>>.from(cacheData['data']);
  }

  // --- News APIs ---
  static Future<void> cacheNews(String category, List<NewsItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_newsPrefix${category.toLowerCase()}';
    final cacheData = {
      'data': items.map((item) => item.toJson()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(key, jsonEncode(cacheData));
  }

  static Future<List<NewsItem>?> getCachedNews(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_newsPrefix${category.toLowerCase()}';
    final cached = prefs.getString(key);
    
    if (cached == null) return null;
    
    try {
      final cacheData = jsonDecode(cached);
      // We can check expiry here if we want, but usually for news, showing old news is better than error
      // Let's implement a soft expiry (if older than 24 hours, maybe clear)
      // but for now, just return what we have if network fails
      
      final List<dynamic> jsonList = cacheData['data'];
      return jsonList.map((json) => NewsItem.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_trendsPrefix) || key.startsWith(_newsPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}