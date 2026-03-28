import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../platform/view/platform_screen.dart';
import '../country/view/country_screen.dart';
import '../technology/view/technology_screen.dart';
import '../profile/view/profile_screen.dart';
import '../politics/view/politics_screen.dart';
import '../geopolitics/view/geopolitics_screen.dart';
import '../local_news/view/local_news_screen.dart';
import '../news/view/trending_news_screen.dart';
import '../../screens/reels_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/ui/glass_container.dart';
import '../../config/theme.dart';
import '../../core/services/preferences_service.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../core/widgets/no_internet_banner.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  
  const MainNavigation({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final PreferencesService _prefsService = PreferencesService();

  // All possible nav items map
  final Map<String, NavItem> _allNavItems = {
    'platform': NavItem(LucideIcons.layoutGrid, 'Platform', AppTheme.cyan),
    'shorts': NavItem(LucideIcons.play, 'Shorts', AppTheme.violet),
    'country': NavItem(LucideIcons.flag, 'Country', Colors.green),
    'tech': NavItem(LucideIcons.monitor, 'Tech', Colors.orange),
    'politics': NavItem(LucideIcons.landmark, 'Politics', Colors.red),
    'geopolitics': NavItem(LucideIcons.globe, 'Geopolitics', Colors.blue),
    'local': NavItem(LucideIcons.mapPin, 'Local', Colors.teal),
    'trending': NavItem(LucideIcons.flame, 'Trending', const Color(0xFFFF6600)),
    'profile': NavItem(LucideIcons.user, 'Profile', AppTheme.neonRed),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _prefsService.addListener(_onPrefsChanged);
    _prefsService.loadNavbarOrder(); // Ensure order is loaded
  }

  void _onPrefsChanged() {
    setState(() {
      // Rebuild when prefs change
      if (_currentIndex >= _prefsService.navbarOrder.length) {
         _currentIndex = 0; // Reset index if out of bounds
      }
    });
  }

  @override
  void dispose() {
    _prefsService.removeListener(_onPrefsChanged);
    _animationController.dispose();
    super.dispose();
  }
  
  List<String> get _currentOrder => _prefsService.navbarOrder.isNotEmpty 
      ? _prefsService.navbarOrder 
      : ['platform', 'trending', 'shorts', 'country', 'profile'];

  List<Widget> get _screens {
    return _currentOrder.map((id) {
       switch (id) {
         case 'platform': return const PlatformScreen();
         case 'shorts': return ReelsScreen(isActive: _currentIndex == _currentOrder.indexOf('shorts'));
         case 'country': return const CountryScreen();
         case 'tech': return const TechnologyScreen();
         case 'politics': return const PoliticsScreen();
         case 'geopolitics': return const GeopoliticsScreen();
         case 'local': return const LocalNewsScreen();
         case 'trending': return const TrendingNewsScreen();
         case 'profile': return ProfileScreen(onThemeToggle: widget.onThemeToggle, isDarkMode: widget.isDarkMode);
         default: return const SizedBox.shrink();
       }
    }).toList();
  }

  List<NavItem> get _navItems {
    return _currentOrder.where((id) => _allNavItems.containsKey(id)).map((id) => _allNavItems[id]!).toList();
  }

  void _onNavItemTapped(int index) {
    if (_currentIndex != index) {
      // Haptic Feedback for premium feel
      HapticFeedback.lightImpact();

      setState(() {
        _currentIndex = index;
      });
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  Widget _buildBody() {
    final connectivity = ref.watch(connectivityProvider);

    return connectivity.when(
      // Still checking — show normal content (avoids flash on startup)
      loading: () => IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // Error resolving connectivity — treat as offline
      error: (_, __) => NoInternetScreen(
        onRetry: () => ref.invalidate(connectivityProvider),
      ),
      data: (isOnline) {
        if (!isOnline) {
          return NoInternetScreen(
            onRetry: () => ref.invalidate(connectivityProvider),
          );
        }
        return IndexedStack(
          index: _currentIndex,
          children: _screens,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allow body to extend behind the fab/bottom bar
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: _buildBody(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
        child: GlassContainer(
          height: 80,
          borderRadius: BorderRadius.circular(32),
          opacity: Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.9,
          color: Theme.of(context).brightness == Brightness.dark ? null : Colors.white,
          blur: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onNavItemTapped(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with unique-color glow + scale animation
                        AnimatedScale(
                          scale: isSelected ? 1.18 : 1.0,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? item.color.withOpacity(0.18)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? Border.all(
                                      color: item.color.withOpacity(0.4),
                                      width: 1.2)
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: item.color.withOpacity(0.35),
                                        blurRadius: 14,
                                        spreadRadius: 0,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected
                                  ? item.color
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white54
                                      : Colors.black45),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Label fades in when active
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isSelected ? 1.0 : 0.5,
                          child: Text(
                            item.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? item.color
                                      : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            maxLines: 1,
                          ),
                        ),
                        // Animated indicator dot
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(top: 2),
                          width: isSelected ? 14 : 0,
                          height: isSelected ? 3 : 0,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final Color color;

  NavItem(this.icon, this.label, this.color);
}
