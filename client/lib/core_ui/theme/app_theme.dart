import 'package:flutter/material.dart';

import 'package:template/core_ui/tokens/ds_colors.dart';
import 'package:template/core_ui/tokens/ds_radius.dart';
import 'package:template/core_ui/tokens/ds_spacing.dart';
import 'package:template/core_ui/tokens/ds_typography.dart';

final ThemeData lightTheme = _buildTheme(
  _lightScheme(),
  textColor: DSColors.textPrimaryLight,
  secondaryTextColor: DSColors.textSecondaryLight,
);

final ThemeData darkTheme = _buildTheme(
  _darkScheme(),
  textColor: DSColors.textPrimaryDark,
  secondaryTextColor: DSColors.textSecondaryDark,
);

ThemeData _buildTheme(
  ColorScheme scheme, {
  required Color textColor,
  required Color secondaryTextColor,
}) {
  final textTheme = DSTypography.textTheme(textColor, secondaryTextColor);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      surfaceTintColor: scheme.surface,
      titleTextStyle: textTheme.titleLarge,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      contentPadding: DSSpacing.inputContent,
      errorStyle: DSTypography.caption.copyWith(color: scheme.error),
      labelStyle: textTheme.bodyMedium,
      hintStyle: textTheme.bodyMedium,
      prefixIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: DSRadius.all12,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: DSRadius.all12,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: DSRadius.all12,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: DSRadius.all12,
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: DSRadius.all12,
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: DSRadius.all12,
        borderSide: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.s16),
        shape: const RoundedRectangleBorder(borderRadius: DSRadius.all12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.s16),
        shape: const RoundedRectangleBorder(borderRadius: DSRadius.all12),
        side: BorderSide(color: scheme.outline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.s12),
        shape: const RoundedRectangleBorder(borderRadius: DSRadius.all12),
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: DSRadius.all12,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
  );
}

ColorScheme _lightScheme() {
  return const ColorScheme(
    brightness: Brightness.light,
    primary: DSColors.accent,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDBEAFE),
    onPrimaryContainer: DSColors.textPrimaryLight,
    secondary: Color(0xFF0EA5E9),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFDFF6FF),
    onSecondaryContainer: DSColors.textPrimaryLight,
    tertiary: Color(0xFF22C55E),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFDCFCE7),
    onTertiaryContainer: DSColors.textPrimaryLight,
    error: DSColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    surface: DSColors.backgroundLight,
    onSurface: DSColors.textPrimaryLight,
    surfaceContainerHighest: DSColors.surfaceLight,
    onSurfaceVariant: DSColors.textSecondaryLight,
    outline: DSColors.borderLight,
    outlineVariant: DSColors.borderLight,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: DSColors.textPrimaryLight,
    onInverseSurface: DSColors.surfaceLight,
    inversePrimary: DSColors.accentDark,
  );
}

ColorScheme _darkScheme() {
  return const ColorScheme(
    brightness: Brightness.dark,
    primary: DSColors.accentDark,
    onPrimary: Color(0xFF0B1220),
    primaryContainer: Color(0xFF1D4ED8),
    onPrimaryContainer: DSColors.textPrimaryDark,
    secondary: Color(0xFF38BDF8),
    onSecondary: Color(0xFF0B1220),
    secondaryContainer: Color(0xFF075985),
    onSecondaryContainer: DSColors.textPrimaryDark,
    tertiary: Color(0xFF4ADE80),
    onTertiary: Color(0xFF0B1220),
    tertiaryContainer: Color(0xFF166534),
    onTertiaryContainer: DSColors.textPrimaryDark,
    error: DSColors.error,
    onError: Color(0xFF0B1220),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: DSColors.textPrimaryDark,
    surface: DSColors.backgroundDark,
    onSurface: DSColors.textPrimaryDark,
    surfaceContainerHighest: DSColors.surfaceDark,
    onSurfaceVariant: DSColors.textSecondaryDark,
    outline: DSColors.borderDark,
    outlineVariant: DSColors.borderDark,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: DSColors.textPrimaryDark,
    onInverseSurface: DSColors.backgroundDark,
    inversePrimary: DSColors.accent,
  );
}
