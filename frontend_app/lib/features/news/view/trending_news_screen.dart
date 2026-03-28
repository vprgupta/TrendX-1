import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/news_item.dart';
import '../../../core/models/trending_story.dart';
import '../../../core/widgets/news_card.dart';
import '../../../core/widgets/category_stories_bar.dart';
import '../../../core/widgets/pull_to_refresh.dart';
import '../../../core/widgets/no_internet_banner.dart';
import '../providers/trending_news_provider.dart';

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

// Map from CategoryStory.filterKey → TrendingStory.category
const _categoryMapping = {
  'All': null,
  'Technology': 'Technology',
  'Geopolitics': 'Geopolitics',
  'Health': 'Health',
  'General': 'General',
  'Science': 'Science',
  'Business': 'Business',
  'Sports': 'Sports',
};

class TrendingNewsScreen extends ConsumerStatefulWidget {
  const TrendingNewsScreen({super.key});

  @override
  ConsumerState<TrendingNewsScreen> createState() =>
      _TrendingNewsScreenState();
}

class _TrendingNewsScreenState extends ConsumerState<TrendingNewsScreen> {
  String _selectedCategory = 'All';

  List<TrendingStory> _filter(List<TrendingStory> stories) {
    final mapped = _categoryMapping[_selectedCategory];
    if (mapped == null) return stories;
    return stories.where((s) => s.category == mapped).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendingAsync = ref.watch(trendingNewsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      '🔥 Trending Now',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => ref.invalidate(trendingNewsProvider),
                      icon: Icon(Icons.refresh_rounded,
                          color: theme.colorScheme.primary),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),

              // ─── Stories-style Category Bar ─────────────────────────────
              const SizedBox(height: 10),
              CategoryStoriesBar(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) =>
                    setState(() => _selectedCategory = cat),
              ),

              const SizedBox(height: 8),

              // ─── News Feed ──────────────────────────────────────────────
              Expanded(
                child: trendingAsync.when(
                  loading: () => Center(
                    child: TrendXLoader(size: 56),
                  ),
                  error: (e, _) => NoInternetScreen(
                    onRetry: () => ref.invalidate(trendingNewsProvider),
                  ),
                  data: (stories) {
                    final filtered = _filter(stories);
                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'No $_selectedCategory stories trending right now.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }
                    return TrendXRefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(trendingNewsProvider),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final story = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: NewsCard(
                              news: _toNewsItem(story),
                              rank: index + 1,
                            ).animate().fadeIn(
                                delay: Duration(milliseconds: index * 40)),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
  }
}
