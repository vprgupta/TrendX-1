import 'package:flutter/material.dart';
import '../../model/platform.dart';
import 'enhanced_trend_card.dart';

class EnhancedPlatformFeed extends StatefulWidget {
  final String platformName;
  final List<PlatformTrend> trends;
  final int animationDelay;

  const EnhancedPlatformFeed({
    super.key,
    required this.platformName,
    required this.trends,
    this.animationDelay = 0,
  });

  @override
  State<EnhancedPlatformFeed> createState() => _EnhancedPlatformFeedState();
}

class _EnhancedPlatformFeedState extends State<EnhancedPlatformFeed>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<double> _headerScaleAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.elasticOut),
    );
    
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));
    
    _headerOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeIn),
    );
    
    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _headerController.forward();
        _cardsController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trends.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildAnimatedHeader(),
        ...widget.trends.asMap().entries.map((entry) {
          final index = entry.key;
          final trend = entry.value;
          return AnimatedBuilder(
            animation: _cardsController,
            builder: (context, child) {
              final cardDelay = index * 0.1;
              final cardAnimation = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _cardsController,
                  curve: Interval(
                    cardDelay,
                    (cardDelay + 0.3).clamp(0.0, 1.0),
                    curve: Curves.easeOutBack,
                  ),
                ),
              );
              
              return Transform.scale(
                scale: cardAnimation.value,
                child: Opacity(
                  opacity: cardAnimation.value,
                  child: EnhancedTrendCard(
                    trend: trend,
                    index: index,
                  ),
                ),
              );
            },
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return SlideTransition(
          position: _headerSlideAnimation,
          child: ScaleTransition(
            scale: _headerScaleAnimation,
            child: FadeTransition(
              opacity: _headerOpacityAnimation,
              child: _buildHeader(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(24),
        shadowColor: _getPlatformColor(widget.platformName).withValues(alpha: 0.3),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getPlatformColor(widget.platformName),
                _getPlatformColor(widget.platformName).withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getPlatformIcon(widget.platformName),
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.platformName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.trends.length} trending posts',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_down,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No trends available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for trending content on ${widget.platformName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'reddit':
        return const Color(0xFFFF4500);
      case 'snapchat':
        return const Color(0xFFFFFC00);
      case 'pinterest':
        return const Color(0xFFBD081C);
      case 'discord':
        return const Color(0xFF5865F2);
      default:
        return Colors.grey;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt;
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return Icons.alternate_email;
      case 'youtube':
        return Icons.play_circle_filled;
      case 'tiktok':
        return Icons.music_note;
      case 'linkedin':
        return Icons.business;
      case 'reddit':
        return Icons.forum;
      case 'snapchat':
        return Icons.camera;
      case 'pinterest':
        return Icons.push_pin;
      case 'discord':
        return Icons.chat;
      default:
        return Icons.public;
    }
  }
}