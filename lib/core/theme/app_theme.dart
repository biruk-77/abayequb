import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─────────────────────────────────────────────────────────
  //  THE ROYAL PALETTE (Blue, White & Gold)
  // ─────────────────────────────────────────────────────────

  // BRAND STRINGS (Restored)
  static const String appName = "Abay eQub";

  // PRIMARY: The "Abay" Identity
  static const Color primaryColor = Color(0xFF003366); // Deep Royal Blue
  static const Color primaryLight = Color(0xFF00509E); // Vibrant Deep Teal

  // ACCENT: The "Wealth" Identity
  static const Color accentColor = Color(0xFFD4AF37); // Gold Bullion
  static const Color accentLight = Color(0xFFF4CF6E); // Gold Dust (Highlight)

  // NEUTRALS: High-End Backgrounds
  static const Color bgLight = Color(0xFFF8FAFC); // Platinum White
  static const Color surfaceLight = Colors.white;

  static const Color bgDark = Color(0xFF020617); // Obsidian (Pitch Black/Blue)
  static const Color surfaceDark = Color(0xFF0F172A); // Midnight Blue

  // TEXT COLORS
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400

  // FUNCTIONAL
  static const Color errorColor = Color(0xFFDC2626); // Ruby Red
  static const Color successColor = Color(0xFF059669); // Emerald Green
  static const Color notificationRed = Color(0xFFEF4444);

  // ─────────────────────────────────────────────────────────
  //  GRADIENTS
  // ─────────────────────────────────────────────────────────

  // The Main "Royal" Gradient
  static const LinearGradient royalGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // BACKWARD COMPATIBILITY (Fixes the errors in Login/Register screens)
  static const LinearGradient primaryGradient = royalGradient;

  static const LinearGradient goldGradient = LinearGradient(
    colors: [accentColor, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Helper for glass effects (restored for compatibility)
  static LinearGradient glassGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: [
        (isDark ? Colors.white : Colors.white).withValues(alpha: 0.12),
        (isDark ? Colors.white : Colors.white).withValues(alpha: 0.04),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Helper to get correct surface color
  static Color surface(BuildContext context) =>
      Theme.of(context).cardTheme.color ?? Colors.white;

  // ─────────────────────────────────────────────────────────
  //  LIGHT THEME
  // ─────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────
  //  DARK THEME
  // ─────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────
  //  THEME BUILDER ENGINE
  // ─────────────────────────────────────────────────────────
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

      // 1. Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        surface: surface,
        onSurface: textPrimary,
        error: errorColor,
      ),

      // 2. Typography (Outfit Font - Modern & Clean)
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),

      // 3. AppBar (Royal Blue Header)
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? surface : primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.0,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // 4. Cards (Clean with subtle borders)
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 8,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
            width: 1,
          ),
        ),
      ),

      // 5. Buttons (Gold/Blue Actions)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
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
          shadowColor: primary.withValues(alpha: 0.4),
        ),
      ),

      // 6. Input Fields (Glassy feel)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        // Idle Border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
        // Focused Border (Gold Highlight)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: secondary, width: 2),
        ),
        // Error Border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
        prefixIconColor: primary,
      ),

      // 7. Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: secondary, // Gold for selected tab
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),

      // 8. Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: secondary, // Gold loaders
        circularTrackColor: primary.withValues(alpha: 0.1),
        refreshBackgroundColor: surface,
      ),

      // 9. Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: primary,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // 10. Snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceDark : primaryColor,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  TYPOGRAPHY HELPERS
  // ─────────────────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  static TextStyle get headline =>
      GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold);
}
