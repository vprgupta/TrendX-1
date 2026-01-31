import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../platform/view/platform_screen.dart';
import '../country/view/country_screen.dart';
import '../technology/view/technology_screen.dart';
import '../profile/view/profile_screen.dart';
import '../politics/view/politics_screen.dart';
import '../geopolitics/view/geopolitics_screen.dart';
import '../local_news/view/local_news_screen.dart';
import '../../screens/reels_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/ui/glass_container.dart';
import '../../config/theme.dart';
import '../../core/services/preferences_service.dart';

class MainNavigation extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  
  const MainNavigation({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with TickerProviderStateMixin {
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
      : ['platform', 'shorts', 'country', 'tech', 'profile'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allow body to extend behind the fab/bottom bar
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false, // We'll handle bottom padding manually
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
        child: GlassContainer(
          height: 80,
          borderRadius: BorderRadius.circular(32), // Kept at 32 as requested (was 24)
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
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.cyan.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20), // Pill shape for icon
                            border: isSelected ? Border.all(color: AppTheme.cyan.withOpacity(0.3), width: 1) : null,
                          ),
                          child: Icon(
                            item.icon,
                            // Keep icon color neutral but high contrast for premium feel
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? (isSelected ? Colors.white : Colors.white60)
                                : (isSelected ? Colors.black : Colors.black54),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isSelected ? 1.0 : 0.6,
                          child: Text(
                            item.label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.black,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
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
