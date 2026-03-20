import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../trends/model/trend.dart';
import '../../trends/view/trend_card.dart';
import '../../../core/ui/glass_container.dart';
import '../../../core/ui/neon_text.dart';
import '../../trends/service/trend_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Trend>> _trendsFuture;

  @override
  void initState() {
    super.initState();
    _loadTrends();
  }

  void _loadTrends() {
    _trendsFuture = TrendService().fetchTrends(limit: 20).then((data) {
      return data.map((json) => Trend.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

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
            child: FutureBuilder<List<Trend>>(
              future: _trendsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.cyan));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.pink, size: 48),
                        const SizedBox(height: 16),
                        Text('Error loading trends', style: TextStyle(color: Colors.white)),
                        TextButton(
                          onPressed: () => setState(() => _loadTrends()),
                          child: const Text('Retry', style: TextStyle(color: AppTheme.cyan)),
                        )
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No trends available', style: TextStyle(color: Colors.white)));
                }

                final trends = snapshot.data!;
                return RefreshIndicator(
                  color: AppTheme.cyan,
                  backgroundColor: AppTheme.uberBlack,
                  onRefresh: () async {
                    setState(() => _loadTrends());
                    await _trendsFuture;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: trends.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return TrendCard(
                        trend: trends[index],
                        index: index,
                      );
                    },
                  ),
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
        Container(color: AppTheme.uberBlack),
        
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
      ],
    );
  }
}
