import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_item.dart';

class CacheService {
  static const String _trendsPrefix = 'trends_';
  static const String _newsPrefix = 'news_';
  // 15 minutes: short enough that country-switching always gets fresh data
  static const Duration _cacheExpiry = Duration(minutes: 15);

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
  // Key includes BOTH category and country to avoid different countries overwriting each other's cache
  static String _newsKey(String category, String country) =>
      '$_newsPrefix${category.toLowerCase()}_${country.toLowerCase()}';

  static Future<void> cacheNews(String category, String country, List<NewsItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _newsKey(category, country);
    // Deduplicate by title before saving
    final seen = <String>{};
    final deduped = items.where((item) => seen.add(item.title)).toList();
    final cacheData = {
      'data': deduped.map((item) => item.toJson()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(key, jsonEncode(cacheData));
  }

  static Future<List<NewsItem>?> getCachedNews(String category, String country) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _newsKey(category, country);
    final cached = prefs.getString(key);
    
    if (cached == null) return null;
    
    try {
      final cacheData = jsonDecode(cached);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
      // Expire after 60 minutes to always show fresh country-specific news
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        await prefs.remove(key);
        return null;
      }
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