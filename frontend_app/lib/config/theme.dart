import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color cyan = Color(0xFF00F0FF);
  static const Color violet = Color(0xFF7000FF);
  static const Color neonRed = Color(0xFFFF003C);
  
  // Uber-style Dark Theme Colors
  static const Color uberBlack = Color(0xFF000000);
  // Refined: Near-black surface for very subtle difference (was #161616)
  static const Color uberSurface = Color(0xFF080808); 
  static const Color uberSurfaceHighlight = Color(0xFF141414); // Slightly lighter for inputs
  static const Color uberTextPrimary = Color(0xFFFFFFFF);
  static const Color uberTextSecondary = Color(0xFFAFAFAF);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: violet,
      secondary: cyan,
      tertiary: neonRed,
      surface: lightSurface,
      surfaceContainerHighest: Color(0xFFE2E8F0),
      onSurface: lightTextPrimary,
      onSurfaceVariant: lightTextSecondary,
      background: lightBackground,
      onBackground: lightTextPrimary,
    ),

    // Typography
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: lightTextPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: lightTextPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: lightTextSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: lightTextSecondary,
      ),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: lightTextPrimary),
    ),
    
    cardTheme: CardThemeData(
      color: lightSurface.withOpacity(0.9),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: uberBlack,
    
    // Color Scheme - Uber Style
    colorScheme: const ColorScheme.dark(
      primary: cyan,
      secondary: violet,
      tertiary: neonRed,
      surface: uberSurface, // #080808
      surfaceContainerHighest: uberSurfaceHighlight, // #141414
      onSurface: uberTextPrimary,
      onSurfaceVariant: uberTextSecondary,
      primaryContainer: Color(0xFF1E1E1E),
      onPrimaryContainer: Colors.white,
      background: uberBlack,
      onBackground: uberTextPrimary,
    ),

    // Typography
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: uberTextPrimary,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: uberTextPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: uberTextPrimary,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: uberTextPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: uberTextPrimary.withOpacity(0.9),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: uberTextSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: uberTextSecondary.withOpacity(0.8),
      ),
    ),
    
    // Component Themes
    appBarTheme: const AppBarTheme(
      backgroundColor: uberBlack,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: uberTextPrimary),
    ),
    
    cardTheme: CardThemeData(
      color: uberSurface, // #080808
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.03)), // Ultra-subtle border
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: uberBlack,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
  );
}
