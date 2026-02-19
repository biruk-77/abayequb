import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Brand Identity ---
  static const String appName = "Abay eQub";

  // --- Colors (Abay Premium Teal) ---
  static const Color primaryColor = Color(0xFF0D4348); // Deep Dark Teal
  static const Color primaryLight = Color(0xFF135A5E); // Professional Teal
  static const Color accentColor = Color(0xFFD4AF37); // Royal Gold (Premium)
  static const Color errorColor = Color(0xFFE53935);

  // Neutral Colors - Light Mode
  static const Color bgLight = Color(0xFFF9F9F9); // Styled Off-White
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Neutral Colors - Dark Mode
  static const Color bgDark = Color(0xFF020617); // Ultra Deep Dark (Midnight)
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static const Color notificationRed = Color(0xFFEF4444);
  static Color surface(BuildContext context) =>
      Theme.of(context).cardTheme.color ?? Colors.white;

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient glassGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: [
        (isDark ? Colors.white : Colors.white).withOpacity(0.15),
        (isDark ? Colors.white : Colors.white).withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      primary: primaryColor,
      surface: surfaceLight,
      background: bgLight,
      textPrimary: textPrimaryLight,
      textSecondary: textSecondaryLight,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      primary: primaryLight,
      surface: surfaceDark,
      background: bgDark,
      textPrimary: textPrimaryDark,
      textSecondary: textSecondaryDark,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
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
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primary,
        secondary: accentColor,
        surface: surface,
        error: errorColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? surface : primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 8,
        shadowColor: primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
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
            letterSpacing: 0.5,
          ),
          elevation: 2,
          shadowColor: primary.withOpacity(0.4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surface.withOpacity(0.1) : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.5)),
        contentPadding: const EdgeInsets.all(20),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceDark : primaryColor,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 10,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accentColor,
        circularTrackColor: primary.withOpacity(0.2),
        refreshBackgroundColor: surface,
      ),
    );
  }

  // --- Typography Helpers for Components ---
  static TextStyle get caption => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  static TextStyle get headline =>
      GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold);
}
