import 'package:flutter/material.dart';
import '../../../core/widgets/news_feed.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/di/service_locator.dart';
import '../../settings/view/settings_screen.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  final PreferencesService _prefsService = getIt<PreferencesService>();

  final Map<String, String> _categoryIcons = {
    'Science': '🔬',
    'Agriculture': '🌾',
    'Space': '🚀',
    'Art': '🎨',
    'Environment': '🌍',
    'Health': '⚕️',
    'Politics': '🏛️',
    'Sports': '⚽',
    'Entertainment': '🎬',
  };

  @override
  void initState() {
    super.initState();
    _prefsService.addListener(_onPreferencesChanged);
    if (_prefsService.selectedWorldCategories.isEmpty) {
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
    if (_prefsService.selectedWorldCategories.isEmpty) {
      return EmptyStateWidget(
        title: 'No Topics Selected',
        message: 'Please select world topics in the settings to see global news.',
        icon: Icons.language,
        actionLabel: 'Select Topics',
        onAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      itemCount: _prefsService.selectedWorldCategories.length,
      itemBuilder: (context, index) {
        final category = _prefsService.selectedWorldCategories.elementAt(index);
        final icon = _categoryIcons[category] ?? '🌐';
        final displayName = '$icon $category';
        
        return NewsFeed(
          categoryName: displayName,
        );
      },
    );
  }
}