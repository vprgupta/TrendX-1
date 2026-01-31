import 'package:flutter/material.dart';
import 'glass_container.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          // Icon Container
          GlassContainer(
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(8),
            color: color.withOpacity(0.15),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Title - Adaptive color
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isDark 
                  ? Colors.white.withOpacity(0.9)
                  : color.withOpacity(0.9), // Use platform color in light mode
              shadows: [
                Shadow(
                  color: color.withOpacity(isDark ? 0.5 : 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Divider Line with Fade - Adaptive opacity
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(isDark ? 0.5 : 0.4),
                    color.withOpacity(isDark ? 0.1 : 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
