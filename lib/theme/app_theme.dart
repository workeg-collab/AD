import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Comprehensive Unified Design System for Saudi Market Landing Page
/// Follows Premium Commercial Saudi Visual Guidelines:
/// - Trustworthy, Corporate, Modern, High-Legibility
/// - Deep Saudi Emerald Green, Charcoal Slate, Crisp Warm Whites
/// - Standardized Spacing, Radius, and Shadow Scales
class AppTheme {
  // Brand Palette - Premium Saudi Commercial
  static const Color primary = Color(0xFF0D5E42); // Deep Prestige Saudi Green
  static const Color primaryLight = Color(0xFF147A58); // Interactive hover green
  static const Color primaryDark = Color(0xFF083C2A); // Deep contrast green
  static const Color primaryContainer = Color(0xFFE8F5F0); // Subtle soft green surface
  static const Color primaryContainerDark = Color(0xFF122820);

  // Secondary & Accents
  static const Color secondary = Color(0xFF1E293B); // Refined Slate Charcoal
  static const Color accentGold = Color(0xFFB4833E); // Restrained 24K Warm Gold Accent
  static const Color accentGoldLight = Color(0xFFFDF7EE);
  static const Color accentGoldDark = Color(0xFF261D0F);

  // Status & Functional
  static const Color success = Color(0xFF0D9488);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color whatsappGreen = Color(0xFF25D366);

  // Light Theme Tokens
  static const Color bgLight = Color(0xFFFAFAF9); // Warm, clean off-white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderSubtleLight = Color(0xFFF3F4F6);
  static const Color textDark = Color(0xFF0F172A); // High-contrast Charcoal
  static const Color textMuted = Color(0xFF64748B); // Slate gray
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Dark Theme Tokens
  static const Color bgDark = Color(0xFF0B110F); // Deep slate with subtle emerald tone
  static const Color surfaceDark = Color(0xFF121B18);
  static const Color cardDark = Color(0xFF17221F);
  static const Color borderDark = Color(0xFF243530);
  static const Color borderSubtleDark = Color(0xFF1B2824);
  static const Color textWhite = Color(0xFFF8FAFC);
  static const Color textMutedDark = Color(0xFF94A3B8);

  // Standardized Border Radii Scale
  static const double radiusSmVal = 8.0;
  static const double radiusMdVal = 12.0;
  static const double radiusLgVal = 16.0;
  static const double radiusXlVal = 24.0;
  static const double radiusFullVal = 999.0;

  static final BorderRadius radiusSm = BorderRadius.circular(radiusSmVal);
  static final BorderRadius radiusMd = BorderRadius.circular(radiusMdVal);
  static final BorderRadius radiusLg = BorderRadius.circular(radiusLgVal);
  static final BorderRadius radiusXl = BorderRadius.circular(radiusXlVal);
  static final BorderRadius radiusFull = BorderRadius.circular(radiusFullVal);

  // Standardized Shadows
  static List<BoxShadow> softShadow({bool isDark = false, double elevation = 1}) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25 * elevation),
          blurRadius: 10 * elevation,
          offset: Offset(0, 3 * elevation),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.035 * elevation),
        blurRadius: 8 * elevation,
        spreadRadius: 0,
        offset: Offset(0, 2 * elevation),
      ),
      BoxShadow(
        color: const Color(0xFF0D5E42).withValues(alpha: 0.025 * elevation),
        blurRadius: 16 * elevation,
        spreadRadius: 0,
        offset: Offset(0, 4 * elevation),
      ),
    ];
  }

  // Standard Button Theme Helpers
  static ButtonStyle primaryButtonStyle({bool isMobile = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: radiusMd),
      textStyle: GoogleFonts.ibmPlexSansArabic(
        fontSize: isMobile ? 13.5 : 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }

  static ButtonStyle secondaryButtonStyle({bool isDark = false, bool isMobile = false}) {
    return OutlinedButton.styleFrom(
      foregroundColor: isDark ? textWhite : textDark,
      backgroundColor: Colors.transparent,
      side: BorderSide(
        color: isDark ? borderDark : borderLight,
        width: 1.2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 22,
        vertical: isMobile ? 12 : 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: radiusMd),
      textStyle: GoogleFonts.ibmPlexSansArabic(
        fontSize: isMobile ? 13 : 14.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    final arabicTextTheme = GoogleFonts.ibmPlexSansArabicTextTheme(baseTextTheme);

    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: bgLight,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        surface: surfaceLight,
        error: error,
      ),
      textTheme: arabicTextTheme.apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusLg,
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle(),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: secondaryButtonStyle(isDark: false),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: radiusXl,
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    final arabicTextTheme = GoogleFonts.ibmPlexSansArabicTextTheme(baseTextTheme);

    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryLight,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        primaryContainer: primaryContainerDark,
        secondary: secondary,
        surface: surfaceDark,
        error: error,
      ),
      textTheme: arabicTextTheme.apply(
        bodyColor: textWhite,
        displayColor: textWhite,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusLg,
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle(),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: secondaryButtonStyle(isDark: true),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: radiusXl,
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
    );
  }
}
