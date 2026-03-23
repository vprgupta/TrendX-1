import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTime pubDate = DateTime.tryParse(news.pubDate) ?? DateTime.now();

    return ScaleOnTap(
      onTap: () => _launchURL(),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: Theme.of(context).cardTheme.elevation,
        color: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(28),
              child: _buildHeader(colorScheme, context, pubDate),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: _buildContent(context),
            ),
            if (news.imageUrl != null && news.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(28),
                child: _buildMedia(context),
              ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: _buildEngagement(colorScheme, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, BuildContext context, DateTime pubDate) {
    return Stack(
      children: [
        Row(
          children: [
            // Circular avatar with fallback
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primary.withOpacity(0.12),
              backgroundImage: (news.authorAvatarUrl != null && news.authorAvatarUrl!.isNotEmpty)
                  ? NetworkImage(news.authorAvatarUrl!)
                  : null,
              onBackgroundImageError: (news.authorAvatarUrl != null && news.authorAvatarUrl!.isNotEmpty)
                  ? (_, __) {}
                  : null,
              child: (news.authorAvatarUrl == null || news.authorAvatarUrl!.isEmpty)
                  ? Icon(Icons.person, size: 20, color: colorScheme.primary)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.source,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (news.author != null)
                    Text(
                      news.author!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    _formatTimestamp(pubDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (rank != null)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          news.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          maxLines: 8,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Text(
          news.contentSnippet.isNotEmpty ? news.contentSnippet : news.content,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 9,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMedia(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          news.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 32,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEngagement(ColorScheme colorScheme, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'Explain',
            Icons.auto_awesome,
            const Color(0xFF9E9E9E),
            () => _showAIExplanation(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            context,
            'Chat',
            Icons.chat_bubble_outline,
            const Color(0xFF9E9E9E),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    trendTitle: news.title,
                    trendPlatform: news.source,
                    trendId: news.link,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, 
    String label, 
    IconData icon, 
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayColor = isDark ? color.withOpacity(0.8) : color;
    final bgColor = isDark 
        ? color.withOpacity(0.15) 
        : color.withOpacity(0.1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark 
                  ? color.withOpacity(0.3) 
                  : color.withOpacity(0.2)
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: displayColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: displayColor,
                fontWeight: FontWeight.w600,
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
        builder: (context) => AIExplanationScreen(
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getPlatformIcon(String source) {
    final s = source.toLowerCase();
    if (s.contains('country')) return Icons.flag_outlined;
    if (s.contains('world')) return Icons.public_outlined;
    if (s.contains('tech')) return Icons.computer_outlined;
    if (s.contains('sport')) return Icons.sports_soccer_outlined;
    if (s.contains('business') || s.contains('finance')) return Icons.business_outlined;
    if (s.contains('health')) return Icons.health_and_safety_outlined;
    if (s.contains('science')) return Icons.science_outlined;
    if (s.contains('entertainment')) return Icons.movie_outlined;
    if (s.contains('politics')) return Icons.account_balance_outlined;
    return Icons.newspaper_outlined;
  }
}
