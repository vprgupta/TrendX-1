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
final countryNewsProvider = FutureProvider.family<List<NewsItem>, String>((ref, countryName) async {
  final newsService = getIt<NewsService>();
  
  String countryCode = 'US';
  if (countryName == 'India') countryCode = 'IN';
  if (countryName == 'United States' || countryName == 'USA' || countryName == 'US') countryCode = 'US';
  if (countryName == 'United Kingdom' || countryName == 'UK') countryCode = 'UK';
  if (countryName == 'Japan') countryCode = 'JP';
  if (countryName == 'Germany') countryCode = 'DE';
  if (countryName == 'France') countryCode = 'FR';
  if (countryName == 'Brazil') countryCode = 'BR';
  if (countryName == 'Canada') countryCode = 'CA';
  
  return await newsService.getNews('top', country: countryCode);
});
