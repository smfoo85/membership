import 'package:flutter/material.dart';

/// "PassPocket" design system — dark-mode-first glassmorphism, iOS Wallet
/// inspired. Ported from the Stitch design spec: Electric Indigo primary,
/// Emerald Mint secondary, Electric Amber tertiary, on a deep obsidian
/// canvas. Barcodes/QR codes deliberately break the dark theme with a
/// solid white "display pod" for maximum scanner contrast.
class AppColors {
  AppColors._();

  static const canvas = Color(0xFF090A0F); // Level 0 background
  static const surface = Color(0xFF131620); // Level 1 — dock/floating controls
  static const cardSurface = Color(0xFF1E2333); // Level 2 — pass card neutral
  static const surfaceHigh = Color(0xFF262B3D);

  static const primary = Color(0xFF6366F1); // Electric Indigo
  static const secondary = Color(0xFF10B981); // Emerald Mint
  static const tertiary = Color(0xFFF59E0B); // Electric Amber
  static const accentSapphire = Color(0xFF38BDF8);

  static const onSurface = Color(0xFFE3E1E9);
  static const onSurfaceVariant = Color(0xFFC7C4D7);
  static const outline = Color(0xFF464554);

  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);

  static const codePodBackground = Colors.white;
  static const codePodForeground = Colors.black;
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Color(0xFF003824),
      tertiary: AppColors.tertiary,
      onTertiary: Color(0xFF472A00),
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      surfaceContainer: AppColors.cardSurface,
      surfaceContainerHigh: AppColors.surfaceHigh,
      outline: AppColors.outline,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
    );

    const inter = 'Inter';

    final textTheme = TextTheme(
      headlineLarge: const TextStyle(
        fontFamily: inter,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.025 * 32,
        height: 38 / 32,
        color: AppColors.onSurface,
      ),
      headlineMedium: const TextStyle(
        fontFamily: inter,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.02 * 24,
        height: 30 / 24,
        color: AppColors.onSurface,
      ),
      headlineSmall: const TextStyle(
        fontFamily: inter,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.015 * 20,
        height: 26 / 20,
        color: AppColors.onSurface,
      ),
      bodyLarge: const TextStyle(
        fontFamily: inter,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 24 / 17,
        color: AppColors.onSurface,
      ),
      bodyMedium: const TextStyle(
        fontFamily: inter,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 21 / 15,
        color: AppColors.onSurfaceVariant,
      ),
      bodySmall: const TextStyle(
        fontFamily: inter,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 18 / 13,
        color: AppColors.onSurfaceVariant,
      ),
      labelLarge: const TextStyle(
        fontFamily: inter,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01 * 14,
        color: AppColors.onSurface,
      ),
      labelMedium: const TextStyle(
        fontFamily: inter,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.02 * 12,
        color: AppColors.onSurfaceVariant,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: inter,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.onSurfaceVariant,
        textColor: AppColors.onSurface,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outline, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.outline,
        ),
      ),
    );
  }

  /// Monospace style for membership numbers / codes, per the design
  /// system's "Code & Credential Numbers" rule.
  static const TextStyle codeDisplay = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.08 * 14,
    color: AppColors.onSurface,
  );
}
