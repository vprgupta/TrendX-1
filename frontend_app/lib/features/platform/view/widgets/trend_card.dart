import 'package:flutter/material.dart';
import '../../model/platform.dart';
import '../../../../screens/youtube_player_screen.dart';
import '../../../../screens/tiktok_player_screen.dart';
import '../../../../screens/ai_explanation_screen.dart';
import '../../../../features/chat/view/chat_screen.dart';

class TrendCard extends StatelessWidget {
  final PlatformTrend trend;

  const TrendCard({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _handleTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildHeader(colorScheme, context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildContent(context),
            ),
            if (trend.mediaUrl != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildMedia(context),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildEngagement(colorScheme, context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (trend.platformName == 'YouTube' && trend.videoId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => YoutubePlayerScreen(
            videoId: trend.videoId!,
            title: trend.title,
          ),
        ),
      );
    } else if (trend.platformName == 'TikTok') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TikTokPlayerScreen(
            title: trend.title,
            username: trend.userName,
            description: trend.caption,
            videoId: trend.videoId,
          ),
        ),
      );
    } else {
      // Show AI explanation for other platforms
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AIExplanationScreen(
            title: trend.title,
            content: trend.caption,
            platform: trend.platformName,
            userAvatarUrl: trend.userAvatarUrl,
            userName: trend.userName,
          ),
        ),
      );
    }
  }

  Widget _buildHeader(ColorScheme colorScheme, BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(trend.userAvatarUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trend.userName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatTimestamp(trend.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                '${trend.rank}',
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
          trend.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          trend.caption,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 2,
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
          trend.mediaUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        // AI Explanation Button
        Expanded(
          child: _buildActionButton(
            context,
            'Explain',
            Icons.auto_awesome,
            Colors.purple,
            () {
              if (trend.platformName == 'YouTube' && trend.videoId != null) {
                // For video content, maybe we still show AI explanation? 
                // The original logic pushed YoutubePlayerScreen on tap.
                // Let's open AI Explanation here specifically.
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AIExplanationScreen(
                      title: trend.title,
                      content: trend.caption,
                      platform: trend.platformName,
                      userAvatarUrl: trend.userAvatarUrl,
                      userName: trend.userName,
                    ),
                  ),
                );
              } else {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AIExplanationScreen(
                      title: trend.title,
                      content: trend.caption,
                      platform: trend.platformName,
                      userAvatarUrl: trend.userAvatarUrl,
                      userName: trend.userName,
                    ),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        
        // Chat Button
        Expanded(
          child: _buildActionButton(
            context,
            'Chat',
            Icons.chat_bubble_outline,
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    trendTitle: trend.title,
                    trendPlatform: trend.platformName,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // Save Button
        Expanded(
          child: _buildActionButton(
            context,
            'Save',
            Icons.bookmark_border,
            Colors.orange,
            () {
               // TODO: Save logic
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to bookmarks')),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
}