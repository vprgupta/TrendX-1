import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/widgets/news_feed.dart';
import '../../../features/news/providers/news_provider.dart';
import '../../../core/widgets/news_card.dart';

// ─── Indian state → search query mapping ────────────────────────────────────
// The backend accepts a 'country' param (e.g. 'IN') and a 'region' search term
// via the 'local' category. We encode the state name in the countryOverride
// as "IN-<StateCode>" so the news provider can pass it properly.
// For simplicity, we encode the state name as the location query string and
// display it prominently while always using country='IN'.

class LocalNewsScreen extends StatefulWidget {
  const LocalNewsScreen({super.key});

  @override
  State<LocalNewsScreen> createState() => _LocalNewsScreenState();
}

enum _LocationStatus {
  idle,
  requesting,
  detecting,
  detected,
  denied,
  error,
}

class _LocalNewsScreenState extends State<LocalNewsScreen>
    with SingleTickerProviderStateMixin {
  _LocationStatus _status = _LocationStatus.idle;
  String? _stateName;
  String? _cityName;
  String? _errorMessage;
  int _refreshKey = 0; // incrementing this forces NewsFeed widgets to reload

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // All 28 Indian states + 8 UTs, with news search keywords
  static const Map<String, String> _stateNewsKeywords = {
    'Andhra Pradesh': 'Andhra Pradesh',
    'Arunachal Pradesh': 'Arunachal Pradesh',
    'Assam': 'Assam',
    'Bihar': 'Bihar',
    'Chhattisgarh': 'Chhattisgarh',
    'Goa': 'Goa',
    'Gujarat': 'Gujarat',
    'Haryana': 'Haryana',
    'Himachal Pradesh': 'Himachal Pradesh',
    'Jharkhand': 'Jharkhand',
    'Karnataka': 'Karnataka',
    'Kerala': 'Kerala',
    'Madhya Pradesh': 'Madhya Pradesh',
    'Maharashtra': 'Maharashtra',
    'Manipur': 'Manipur',
    'Meghalaya': 'Meghalaya',
    'Mizoram': 'Mizoram',
    'Nagaland': 'Nagaland',
    'Odisha': 'Odisha',
    'Punjab': 'Punjab',
    'Rajasthan': 'Rajasthan',
    'Sikkim': 'Sikkim',
    'Tamil Nadu': 'Tamil Nadu',
    'Telangana': 'Telangana',
    'Tripura': 'Tripura',
    'Uttar Pradesh': 'Uttar Pradesh',
    'Uttarakhand': 'Uttarakhand',
    'West Bengal': 'West Bengal',
    // UTs
    'Delhi': 'Delhi',
    'Jammu and Kashmir': 'Jammu Kashmir',
    'Ladakh': 'Ladakh',
    'Chandigarh': 'Chandigarh',
    'Puducherry': 'Puducherry',
    'Andaman and Nicobar Islands': 'Andaman Nicobar',
    'Dadra and Nagar Haveli and Daman and Diu': 'Daman Diu',
    'Lakshadweep': 'Lakshadweep',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Auto-start detection
    WidgetsBinding.instance.addPostFrameCallback((_) => _detectLocation());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Refreshes the news content WITHOUT re-detecting location.
  Future<void> _refreshNewsOnly() async {
    setState(() => _refreshKey++);
  }

  Future<void> _detectLocation() async {
    // ── Guard: never re-detect if location is already known ───────────────
    if (_status == _LocationStatus.detected) return;
    // ─────────────────────────────────────────────────────────────────────
    setState(() {
      _status = _LocationStatus.requesting;
      _errorMessage = null;
    });

    // 1. Check/request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _status = _LocationStatus.denied;
        _errorMessage = permission == LocationPermission.deniedForever
            ? 'Location permission is permanently denied.\nPlease enable it in Settings.'
            : 'Location permission was denied.\nTap the button to try again.';
      });
      return;
    }

    // 2. Check if location service is enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _status = _LocationStatus.error;
        _errorMessage = 'Location services are disabled on your device.\nPlease turn on GPS.';
      });
      return;
    }

    setState(() => _status = _LocationStatus.detecting);

    try {
      // 3. Get GPS coordinates
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // low accuracy is enough for state detection
          timeLimit: Duration(seconds: 15),
        ),
      );

      // 4. Reverse geocode with BigDataCloud free API (no key needed)
      final state = await _reverseGeocode(position.latitude, position.longitude);

      setState(() {
        _stateName = state['state'];
        _cityName = state['city'];
        _status = _LocationStatus.detected;
      });
    } catch (e) {
      setState(() {
        _status = _LocationStatus.error;
        _errorMessage = 'Could not detect your location.\nPlease check GPS and try again.';
      });
    }
  }

  Future<Map<String, String>> _reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client'
        '?latitude=$lat&longitude=$lng&localityLanguage=en',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final principalSubdivision =
            data['principalSubdivision'] as String? ?? '';
        final city = data['city'] as String? ??
            data['locality'] as String? ?? '';

        // Normalize to match our map keys
        final matchedState = _normalizeState(principalSubdivision);

        return {
          'state': matchedState,
          'city': city,
        };
      }
    } catch (_) {}
    return {'state': 'India', 'city': ''};
  }

  /// Fuzzy-match the API's state name against our known states.
  String _normalizeState(String apiState) {
    if (apiState.isEmpty) return 'India';
    final lower = apiState.toLowerCase();
    for (final key in _stateNewsKeywords.keys) {
      if (lower.contains(key.toLowerCase()) ||
          key.toLowerCase().contains(lower)) {
        return key;
      }
    }
    return apiState; // fall back to whatever the API returned
  }

  /// Always returns 'IN' — Local News is India-only.
  String get _newsCountryParam => 'IN';

  /// The category/feed name to pass to NewsFeed.
  /// Encodes the local state query into the category string.
  String get _newsCategoryParam {
    if (_stateName == null || _stateName!.isEmpty || _stateName == 'India') {
      return 'local';
    }
    final keyword = _stateNewsKeywords[_stateName!] ?? _stateName!;
    // Category "local|<state keyword>" – the backend's newsService
    // passes the country as a region search; wrapping state in the
    // countryOverride key tells NewsFeed to use countryNewsByCategoryProvider
    return 'local $keyword';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isDark),
            Expanded(child: _buildContent(theme, isDark)),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F0F1A), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF0F9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pulsing location icon
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) => Transform.scale(
              scale: _status == _LocationStatus.detecting ||
                      _status == _LocationStatus.requesting
                  ? _pulseAnim.value
                  : 1.0,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: _status == _LocationStatus.detected
                      ? const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : _status == _LocationStatus.denied ||
                              _status == _LocationStatus.error
                          ? const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                            ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (_status == _LocationStatus.detected
                              ? const Color(0xFF10B981)
                              : const Color(0xFF3B82F6))
                          .withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  _status == _LocationStatus.detected
                      ? LucideIcons.mapPin
                      : _status == _LocationStatus.denied ||
                              _status == _LocationStatus.error
                          ? LucideIcons.mapPinOff
                          : LucideIcons.locate,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local News',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                _buildLocationSubtitle(theme),
              ],
            ),
          ),

          // Re-detect button
          if (_status == _LocationStatus.detected ||
              _status == _LocationStatus.denied ||
              _status == _LocationStatus.error ||
              _status == _LocationStatus.idle)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Refresh news button (does NOT re-detect location)
                if (_status == _LocationStatus.detected)
                  IconButton(
                    onPressed: _refreshNewsOnly,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    color: Colors.teal,
                    tooltip: 'Refresh news',
                  ),
                // Re-detect location button
                IconButton(
                  onPressed: () {
                    // Allow re-detection by resetting status first
                    setState(() => _status = _LocationStatus.idle);
                    _detectLocation();
                  },
                  icon: const Icon(Icons.my_location_rounded, size: 20),
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: 'Re-detect location',
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildLocationSubtitle(ThemeData theme) {
    switch (_status) {
      case _LocationStatus.idle:
      case _LocationStatus.requesting:
        return Text(
          'Requesting location permission...',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      case _LocationStatus.detecting:
        return Row(
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Detecting your state...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        );
      case _LocationStatus.detected:
        return Row(
          children: [
            Icon(Icons.location_on, size: 12, color: const Color(0xFF10B981)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _cityName != null && _cityName!.isNotEmpty
                    ? '$_cityName, $_stateName'
                    : _stateName ?? 'India',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case _LocationStatus.denied:
      case _LocationStatus.error:
        return Text(
          'Tap 📍 to enable local news',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        );
    }
  }

  // ── Content ──────────────────────────────────────────────────────────────────

  Widget _buildContent(ThemeData theme, bool isDark) {
    switch (_status) {
      case _LocationStatus.idle:
      case _LocationStatus.requesting:
      case _LocationStatus.detecting:
        return _buildLoadingState(theme);

      case _LocationStatus.denied:
      case _LocationStatus.error:
        return _buildPermissionError(theme, isDark);

      case _LocationStatus.detected:
        return _buildNewsFeed(theme);
    }
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _status == _LocationStatus.requesting
                ? 'Requesting permission...'
                : 'Finding your location...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re detecting your state to show\nhyper-local news for you',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildPermissionError(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.mapPinOff,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Location Access Needed',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Location permission was denied.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _detectLocation,
              icon: const Icon(LucideIcons.locate, size: 18),
              label: const Text('Grant Location Access'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Option to open settings if permanently denied
            if (_errorMessage?.contains('permanently') == true)
              TextButton(
                onPressed: () => Geolocator.openAppSettings(),
                child: const Text('Open App Settings'),
              ),
            const SizedBox(height: 16),
            // Manual state picker fallback
            OutlinedButton.icon(
              onPressed: _showManualStatePicker,
              icon: const Icon(LucideIcons.list, size: 16),
              label: const Text('Choose State Manually'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildNewsFeed(ThemeData theme) {
    final stateDisplay = _stateName ?? 'India';
    final city = _cityName ?? '';
    final newsCategories = ['Politics', 'Business', 'Health', 'Crime', 'Sports'];

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120, top: 8),
      itemCount: newsCategories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildStateBanner(theme, stateDisplay);
        final cat = newsCategories[index - 1];
        return _LocalStateFeed(
          key: ValueKey('$stateDisplay-$city-$cat-$_refreshKey'),
          state: stateDisplay,
          city: city,
          category: cat,
        ).animate().fadeIn(
              delay: Duration(milliseconds: (index - 1) * 100),
              duration: 400.ms,
            );
      },
    );
  }

  Widget _buildStateBanner(ThemeData theme, String state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C75), Color(0xFF1B262C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C75).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🇮🇳', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Showing news for',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
                Text(
                  state,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _cityName != null && _cityName!.isNotEmpty
                      ? 'Detected near $_cityName'
                      : 'Based on your GPS location',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showManualStatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.chevronsUpDown,
                      size: 14, color: Colors.white.withOpacity(0.8)),
                  const SizedBox(width: 4),
                  Text(
                    'Change',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: -0.1, end: 0, duration: 400.ms).fadeIn();
  }

  // ── Manual state picker ───────────────────────────────────────────────────

  void _showManualStatePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StatePickerSheet(
        states: _stateNewsKeywords.keys.toList(),
        currentState: _stateName,
        onSelected: (state) {
          Navigator.pop(ctx);
          setState(() {
            _stateName = state;
            _cityName = null;
            _status = _LocationStatus.detected;
          });
        },
      ),
    );
  }
}

// ─── State Picker Bottom Sheet ───────────────────────────────────────────────
class _StatePickerSheet extends StatefulWidget {
  final List<String> states;
  final String? currentState;
  final ValueChanged<String> onSelected;

  const _StatePickerSheet({
    required this.states,
    required this.currentState,
    required this.onSelected,
  });

  @override
  State<_StatePickerSheet> createState() => _StatePickerSheetState();
}

class _StatePickerSheetState extends State<_StatePickerSheet> {
  String _query = '';

  List<String> get _filtered => widget.states
      .where((s) => s.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Select Your State',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                autofocus: false,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search states...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final state = _filtered[index];
                  final isSelected = state == widget.currentState;
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Text(
                        state[0],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    title: Text(
                      state,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle,
                            color: theme.colorScheme.primary)
                        : null,
                    onTap: () => widget.onSelected(state),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hyper-local per-section feed ────────────────────────────────────────────
/// Renders a single category section of local state news.
/// Each instance uses its own `localStateNewsProvider` key so categories
/// fetch independently and don't share each other's cached data.
class _LocalStateFeed extends ConsumerWidget {
  final String state;
  final String city;
  final String category;

  const _LocalStateFeed({
    super.key,
    required this.state,
    required this.city,
    required this.category,
  });

  IconData _icon() {
    switch (category.toLowerCase()) {
      case 'politics': return Icons.account_balance_rounded;
      case 'business': return Icons.trending_up_rounded;
      case 'health':   return Icons.favorite_rounded;
      case 'crime':    return Icons.security_rounded;
      case 'sports':   return Icons.sports_cricket_rounded;
      default:         return Icons.newspaper_rounded;
    }
  }

  Color _color() {
    switch (category.toLowerCase()) {
      case 'politics':     return const Color(0xFFE53935);
      case 'business':     return const Color(0xFF43A047);
      case 'health':       return const Color(0xFF00ACC1);
      case 'crime':        return const Color(0xFFFF7043);
      case 'sports':       return const Color(0xFF5C6BC0);
      default:             return const Color(0xFF78909C);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = '$state|$city|$category';
    final async = ref.watch(localStateNewsProvider(key));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _color();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon(), color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                category,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.25)),
                ),
                child: Text(
                  state,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Could not load $category news for $state.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  'No recent $category news found for $state.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Column(
              children: items.take(8).toList().asMap().entries.map((e) {
                return NewsCard(
                  news: e.value,
                  rank: e.key + 1,
                );
              }).toList(),
            );
          },
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Divider(
            color: theme.colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
