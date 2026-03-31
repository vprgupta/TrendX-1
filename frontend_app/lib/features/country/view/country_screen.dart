import 'package:flutter/material.dart';
import '../../../core/widgets/news_feed.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/di/service_locator.dart';

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  final PreferencesService _prefsService = getIt<PreferencesService>();

  final Map<String, String> _countryInfo = {
    'IN': '🇮🇳 India',
    'NP': '🇳🇵 Nepal',
    'Worldwide': '🌍 Worldwide',
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _prefsService,
      builder: (context, child) {
        final countryCode = _prefsService.selectedCountryFilter;
        final countryLabel = _countryInfo[countryCode] ?? '🌍 Global';

        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                const Text(
                  'Country Focus',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  countryLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // 1. Politics Section
                NewsFeed(
                  categoryName: 'Politics',
                  countryOverride: countryCode == 'Worldwide' ? 'IN' : countryCode,
                ),
                const Divider(),
                
                // 2. Finance Section
                NewsFeed(
                  categoryName: 'Business', // Backend maps 'Business' to finance-related
                  countryOverride: countryCode == 'Worldwide' ? 'IN' : countryCode,
                ),
                const Divider(),
                
                // 3. Health Section
                NewsFeed(
                  categoryName: 'Health',
                  countryOverride: countryCode == 'Worldwide' ? 'IN' : countryCode,
                ),
                const Divider(),

                // 4. Entertainment Section
                NewsFeed(
                  categoryName: 'Entertainment',
                  countryOverride: countryCode == 'Worldwide' ? 'IN' : countryCode,
                ),
                const Divider(),

                // 5. Sports Section
                NewsFeed(
                  categoryName: 'Sports',
                  countryOverride: countryCode == 'Worldwide' ? 'IN' : countryCode,
                ),
                const Divider(),

                // 6. Science Section
                NewsFeed(
                  categoryName: 'Science',
                  countryOverride: countryCode == 'Worldwide' ? 'IN' : countryCode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}