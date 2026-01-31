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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Local News',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                     _prefsService.selectedCountries.isNotEmpty 
                        ? _prefsService.selectedCountries.first 
                        : 'Your Region',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: 1, 
        itemBuilder: (context, index) {
          return const NewsFeed(
            categoryName: 'local', // Fetch data for 'local'
          );
        },
      ),
    );
  }
}
