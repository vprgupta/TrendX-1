import 'package:flutter/material.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../core/widgets/trendx_logo.dart';
import '../../../core/services/preferences_service.dart';
import '../controller/platform_controller.dart';
import '../model/platform.dart';
import 'widgets/platform_feed.dart';


class PlatformScreen extends StatefulWidget {
  const PlatformScreen({super.key});

  @override
  State<PlatformScreen> createState() => _PlatformScreenState();
}

class _PlatformScreenState extends State<PlatformScreen> {
  final PlatformController _controller = PlatformController();
  final PreferencesService _prefsService = PreferencesService();

  final Map<String, String> _countries = {
    'Worldwide': '🌍 Worldwide',
    'US': '🇺🇸 United States',
    'IN': '🇮🇳 India',
    'PK': '🇵🇰 Pakistan',
    'BD': '🇧🇩 Bangladesh',
    'LK': '🇱🇰 Sri Lanka',
    'NP': '🇳🇵 Nepal',
    'BT': '🇧🇹 Bhutan',
    'MV': '🇲🇻 Maldives',
    'AF': '🇦🇫 Afghanistan',
    'GB': '🇬🇧 United Kingdom',
    'CA': '🇨🇦 Canada',
    'AU': '🇦🇺 Australia',
    'DE': '🇩🇪 Germany',
    'FR': '🇫🇷 France',
    'JP': '🇯🇵 Japan',
    'KR': '🇰🇷 South Korea',
    'BR': '🇧🇷 Brazil',
  };

  @override
  void initState() {
    super.initState();
    _prefsService.addListener(_onPreferencesChanged);
    _prefsService.loadCountryFilter();
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
      // backgroundColor: Theme.of(context).colorScheme.surface, // Removed to match theme scaffold background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent, // Transparent to show scaffold background
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  TrendXLogo(
                    height: 80,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.tune_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      onSelected: (value) {
                        _prefsService.updateCountryFilter(value);
                      },
                      itemBuilder: (context) => _countries.entries.map((entry) {
                        return PopupMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: _prefsService.selectedPlatforms.length,
              itemBuilder: (context, index) {
                final platform = _prefsService.selectedPlatforms.elementAt(index);
                final countryCode = _prefsService.selectedCountryFilter == 'Worldwide' ? 'US' : _prefsService.selectedCountryFilter;
                return FutureBuilder<List<PlatformTrend>>(
                  future: _controller.getPlatformTrends(platform, countryCode),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: List.generate(3, (index) => const ShimmerCard()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    }
                    return PlatformFeed(
                      platformName: platform,
                      trends: snapshot.data ?? [],
                    );
                  },
                );
              },
            ),
    );
  }


}