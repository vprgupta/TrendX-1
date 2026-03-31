import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/news_item.dart';
import '../../../../core/models/trending_story.dart';
import '../../../../core/widgets/news_card.dart';
import '../../../../core/ui/section_header.dart';

class TrendingCategoryFeed extends StatelessWidget {
  final String categoryName;
  final List<TrendingStory> stories;

  const TrendingCategoryFeed({
    super.key,
    required this.categoryName,
    required this.stories,
  });

  /// Converts a [TrendingStory] into the existing [NewsItem] model.
  NewsItem _toNewsItem(TrendingStory story) {
    return NewsItem(
      title: story.title,
      link: story.link,
      pubDate: story.pubDate,
      content: story.sources.join(' · '),
      contentSnippet: story.sources.join(' · '),
      source: story.sources.isNotEmpty ? story.sources.first : 'Trending',
      imageUrl: story.imageUrl,
      author: story.author ?? story.sources.join(' · '),
      authorAvatarUrl: null,
      likes: story.points,
      comments: 0,
      shares: 0,
      rank: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SectionHeader(
          title: categoryName,
          icon: _getCategoryIcon(categoryName),
          color: _getCategoryColor(categoryName),
        ),
        const SizedBox(height: 8),
        ...stories.map((story) {
           final index = stories.indexOf(story);
           return Padding(
             padding: const EdgeInsets.only(bottom: 14, left: 16, right: 16),
             child: NewsCard(
               news: _toNewsItem(story),
               rank: index + 1,
             ).animate().fadeIn(
               delay: Duration(milliseconds: index * 50),
             ).slideY(begin: 0.1, end: 0),
           );
        }),
        const SizedBox(height: 12),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'politics':
        return Colors.redAccent;
      case 'health':
        return Colors.cyan;
      case 'finance':
        return Colors.green;
      case 'science':
        return Colors.blue;
      case 'technology':
        return Colors.orange;
      case 'breakthrough':
        return Colors.deepPurpleAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'politics':
        return LucideIcons.landmark;
      case 'health':
        return LucideIcons.heartPulse;
      case 'finance':
        return LucideIcons.banknote;
      case 'science':
        return LucideIcons.microscope;
      case 'technology':
        return LucideIcons.cpu;
      case 'breakthrough':
        return LucideIcons.sparkles;
      default:
        return LucideIcons.flame;
    }
  }
}
