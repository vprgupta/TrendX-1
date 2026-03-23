import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/news_item.dart';
import '../../../core/models/trending_story.dart';
import '../../../core/widgets/news_card.dart';
import '../providers/trending_news_provider.dart';

/// Converts a [TrendingStory] (from the velocity engine) into the existing
/// [NewsItem] model so the standard [NewsCard] widget can render it identically
/// to every other news section in the app.
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

class TrendingNewsScreen extends ConsumerStatefulWidget {
  const TrendingNewsScreen({super.key});

  @override
  ConsumerState<TrendingNewsScreen> createState() => _TrendingNewsScreenState();
}

class _TrendingNewsScreenState extends ConsumerState<TrendingNewsScreen> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'Technology', 'Geopolitics', 'Health', 'General'];

  List<TrendingStory> _filter(List<TrendingStory> stories) {
    if (_selectedCategory == 'All') return stories;
    return stories.where((s) => s.category == _selectedCategory).toList();
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

            // ─── Category Pills ─────────────────────────────────────────
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final selected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withOpacity(0.15),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? (theme.brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white)
                                : theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // ─── News Feed ──────────────────────────────────────────────
            Expanded(
              child: trendingAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'Backend is not running.\nStart the backend with npm run dev.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () =>
                            ref.invalidate(trendingNewsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (stories) {
                  final filtered = _filter(stories);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No ${_selectedCategory} stories trending right now.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(trendingNewsProvider),
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final story = filtered[index];
                        return NewsCard(
                          news: _toNewsItem(story),
                          rank: index + 1,
                        )
                            .animate()
                            .fadeIn(
                                delay: Duration(
                                    milliseconds: index * 40));
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
