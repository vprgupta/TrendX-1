import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'trend_detail_screen.dart';

import '../../../core/ui/glass_container.dart';
import '../../../core/ui/neon_text.dart';
import '../../../config/theme.dart';
import '../model/trend.dart';

class TrendCard extends StatelessWidget {
  final Trend trend;
  final int index;

  const TrendCard({
    super.key,
    required this.trend,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrendDetailScreen(trend: trend),
          ),
        );
      },
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        // Adaptive Border: White for Dark (subtle), Grey for Light (visible)
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white.withOpacity(0.15) 
              : Colors.black.withOpacity(0.1), // Stronger border for light mode
          width: 1,
        ),
        // Adaptive Gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  const Color(0xFF1D2333).withOpacity(0.6), // SurfaceBlue tint
                  const Color(0xFF1D2333).withOpacity(0.4),
                ]
              : [
                  Colors.white.withOpacity(0.9), // High opacity for light mode
                  Colors.white.withOpacity(0.8),
                ],
        ),
        // Add Shadow for better separation
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        child: Stack(
          children: [
            // Background Glow Effect
            Positioned(
              right: -20,
              top: -20,
              child: Hero( // Hero Transition for Background Glow
                tag: 'trend_glow_${trend.id}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.4),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rank Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: NeonText(
                          '#${trend.rank}',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                             color: colorScheme.primary,
                             fontWeight: FontWeight.bold,
                          ),
                          glowColor: colorScheme.primary,
                          blurRadius: 5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Hero( // Hero Transition for Title
                          tag: 'trend_title_${trend.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              trend.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: Text(
                      trend.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Metrics
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetric(
                          context,
                          LucideIcons.trendingUp,
                          '${trend.popularity}%',
                          AppTheme.neonRed,
                        ),
                        _buildVerticalDivider(),
                        _buildMetric(
                          context,
                          LucideIcons.clock,
                          _formatDuration(trend.duration),
                          AppTheme.cyan,
                        ),
                        _buildVerticalDivider(),
                        _buildMetric(
                          context,
                          LucideIcons.globe,
                          trend.region,
                          AppTheme.violet,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate()
       .fadeIn(delay: (100 * index).ms, duration: 600.ms)
       .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    IconData icon,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays}d';
    if (duration.inHours > 0) return '${duration.inHours}h';
    return '${duration.inMinutes}m';
  }
}