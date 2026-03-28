import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_item.dart';
import '../../screens/ai_explanation_screen.dart';
import '../../features/chat/view/chat_screen.dart';
import 'animations.dart';

class NewsCard extends StatelessWidget {
  final NewsItem news;
  final int rank;

  const NewsCard({
    super.key,
    required this.news,
    this.rank = 1,
  });

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(news.link);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  String _formatTimestamp() {
    final ts = DateTime.tryParse(news.pubDate) ?? DateTime.now();
    final diff = DateTime.now().difference(ts);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _estimateReadTime() {
    final words =
        (news.content.isEmpty ? news.contentSnippet : news.content).split(' ').length;
    final minutes = (words / 200).ceil().clamp(1, 99);
    return '$minutes min read';
  }

  bool get _hasImage => news.imageUrl != null && news.imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleOnTap(
      onTap: _launchURL,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        color: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 1. HEADER: source + timestamp + rank badge ────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                children: [
                  // Source avatar
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: cs.primary.withOpacity(0.12),
                    backgroundImage:
                        (news.authorAvatarUrl != null && news.authorAvatarUrl!.isNotEmpty)
                            ? NetworkImage(news.authorAvatarUrl!)
                            : null,
                    child:
                        (news.authorAvatarUrl == null || news.authorAvatarUrl!.isEmpty)
                            ? Icon(Icons.newspaper_outlined,
                                size: 14, color: cs.primary)
                            : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news.source,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_formatTimestamp()}  ·  ${_estimateReadTime()}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rank badge
                  if (rank <= 5)
                    _RankBadge(rank: rank, hot: true)
                  else if (rank <= 10)
                    _RankBadge(rank: rank, hot: false),
                ],
              ),
            ),

            // ── 2. TITLE (heading at top) ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Text(
                news.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                  color: cs.onSurface,
                ),
              ),
            ),

            // ── 3. IMAGE (middle) ─────────────────────────────────────────
            if (_hasImage) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    news.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey.withOpacity(0.1),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            // ── 4. DESCRIPTION (bold, 9 lines) ────────────────────────────
            if (news.contentSnippet.isNotEmpty || news.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Text(
                  news.contentSnippet.isNotEmpty
                      ? news.contentSnippet
                      : news.content,
                  maxLines: 9,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.55,
                    color: cs.onSurface.withOpacity(isDark ? 0.85 : 0.78),
                  ),
                ),
              ),

            // ── 5. ACTION BUTTONS ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'AI Explain',
                      icon: Icons.auto_awesome_rounded,
                      onTap: () => _showAIExplanation(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: 'Discuss',
                      icon: Icons.chat_bubble_outline_rounded,
                      onTap: () => _openChat(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _IconOnlyButton(
                    icon: Icons.open_in_new_rounded,
                    onTap: _launchURL,
                    tooltip: 'Open article',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAIExplanation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AIExplanationScreen(
          title: news.title,
          content: news.content,
          platform: news.source,
          userAvatarUrl: news.authorAvatarUrl ?? '',
          userName: news.author ?? news.source,
          sourceUrl: news.link,
        ),
      ),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          trendTitle: news.title,
          trendPlatform: news.source,
          trendId: news.link,
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _RankBadge extends StatelessWidget {
  final int rank;
  final bool hot;
  const _RankBadge({required this.rank, required this.hot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hot
              ? [const Color(0xFFFF6B35), const Color(0xFFFF3B5C)]
              : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (hot ? const Color(0xFFFF3B5C) : const Color(0xFF6366F1))
                .withOpacity(0.4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(hot ? '🔥' : '📈', style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: cs.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: cs.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconOnlyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _IconOnlyButton(
      {required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 38,
          decoration: BoxDecoration(
            color: cs.onSurface.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: cs.onSurface.withOpacity(0.15)),
          ),
          child: Icon(icon, size: 16, color: cs.onSurface.withOpacity(0.7)),
        ),
      ),
    );
  }
}
