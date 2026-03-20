import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  String _activeTheme = 'system';
  String get activeTheme => _activeTheme;

  ThemeMode get themeMode {
    if (_activeTheme == 'light' || _activeTheme == 'lavender') return ThemeMode.light;
    if (_activeTheme == 'system') return ThemeMode.system;
    return ThemeMode.dark;
  }

  bool get isDarkMode {
    if (_activeTheme == 'system') {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  ThemeData get lightTheme {
    if (_activeTheme == 'lavender') return AppTheme.lavenderTheme;
    return AppTheme.lightTheme;
  }

  ThemeData get darkTheme {
    if (_activeTheme == 'ocean') return AppTheme.oceanTheme;
    if (_activeTheme == 'cyberpunk') return AppTheme.cyberpunkTheme;
    if (_activeTheme == 'forest') return AppTheme.forestTheme;
    return AppTheme.darkTheme; // Default uber-style
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('activeTheme');
    
    if (savedTheme != null) {
      _activeTheme = savedTheme;
    } else {
      // Legacy migration
      final isDark = prefs.getBool('isDarkMode');
      if (isDark != null) {
        _activeTheme = isDark ? 'dark' : 'light';
      }
    }
    notifyListeners();
  }

  Future<void> setTheme(String themeId) async {
    _activeTheme = themeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeTheme', _activeTheme);
    notifyListeners();
  }

  // Legacy toggle used by AuthWrapper
  Future<void> toggleTheme() async {
    if (_activeTheme == 'light' || _activeTheme == 'lavender') {
      await setTheme('dark');
    } else {
      await setTheme('light');
    }
  }
}
