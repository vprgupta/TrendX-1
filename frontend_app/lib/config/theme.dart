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

  // --- NEW THEMES ---

  static ThemeData get oceanTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF040B16), // Deep Navy
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00FFD1), // Neon Cyan
      secondary: Color(0xFF3B82F6), // Blue
      tertiary: Color(0xFF8B5CF6), // Purple
      surface: Color(0xFF0A1526), // Dark Blue Surface
      surfaceContainerHighest: Color(0xFF13233F),
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFF94A3B8),
      background: Color(0xFF040B16),
      onBackground: Colors.white,
    ),
    textTheme: lightTheme.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF040B16),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );

  static ThemeData get cyberpunkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0221), // Very dark purple
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF00E6), // Hot Pink
      secondary: Color(0xFF00FFFF), // Cyan
      tertiary: Color(0xFFFDEB71), // Yellow
      surface: Color(0xFF1A0B2E),
      surfaceContainerHighest: Color(0xFF2D1B4E),
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFFAAA3B0),
      background: Color(0xFF0D0221),
      onBackground: Colors.white,
    ),
    textTheme: lightTheme.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D0221),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );

  static ThemeData get forestTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0B1410), // Very dark green
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF10B981), // Emerald
      secondary: Color(0xFFD4AF37), // Gold
      tertiary: Color(0xFFF59E0B), // Amber
      surface: Color(0xFF13211A), // Dark leaf
      surfaceContainerHighest: Color(0xFF1D3529),
      onSurface: Color(0xFFECFDF5),
      onSurfaceVariant: Color(0xFFA7F3D0),
      background: Color(0xFF0B1410),
      onBackground: Color(0xFFECFDF5),
    ),
    textTheme: lightTheme.textTheme.apply(
      bodyColor: const Color(0xFFECFDF5),
      displayColor: const Color(0xFFECFDF5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0B1410),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFECFDF5)),
    ),
  );

  static ThemeData get lavenderTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFDFBFE), // Very light purple tint
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8B5CF6), // Soft Purple
      secondary: Color(0xFFEC4899), // Pink
      tertiary: Color(0xFF6366F1), // Indigo
      surface: Colors.white,
      surfaceContainerHighest: Color(0xFFF3E8FF), // Light purple background for cards
      onSurface: Color(0xFF1E1B4B),
      onSurfaceVariant: Color(0xFF4C1D95),
      background: Color(0xFFFDFBFE),
      onBackground: Color(0xFF1E1B4B),
    ),
    textTheme: lightTheme.textTheme.apply(
      bodyColor: const Color(0xFF1E1B4B),
      displayColor: const Color(0xFF1E1B4B),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFDFBFE),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1E1B4B)),
    ),
  );
}
