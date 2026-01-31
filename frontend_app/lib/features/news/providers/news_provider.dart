import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/news_item.dart';
import '../../../core/services/news_service.dart';

// Simpler state management using FutureProvider
final newsProvider = FutureProvider.family<List<NewsItem>, String>((ref, category) async {
  final newsService = getIt<NewsService>();
  return await newsService.getNews(category);
});
