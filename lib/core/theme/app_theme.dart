import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// AppTheme defines a vibrant, premium design system with modern typography,
/// harmonious color palettes, and sleek light/dark mode styling.
/// Typography Rule:
/// - Space Grotesk: Big headings (Display, Headline)
/// - DM Sans: Section headings, medium text, labels (Title, Label)
/// - DM Mono: General/body text (Body)
class AppTheme {
  AppTheme._();

  // Curated Color Palette
  static const Color primaryLight = Color(0xFF4F46E5); // Vibrant Indigo
  static const Color primaryDark = Color(0xFF6366F1); // Soft Indigo
  static const Color secondaryLight = Color(0xFF0D9488); // Teal
  static const Color secondaryDark = Color(0xFF14B8A6); // Soft Teal
  static const Color accent = Color(0xFFF43F5E); // Rose

  // Neutral Tones
  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500

  static const Color bgDark = Color(0xFF0B0F19); // Deep Slate
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color textDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400

  // Spacing and Radius Tokens
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;

  static const EdgeInsets paddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24.0);

  static TextTheme _buildTextTheme(TextTheme base, Color color) {
    final spaceGrotesk = base.apply(
      fontFamily: 'SpaceGrotesk',
      bodyColor: color,
      displayColor: color,
    );
    final dmSans = base.apply(
      fontFamily: 'DMSans',
      bodyColor: color,
      displayColor: color,
    );
    final dmMono = base.apply(
      fontFamily: 'DMMono',
      bodyColor: color,
      displayColor: color,
    );

    return TextTheme(
      displayLarge: spaceGrotesk.displayLarge,
      displayMedium: spaceGrotesk.displayMedium,
      displaySmall: spaceGrotesk.displaySmall,
      headlineLarge: spaceGrotesk.headlineLarge,
      headlineMedium: spaceGrotesk.headlineMedium,
      headlineSmall: spaceGrotesk.headlineSmall,
      
      titleLarge: dmSans.titleLarge,
      titleMedium: dmSans.titleMedium,
      titleSmall: dmSans.titleSmall,
      labelLarge: dmSans.labelLarge,
      labelMedium: dmSans.labelMedium,
      labelSmall: dmSans.labelSmall,

      bodyLarge: dmMono.bodyLarge,
      bodyMedium: dmMono.bodyMedium,
      bodySmall: dmMono.bodySmall,
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _buildTextTheme(base.textTheme, textLight);

    return base.copyWith(
      scaffoldBackgroundColor: bgLight,
      primaryColor: primaryLight,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: secondaryLight,
        surface: surfaceLight,
        error: accent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textLight,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: textLight,
          fontSize: 22,
        ),
        iconTheme: const IconThemeData(color: textLight),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryLight.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondaryLight),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = _buildTextTheme(base.textTheme, textDark);

    return base.copyWith(
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryDark,
        surface: surfaceDark,
        error: accent,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textDark,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: textDark,
          fontSize: 22,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryDark.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondaryDark),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
