import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../trends/model/trend.dart';
import '../../trends/view/trend_card.dart';
import '../../../core/ui/glass_container.dart';
import '../../../core/ui/neon_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: GlassContainer(
          borderRadius: BorderRadius.zero,
          blur: 10,
          opacity: 0, // Fully transparent tint to match background
          border: null, // Remove border to blend seamlessly
          child: AppBar(
            backgroundColor: Colors.transparent,
            title: NeonText(
              'TRENDX',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              glowColor: AppTheme.cyan,
              blurRadius: 15,
            ),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ).animate().fadeIn(delay: 400.ms),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Animated Background
          const _AuroraBackground(),
          
          // 2. Content
          SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _dummyTrends.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return TrendCard(
                  trend: _dummyTrends[index],
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Deep Background
        Container(color: AppTheme.midnightBlue),
        
        // Glowing Orb 1 (Cyan)
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cyan.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cyan.withOpacity(0.2),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .moveY(begin: 0, end: 50, duration: 4.seconds)
         .scaleXY(begin: 1, end: 1.2, duration: 5.seconds),

        // Glowing Orb 2 (Violet)
        Positioned(
          bottom: 100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.violet.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.violet.withOpacity(0.2),
                  blurRadius: 120,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .moveY(begin: 0, end: -50, duration: 5.seconds)
         .scaleXY(begin: 1, end: 1.3, duration: 6.seconds),

         // Overlay Noise (Optional/Simulated)
         // ...
      ],
    );
  }
}

// Mock Data
final List<Trend> _dummyTrends = [
  Trend(
    id: '1',
    title: 'SpaceX Starship Launch',
    description: 'Starship successfully reaches orbit, marking a new era in space exploration. Global reactions flood social media.',
    rank: 1,
    popularity: 98,
    duration: const Duration(hours: 4),
    region: 'Global',
  ),
  Trend(
    id: '2',
    title: 'Bitcoin Halving Event',
    description: 'Crypto markets surge as the highly anticipated Bitcoin halving event completes. Analysts predict major volatility.',
    rank: 2,
    popularity: 92,
    duration: const Duration(hours: 12),
    region: 'Finance',
  ),
  Trend(
    id: '3',
    title: 'Cyberpunk 2077 Update',
    description: 'CD Projekt Red releases massive expansion phantom liberty, receiving critical acclaim.',
    rank: 3,
    popularity: 88,
    duration: const Duration(days: 1),
    region: 'Gaming',
  ),
];
