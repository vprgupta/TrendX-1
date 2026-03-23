import 'package:flutter/material.dart';
import '../../../core/widgets/news_feed.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/di/service_locator.dart';

class LocalNewsScreen extends StatefulWidget {
  const LocalNewsScreen({super.key});

  @override
  State<LocalNewsScreen> createState() => _LocalNewsScreenState();
}

class _LocalNewsScreenState extends State<LocalNewsScreen> {
  final PreferencesService _prefsService = getIt<PreferencesService>();

  @override
  void initState() {
    super.initState();
    _prefsService.addListener(_onPrefsChanged);
    _prefsService.loadCountryFilter();
  }

  @override
  void dispose() {
    _prefsService.removeListener(_onPrefsChanged);
    super.dispose();
  }

  void _onPrefsChanged() => setState(() {});

  String get _countryCode {
    final filter = _prefsService.selectedCountryFilter;
    if (filter.isEmpty || filter == 'Worldwide') return 'US';
    return filter;
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
                'Local News',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: 1,
        itemBuilder: (context, index) {
          return NewsFeed(
            categoryName: 'local',
            countryOverride: _countryCode,
          );
        },
      ),
    );
  }
}
