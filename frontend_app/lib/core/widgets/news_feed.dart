import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/section_header.dart';
import 'news_card.dart';
import 'animations.dart';
import '../../features/news/providers/news_provider.dart';

class NewsFeed extends ConsumerWidget {
  final String categoryName;

  const NewsFeed({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider for this specific category
    final newsAsync = ref.watch(newsProvider(categoryName));

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
                  onPressed: () => ref.refresh(newsProvider(categoryName)),
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

    final limit = categoryName.toLowerCase().contains('world') ? 50 : 10;
    // Cast dynamic List to List<dynamic> or List<NewsItem> if generics lost, 
    // but FutureProvider<List<NewsItem>> keeps type.
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
