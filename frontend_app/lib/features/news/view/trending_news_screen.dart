import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/trending_story.dart';
import '../../../core/widgets/pull_to_refresh.dart';
import '../../../core/widgets/no_internet_banner.dart';
import '../providers/trending_news_provider.dart';
import 'widgets/trending_category_feed.dart';

class TrendingNewsScreen extends ConsumerStatefulWidget {
  const TrendingNewsScreen({super.key});

  @override
  ConsumerState<TrendingNewsScreen> createState() =>
      _TrendingNewsScreenState();
}

class _TrendingNewsScreenState extends ConsumerState<TrendingNewsScreen> {
  // Target categories requested by the user
  final List<String> _displayCategories = [
    'Breakthrough',
    'Technology',
    'Politics',
    'Health',
    'Finance',
    'Science',
  ];

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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    '🔥 Trending Now',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
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

            // ─── Categorical Feed ───────────────────────────────────────
            Expanded(
              child: trendingAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => NoInternetScreen(
                  onRetry: () => ref.invalidate(trendingNewsProvider),
                ),
                data: (stories) {
                  if (stories.isEmpty) {
                    return Center(
                      child: Text(
                        'No trending stories right now. Catch up later!',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  return TrendXRefreshIndicator(
                    onRefresh: () async => ref.invalidate(trendingNewsProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: _displayCategories.length,
                      itemBuilder: (context, index) {
                        final catName = _displayCategories[index];
                        // Filter stories for this specific category
                        final filteredStories = stories
                            .where((s) => s.category.toLowerCase() == catName.toLowerCase())
                            .take(4) // Show top 4 per category to keep it concise
                            .toList();

                        if (filteredStories.isEmpty) {
                           return const SizedBox.shrink();
                        }

                        return TrendingCategoryFeed(
                          categoryName: catName,
                          stories: filteredStories,
                        ).animate().fadeIn(
                           delay: Duration(milliseconds: index * 100),
                        ).slideY(begin: 0.05, end: 0);
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

