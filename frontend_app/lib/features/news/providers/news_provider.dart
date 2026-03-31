import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  
  // Map full country names AND ISO codes to ISO country codes
  const codeMap = {
    // Full names
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
    'Nepal': 'NP',
    'Pakistan': 'PK',
    'Bangladesh': 'BD',
    'Sri Lanka': 'LK',
    'Bhutan': 'BT',
    'Maldives': 'MV',
    'Afghanistan': 'AF',
    'South Korea': 'KR',
    // ISO codes pass through directly
    'US': 'US', 'IN': 'IN', 'GB': 'GB', 'JP': 'JP',
    'DE': 'DE', 'FR': 'FR', 'BR': 'BR', 'CA': 'CA',
    'AU': 'AU', 'NP': 'NP', 'PK': 'PK', 'BD': 'BD',
    'LK': 'LK', 'BT': 'BT', 'MV': 'MV', 'AF': 'AF',
    'KR': 'KR', 'CN': 'CN', 'RU': 'RU',
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
  final countryCode = parts[0]; // e.g. 'IN' or 'NP'
  final category = parts.length > 1 ? parts[1] : 'top'; // e.g. 'Politics'
  return await newsService.getNews(category, country: countryCode);
});
