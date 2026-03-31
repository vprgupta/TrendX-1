import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'config/theme.dart';
import 'config/environment.dart';
import 'features/auth/view/auth_wrapper.dart';
import 'core/services/saved_trends_service.dart';
import 'core/services/theme_service.dart';
import 'core/di/service_locator.dart'; // Import DI
import 'core/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (wrapped in try-catch to allow app startup even if config is missing)
  try {
    await Firebase.initializeApp();
    
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed or config missing: $e');
    debugPrint('App will continue running without Crashlytics/Analytics.');
  }
  
  // Initialize environment configuration
  const envName = String.fromEnvironment('ENV', defaultValue: 'development');
  if (envName == 'production') {
    EnvironmentConfig.setEnvironment(Environment.production);
  } else if (envName == 'staging') {
    EnvironmentConfig.setEnvironment(Environment.staging);
  }
  
  setupLocator(); // Initialize DI

  // Version-based cache flush: clears stale news cache when app backend routing changes.
  // Bump this version string whenever a backend routing fix is deployed.
  const cacheVersion = 'v4_regional_routing';
  final prefs = await SharedPreferences.getInstance();
  final storedVersion = prefs.getString('news_cache_version');
  if (storedVersion != cacheVersion) {
    await CacheService.clearCache();
    await prefs.setString('news_cache_version', cacheVersion);
    debugPrint('🗑️ Cleared stale news cache (version upgrade: $storedVersion → $cacheVersion)');
  }

  await getIt<SavedTrendsService>().loadSavedTrends();
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
      theme: _themeService.lightTheme,
      darkTheme: _themeService.darkTheme,
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