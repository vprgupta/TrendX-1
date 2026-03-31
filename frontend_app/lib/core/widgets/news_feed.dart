import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/section_header.dart';
import 'news_card.dart';
import 'animations.dart';
import '../../features/news/providers/news_provider.dart';

class NewsFeed extends ConsumerWidget {
  final String categoryName;
  /// When set, fetches this specific category for the given country code (e.g. 'IN').
  /// Uses the `countryNewsByCategoryProvider` which correctly routes category + country
  /// to the backend, fixing the duplication bug where all sections showed 'top' news.
  final String? countryOverride;

  const NewsFeed({
    super.key,
    required this.categoryName,
    this.countryOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // When a country override is provided, use the composite key provider
    // so each section gets its OWN category (Politics, Health, etc.) for that country.
    final newsAsync = countryOverride != null
        ? ref.watch(countryNewsByCategoryProvider('$countryOverride|$categoryName'))
        : ref.watch(newsProvider(categoryName));

    return Column(
      children: [
        // Section Header
        SectionHeader(
          title: categoryName,
          icon: _getCategoryIcon(categoryName),
          color: _getCategoryColor(categoryName),
        ),
        
        // Content based on AsyncValue state
        newsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text('Error: $err', style: const TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: () => countryOverride != null
                      ? ref.refresh(countryNewsByCategoryProvider('$countryOverride|$categoryName'))
                      : ref.refresh(newsProvider(categoryName)),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
          data: (items) => Column(
            children: _buildNewsList(items),
          ),
        ),
          
        const SizedBox(height: 8),
      ],
    );
  }

  List<Widget> _buildNewsList(List items) {
    if (items.isEmpty) {
        return [const Padding(padding: EdgeInsets.all(16), child: Text("No news available."))];
    }

    final limit = categoryName.toLowerCase().contains('world') ? 50 : 15;
    final topNews = items.take(limit).toList(); 

    return topNews.asMap().entries.map((entry) {
      final index = entry.key;
      final news = entry.value;
      return FadeInSlide(
        index: index,
         duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: NewsCard(
            news: news,
            rank: index + 1,
          ),
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'world news':
      case 'world':
        return Colors.blue;
      case 'politics':
        return const Color(0xFFE53935);
      case 'business':
      case 'finance':
        return const Color(0xFF43A047);
      case 'health':
        return const Color(0xFF00ACC1);
      case 'entertainment':
        return const Color(0xFFAB47BC);
      case 'sports':
        return const Color(0xFFFF7043);
      case 'science':
        return const Color(0xFF1E88E5);
      case 'technology news':
      case 'technology':
        return Colors.deepPurple;
      case 'country news':
      case 'country':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'world news':
      case 'world':
        return Icons.public;
      case 'politics':
        return Icons.account_balance;
      case 'business':
      case 'finance':
        return Icons.trending_up;
      case 'health':
        return Icons.favorite;
      case 'entertainment':
        return Icons.movie;
      case 'sports':
        return Icons.sports_cricket;
      case 'science':
        return Icons.science;
      case 'technology news':
      case 'technology':
        return Icons.computer;
      case 'country news':
      case 'country':
        return Icons.flag;
      default:
        return Icons.newspaper;
    }
  }
}
