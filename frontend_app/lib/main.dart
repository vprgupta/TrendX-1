import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'features/auth/view/auth_wrapper.dart';
import 'core/services/saved_trends_service.dart';
import 'core/services/theme_service.dart';
import 'core/di/service_locator.dart'; // Import DI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator(); // Initialize DI
  await SavedTrendsService().loadSavedTrends();
  runApp(const ProviderScope(child: MyApp())); // Wrap with ProviderScope
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // We can eventually move this too, but keeping minimal changes first
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
    _loadServices();
  }

  Future<void> _loadServices() async {
    await _themeService.loadTheme();
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrendX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeService.themeMode,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _themeService.isDarkMode
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
        child: AuthWrapper(
          onThemeToggle: _themeService.toggleTheme,
          isDarkMode: _themeService.isDarkMode,
        ),
      ),
    );
  }
}