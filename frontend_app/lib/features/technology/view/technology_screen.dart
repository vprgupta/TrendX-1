import 'package:flutter/material.dart';
import '../../../core/widgets/news_feed.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/di/service_locator.dart'; // Import DI

class TechnologyScreen extends StatefulWidget {
  const TechnologyScreen({super.key});

  @override
  State<TechnologyScreen> createState() => _TechnologyScreenState();
}

class _TechnologyScreenState extends State<TechnologyScreen> {
  // Use GetIt to access the singleton
  final PreferencesService _prefsService = getIt<PreferencesService>();

  final Map<String, String> _categoryIcons = {
    'AI': '🤖',
    'Mobile': '📱',
    'Web': '🌐',
    'Blockchain': '⛓️',
    'IoT': '📡',
    'Robotics': '🦾',
    'Cloud': '☁️',
    'Cybersecurity': '🔒',
  };

  @override
  void initState() {
    super.initState();
    _prefsService.addListener(_onPreferencesChanged);
    // In a real app we might not want to call loadFromBackend on every init if already loaded
    if (_prefsService.selectedTechCategories.isEmpty) { 
        _prefsService.loadFromBackend();
    }
  }

  @override
  void dispose() {
    _prefsService.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Technology',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _prefsService.selectedTechCategories.isEmpty
          ? EmptyStateWidget(
              title: 'No Categories Selected',
              message: 'Please select technology categories in the settings to see relevant news.',
              icon: Icons.category_outlined,
              actionLabel: 'Customize Feed',
              onAction: () {
                // TODO: Navigate to settings or show preference dialog
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: _prefsService.selectedTechCategories.length,
              itemBuilder: (context, index) {
                final category = _prefsService.selectedTechCategories.elementAt(index);
                final icon = _categoryIcons[category] ?? '💻';
                final displayName = '$icon $category';
                
                // NewsFeed now handles data fetching via Riverpod
                return NewsFeed(
                  categoryName: displayName,
                );
              },
            ),
    );
  }
}