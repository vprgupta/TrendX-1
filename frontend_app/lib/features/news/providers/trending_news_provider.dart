import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/trending_story.dart';
import '../../../core/services/trending_news_service.dart';
import '../../../core/services/user_preference_tracker.dart';

final trendingNewsProvider = FutureProvider<List<TrendingStory>>((ref) async {
  final service = TrendingNewsService();
  final stories = await service.getTrending(limit: 25);

  // Apply personalization boosts
  final boosts = await UserPreferenceTracker.getPersonalizationBoosts();

  if (boosts.isEmpty) return stories;

  // Re-sort stories with personalized velocity = base velocity × category boost
  final scored = stories.map((story) {
    final categoryKey = story.category.toLowerCase();
    final boost = boosts[categoryKey] ?? 1.0;
    final personalScore = story.velocityScore * boost;
    return _ScoredStory(story: story, personalScore: personalScore);
  }).toList()
    ..sort((a, b) => b.personalScore.compareTo(a.personalScore));

  return scored.map((s) => s.story).toList();
});

class _ScoredStory {
  final TrendingStory story;
  final double personalScore;
  _ScoredStory({required this.story, required this.personalScore});
}
