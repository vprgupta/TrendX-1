import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/ui/glass_container.dart';
import '../../../config/theme.dart';
import '../model/trend.dart';

class TrendDetailScreen extends StatelessWidget {
  final Trend trend;

  const TrendDetailScreen({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: GlassContainer(
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(8),
            color: isDark ? Colors.black : Colors.white,
            opacity: 0.2,
            child: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Animated Background (Simple Gradient Mesh approximation)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surface,
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          
          // Glowing Orb for ambience
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ).animate().scale(duration: 2.seconds, curve: Curves.easeInOut).fadeIn(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Title Transition
                  Hero(
                    tag: 'trend_title_${trend.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        trend.title,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: colorScheme.primary.withOpacity(0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Rank Badge
                  GlassContainer(
                    borderRadius: BorderRadius.circular(50),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: colorScheme.primary,
                    opacity: 0.1,
                    border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.trophy, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Rank #${trend.rank}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(),

                  const SizedBox(height: 32),

                  // Metrics Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildDetailCard(
                        context, 
                        'Popularity', 
                        '${trend.popularity}%', 
                        LucideIcons.trendingUp, 
                        AppTheme.neonRed
                      ),
                      _buildDetailCard(
                        context, 
                        'Volume', 
                        '2.4M', // Mock data
                        LucideIcons.activity, 
                        AppTheme.cyan
                      ),
                      _buildDetailCard(
                        context, 
                        'Region', 
                        trend.region, 
                        LucideIcons.globe, 
                        AppTheme.violet
                      ),
                      _buildDetailCard(
                        context, 
                        'Duration', 
                        '${trend.duration.inHours}h', 
                        LucideIcons.clock, 
                        Colors.orange
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  // Description
                  Text(
                    'About this Trend',
                     style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 16),
                  Text(
                    trend.description * 3, // Mock extended description
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ).animate().fadeIn(delay: 700.ms),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      opacity: 0.05,
      border: Border.all(color: Colors.white.withOpacity(0.05)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
