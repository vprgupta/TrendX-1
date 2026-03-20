import 'package:flutter/material.dart';
import '../../../core/widgets/news_feed.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/di/service_locator.dart';
import '../../settings/view/settings_screen.dart';

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  final PreferencesService _prefsService = getIt<PreferencesService>();

  final Map<String, String> _countryFlags = {
    'USA': '🇺🇸',
    'India': '🇮🇳',
    'UK': '🇬🇧',
    'Japan': '🇯🇵',
    'Germany': '🇩🇪',
    'France': '🇫🇷',
    'Brazil': '🇧🇷',
    'Canada': '🇨🇦',
  };

  @override
  void initState() {
    super.initState();
    _prefsService.addListener(_onPreferencesChanged);
    if (_prefsService.selectedCountries.isEmpty) {
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
                'Country News',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _prefsService.selectedCountries.isEmpty
          ? EmptyStateWidget(
              title: 'No Countries Selected',
              message: 'Please select countries in the settings to see local news.',
              icon: Icons.public,
              actionLabel: 'Select Countries',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: _prefsService.selectedCountries.length,
              itemBuilder: (context, index) {
                final country = _prefsService.selectedCountries.elementAt(index);
                final flag = _countryFlags[country] ?? '🏳️';
                final displayName = '$flag $country';
                
                // Just passing the country as override to independently fetch Top News from it
                return NewsFeed(
                  categoryName: displayName,
                  countryOverride: country,
                );
              },
            ),
    );
  }
}