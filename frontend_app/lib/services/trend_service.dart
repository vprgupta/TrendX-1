import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class Trend {
  final String id;
  final String title;
  final String content;
  final String platform;
  final String category;
  final String country;
  final String? imageUrl;
  final String? url;
  final String? author;
  final DateTime publishedAt;
  final Map<String, dynamic> metrics;
  
  // Trending scores
  final double trendingScore;
  final double? engagementScore;
  final double? recencyScore;
  final double? viralityScore;
  final double? velocityScore;
  
  // Cross-platform data
  final List<String>? platforms;
  final int? platformCount;
  final double? globalScore;
  final String? trendingType;
  final String? momentum;

  Trend({
    required this.id,
    required this.title,
    required this.content,
    required this.platform,
    required this.category,
    required this.country,
    this.imageUrl,
    this.url,
    this.author,
    required this.publishedAt,
    required this.metrics,
    required this.trendingScore,
    this.engagementScore,
    this.recencyScore,
    this.viralityScore,
    this.velocityScore,
    this.platforms,
    this.platformCount,
    this.globalScore,
    this.trendingType,
    this.momentum,
  });

  factory Trend.fromJson(Map<String, dynamic> json) {
    return Trend(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      platform: json['platform'] ?? '',
      category: json['category'] ?? 'general',
      country: json['country'] ?? 'global',
      imageUrl: json['imageUrl'],
      url: json['url'],
      author: json['author'],
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt']) 
          : DateTime.now(),
      metrics: json['metrics'] ?? {},
      trendingScore: (json['trendingScore'] ?? 0).toDouble(),
      engagementScore: json['engagementScore']?.toDouble(),
      recencyScore: json['recencyScore']?.toDouble(),
      viralityScore: json['viralityScore']?.toDouble(),
      velocityScore: json['velocityScore']?.toDouble(),
      platforms: json['platforms'] != null 
          ? List<String>.from(json['platforms']) 
          : null,
      platformCount: json['platformCount'],
      globalScore: json['globalScore']?.toDouble(),
      trendingType: json['trendingType'],
      momentum: json['momentum'],
    );
  }
}

class TrendService {
  /// Get global trending topics (cross-platform aggregation)
  static Future<List<Trend>> getGlobalTrending(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.trends}/trending/global'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['trends'] as List)
            .map((json) => Trend.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load global trends');
    } catch (e) {
      print('Error fetching global trends: $e');
      return [];
    }
  }

  /// Get trends by platform
  static Future<List<Trend>> getTrendsByPlatform(
    String platform, 
    String token
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.trends}/trending/platform/$platform'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['trends'] as List)
            .map((json) => Trend.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load platform trends');
    } catch (e) {
      print('Error fetching platform trends: $e');
      return [];
    }
  }

  /// Get trends by category (World or Tech)
  static Future<List<Trend>> getTrendsByCategory(
    String category,
    String token
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.trends}/trending/category/$category'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['trends'] as List)
            .map((json) => Trend.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load category trends');
    } catch (e) {
      print('Error fetching category trends: $e');
      return [];
    }
  }

  /// Get trends by country
  static Future<List<Trend>> getTrendsByCountry(
    String country,
    String token
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.trends}/trending/country/$country'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['trends'] as List)
            .map((json) => Trend.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load country trends');
    } catch (e) {
      print('Error fetching country trends: $e');
      return [];
    }
  }

  /// Get personalized trends based on user preferences
  static Future<List<Trend>> getPersonalizedTrends(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.trends}/personalized'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['trends'] as List)
            .map((json) => Trend.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load personalized trends');
    } catch (e) {
      print('Error fetching personalized trends: $e');
      return [];
    }
  }

  /// Get all trends (existing endpoint)
  static Future<List<Trend>> getAllTrends(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.trends),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((json) => Trend.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load trends');
    } catch (e) {
      print('Error fetching trends: $e');
      return [];
    }
  }
}
