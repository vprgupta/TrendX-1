import 'package:flutter/material.dart';
import '../../model/world_trend.dart';
import '../../../../core/services/saved_trends_service.dart';
import '../../../../screens/ai_explanation_screen.dart';

class WorldTrendCard extends StatelessWidget {
  final WorldTrend trend;

  const WorldTrendCard({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _handleTap(context),
        child: SizedBox(
          height: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildHeader(colorScheme, context),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildContent(context),
                ),
              ),
              if (trend.imageUrl != null)
                Expanded(
                  child: _buildImage(context),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildFooter(colorScheme, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIExplanationScreen(
          title: trend.title,
          content: trend.description,
          platform: 'World News',
          userAvatarUrl: 'https://i.pravatar.cc/150?img=${trend.rank + 30}',
          userName: trend.region,
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(),
                color: _getCategoryColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (trend.countryFlag != null) ...[
                        Text(trend.countryFlag!, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          trend.region,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    trend.category,
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
          trend.description,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          trend.imageUrl!,
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

  Widget _buildFooter(ColorScheme colorScheme, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _formatEngagement(trend.engagement),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              _formatTimestamp(trend.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            ListenableBuilder(
              listenable: SavedTrendsService(),
              builder: (context, _) {
                final savedService = SavedTrendsService();
                final isSaved = savedService.isTrendSaved(trend.id);
                return IconButton(
                  onPressed: () => savedService.toggleSavedTrend(trend.id),
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (trend.category.toLowerCase()) {
      case 'technology':
        return Colors.blue;
      case 'politics':
        return Colors.red;
      case 'sports':
        return Colors.green;
      case 'entertainment':
        return Colors.purple;
      case 'science':
        return Colors.teal;
      case 'health':
        return Colors.pink;
      case 'business':
        return Colors.orange;
      case 'environment':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (trend.category.toLowerCase()) {
      case 'technology':
        return Icons.computer_outlined;
      case 'politics':
        return Icons.account_balance_outlined;
      case 'sports':
        return Icons.sports_soccer_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'science':
        return Icons.science_outlined;
      case 'health':
        return Icons.health_and_safety_outlined;
      case 'business':
        return Icons.business_outlined;
      case 'environment':
        return Icons.eco_outlined;
      default:
        return Icons.public_outlined;
    }
  }

  String _formatEngagement(int engagement) {
    if (engagement >= 1000000) {
      return '${(engagement / 1000000).toStringAsFixed(1)}M';
    } else if (engagement >= 1000) {
      return '${(engagement / 1000).toStringAsFixed(0)}k';
    }
    return engagement.toString();
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