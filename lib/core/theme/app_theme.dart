import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Brand Identity ---
  static const String appName = "Abay eQub";

  // --- Brand Colors (Abay Mix) ---
  // Blue: Represents the Abay River, Trust, and Stability
  static const Color primaryColor = Color(0xFF003366); // Dark Royal Blue
  static const Color primaryLight = Color(
    0xFF00509E,
  ); // Lighter Professional Blue

  // Gold: Represents the eQub (Wealth & Value)
  static const Color accentColor = Color(0xFFD4AF37); // Metallic Gold
  static const Color accentLight = Color(0xFFFFD700); // Bright Gold

  static const Color errorColor = Color(0xFFE53935);
  static const Color notificationRed = Color(0xFFEF4444);

  // --- Neutral Colors (Light Mode) ---
  static const Color bgLight = Color(
    0xFFF4F6F9,
  ); // Very light blue-grey (cleaner than pure white)
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(
    0xFF002147,
  ); // Very Dark Blue (Instead of harsh black)
  static const Color textSecondaryLight = Color(0xFF546E7A); // Blue-Grey

  // --- Neutral Colors (Dark Mode) ---
  static const Color bgDark = Color(0xFF05101A); // Deep Night Blue
  static const Color surfaceDark = Color(
    0xFF0A1929,
  ); // Slightly lighter dark blue
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // --- Gradients ---
  // The Signature Abay Gradient (Blue to Light Blue)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // The Wealth Gradient (Gold)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, Color(0xFFF4CF6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Helper for glass effects
  static LinearGradient glassGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: [
        (isDark ? Colors.white : Colors.white).withOpacity(0.12),
        (isDark ? Colors.white : Colors.white).withOpacity(0.04),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Helper to get correct surface color
  static Color surface(BuildContext context) =>
      Theme.of(context).cardTheme.color ?? Colors.white;

  // --- LIGHT THEME DEFINITION ---
  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceLight,
      background: bgLight,
      textPrimary: textPrimaryLight,
      textSecondary: textSecondaryLight,
    );
  }

  // --- DARK THEME DEFINITION ---
  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      primary: primaryLight, // Lighter blue for dark mode readability
      secondary: accentColor,
      surface: surfaceDark,
      background: bgDark,
      textPrimary: textPrimaryDark,
      textSecondary: textSecondaryDark,
    );
  }

  // --- THEME BUILDER ---
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color background,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: background,

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        error: errorColor,
      ),

      // Font Styles (Fixes "Unattractive Font" issues)
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),

      // App Bar (Abay Blue Header)
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? surface : primaryColor,
        foregroundColor: Colors.white, // White text on Blue header
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Cards (Clean White with Gold Hint)
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 4,
        shadowColor: primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          // Subtle border
          side: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
      ),

      // Buttons (Gold/Blue Actions)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // Royal Blue Buttons
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
          elevation: 4,
          shadowColor: primary.withOpacity(0.4),
        ),
      ),

      // Input Fields (Fixes "Unattractive Inputs")
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surface.withOpacity(0.5) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        // Default Border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade300,
          ),
        ),
        // Enabled Border (Idle)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade300,
          ),
        ),
        // Focused Border (Gold Highlight)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: secondary, width: 2), // Gold Focus
        ),
        // Error Border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.5)),
      ),

      // Bottom Nav Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary, // Blue for selected
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: secondary, // Gold loaders
        circularTrackColor: primary.withOpacity(0.1),
        refreshBackgroundColor: surface,
      ),

      // Snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceDark : primaryColor,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }

  // --- Typography Helpers ---
  static TextStyle get caption => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  static TextStyle get headline =>
      GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold);
}
