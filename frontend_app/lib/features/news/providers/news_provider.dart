import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/di/service_locator.dart';
import '../../../core/models/news_item.dart';
import '../../../core/services/news_service.dart';
import '../../../core/services/preferences_service.dart';

// Simpler state management using FutureProvider
final newsProvider = FutureProvider.family<List<NewsItem>, String>((ref, category) async {
  final newsService = getIt<NewsService>();
  final preferencesService = getIt<PreferencesService>();
  
  // Get the globally selected country
  final selectedCountry = preferencesService.selectedCountryFilter;
  
  // Convert full names like 'India' to codes if needed, or pass it directly.
  // The backend Google RSS translates names or codes based on mapped logic, but 'US' or 'IN' is preferred.
  String countryCode = selectedCountry == 'Worldwide' ? 'US' : selectedCountry.substring(0, 2).toUpperCase();
  if (selectedCountry == 'India') countryCode = 'IN';
  if (selectedCountry == 'United States' || selectedCountry == 'USA') countryCode = 'US';
  if (selectedCountry == 'United Kingdom' || selectedCountry == 'UK') countryCode = 'UK';
  
  return await newsService.getNews(category, country: countryCode);
});

// Provider specific to listing countries in the Country screen
// Returns velocity-ranked stories for a specific country
final countryNewsProvider = FutureProvider.family<List<NewsItem>, String>((ref, countryName) async {
  final newsService = getIt<NewsService>();
  
  // Map full country names to ISO country codes
  const codeMap = {
    'India': 'IN',
    'United States': 'US', 'USA': 'US',
    'United Kingdom': 'GB', 'UK': 'GB',
    'Japan': 'JP',
    'Germany': 'DE',
    'France': 'FR',
    'Brazil': 'BR',
    'Canada': 'CA',
    'Australia': 'AU',
    'China': 'CN',
    'Russia': 'RU',
    // ISO codes pass through directly
    'US': 'US', 'IN': 'IN', 'GB': 'GB', 'JP': 'JP',
    'DE': 'DE', 'FR': 'FR', 'BR': 'BR', 'CA': 'CA',
    'AU': 'AU', 'CN': 'CN', 'RU': 'RU',
  };
  
  final countryCode = codeMap[countryName] ?? countryName;
  
  // Fetch top news for the country
  return await newsService.getNews('top', country: countryCode);
});

/// Provider for Country section: fetches a SPECIFIC category for a specific country.
/// Key format: "<countryCode>|<category>" e.g. "IN|Politics"
/// This fixes the bug where all sections showed identical 'top' news.
final countryNewsByCategoryProvider = FutureProvider.family<List<NewsItem>, String>((ref, key) async {
  final newsService = getIt<NewsService>();
  final parts = key.split('|');
  final countryCode = parts[0]; // e.g. 'IN'
  final category = parts.length > 1 ? parts[1] : 'top'; // e.g. 'Politics'
  return await newsService.getNews(category, country: countryCode);
});

// ─── Breakthrough ─────────────────────────────────────────────────────────────

/// A single breakthrough discovery item from the dedicated backend endpoint.
class BreakthroughItem {
  final String domain;
  final String domainColor;
  final String title;
  final String link;
  final String pubDate;
  final String snippet;
  final String source;
  final String? imageUrl;
  final String? author;

  const BreakthroughItem({
    required this.domain,
    required this.domainColor,
    required this.title,
    required this.link,
    required this.pubDate,
    required this.snippet,
    required this.source,
    this.imageUrl,
    this.author,
  });

  factory BreakthroughItem.fromJson(Map<String, dynamic> j) => BreakthroughItem(
        domain: j['domain'] ?? 'Science',
        domainColor: j['domainColor'] ?? '#00B4D8',
        title: j['title'] ?? '',
        link: j['link'] ?? '#',
        pubDate: j['pubDate'] ?? '',
        snippet: j['snippet'] ?? '',
        source: j['source'] ?? 'Unknown',
        imageUrl: j['imageUrl'],
        author: j['author'],
      );

  /// Converts to NewsItem for reuse with the existing NewsCard widget.
  NewsItem toNewsItem(int rank) => NewsItem(
        title: title,
        link: link,
        pubDate: pubDate,
        content: snippet,
        contentSnippet: snippet,
        source: source,
        imageUrl: imageUrl,
        author: author,
        rank: rank,
      );
}

/// Provider that fetches all breakthrough items from /api/news/breakthrough.
/// Grouped result: Map<domainLabel, List<BreakthroughItem>>
final breakthroughProvider =
    FutureProvider<Map<String, List<BreakthroughItem>>>((ref) async {
  const baseUrl = 'https://trendx-1.onrender.com/api';
  final uri = Uri.parse('$baseUrl/news/breakthrough');

  final response = await http.get(uri).timeout(const Duration(seconds: 30));
  if (response.statusCode != 200) {
    throw Exception('Breakthrough fetch failed: ${response.statusCode}');
  }

  final List<dynamic> raw = jsonDecode(response.body);
  final items = raw.map((e) => BreakthroughItem.fromJson(e as Map<String, dynamic>)).toList();

  // Group by domain, preserve order from DOMAINS list on backend
  final Map<String, List<BreakthroughItem>> grouped = {};
  for (final item in items) {
    grouped.putIfAbsent(item.domain, () => []).add(item);
  }
  return grouped;
});

