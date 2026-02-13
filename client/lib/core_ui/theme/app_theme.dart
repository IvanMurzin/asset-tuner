import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

const DSSpacing _spacing = DSSpacing(
  s4: 4,
  s8: 8,
  s12: 12,
  s16: 16,
  s24: 24,
  s32: 32,
);

const DSRadius _radius = DSRadius(r8: 8, r12: 12, r16: 16);

const DSElevation _elevation = DSElevation(
  e0: [],
  e1: [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -4,
    ),
  ],
  e2: [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.14),
      offset: Offset(0, 10),
      blurRadius: 24,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.12),
      offset: Offset(0, 4),
      blurRadius: 10,
      spreadRadius: -4,
    ),
  ],
);

const DSColors _lightColors = DSColors(
  primary: Color(0xFF2563EB),
  primaryHover: Color(0xFF1D4ED8),
  onPrimary: Color(0xFFFFFFFF),
  background: Color(0xFFF6F8FB),
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFEEF2F7),
  textPrimary: Color(0xFF0B1220),
  textSecondary: Color(0xFF5B6B82),
  textTertiary: Color(0xFF8EA0B8),
  textOnPrimary: Color(0xFFFFFFFF),
  border: Color(0xFFD9E1EC),
  success: Color(0xFF0E9F6E),
  warning: Color(0xFFF59E0B),
  danger: Color(0xFFE11D48),
  info: Color(0xFF38BDF8),
  neutral0: Color(0xFFFFFFFF),
  neutral50: Color(0xFFF6F8FB),
  neutral100: Color(0xFFEEF2F7),
  neutral200: Color(0xFFD9E1EC),
  neutral300: Color(0xFFC2CDDA),
  neutral400: Color(0xFF8EA0B8),
  neutral500: Color(0xFF5B6B82),
  neutral600: Color(0xFF3D4B63),
  neutral700: Color(0xFF25324A),
  neutral900: Color(0xFF0B1220),
  neutral950: Color(0xFF070C16),
);

const DSColors _darkColors = DSColors(
  primary: Color(0xFF2563EB),
  primaryHover: Color(0xFF1D4ED8),
  onPrimary: Color(0xFFFFFFFF),
  background: Color(0xFF070C16),
  surface: Color(0xFF0B1220),
  surfaceAlt: Color(0xFF25324A),
  textPrimary: Color(0xFFF6F8FB),
  textSecondary: Color(0xFFC2CDDA),
  textTertiary: Color(0xFF8EA0B8),
  textOnPrimary: Color(0xFFFFFFFF),
  border: Color(0xFF25324A),
  success: Color(0xFF0E9F6E),
  warning: Color(0xFFF59E0B),
  danger: Color(0xFFE11D48),
  info: Color(0xFF38BDF8),
  neutral0: Color(0xFFFFFFFF),
  neutral50: Color(0xFFF6F8FB),
  neutral100: Color(0xFFEEF2F7),
  neutral200: Color(0xFFD9E1EC),
  neutral300: Color(0xFFC2CDDA),
  neutral400: Color(0xFF8EA0B8),
  neutral500: Color(0xFF5B6B82),
  neutral600: Color(0xFF3D4B63),
  neutral700: Color(0xFF25324A),
  neutral900: Color(0xFF0B1220),
  neutral950: Color(0xFF070C16),
);

final ThemeData lightTheme = _buildTheme(_lightColors, Brightness.light);
final ThemeData darkTheme = _buildTheme(_darkColors, Brightness.dark);

ThemeData _buildTheme(DSColors colors, Brightness brightness) {
  final typography = DSTypography.fromColors(colors);

  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryHover,
      onPrimaryContainer: colors.onPrimary,
      secondary: colors.info,
      onSecondary: colors.onPrimary,
      secondaryContainer: colors.surfaceAlt,
      onSecondaryContainer: colors.textPrimary,
      tertiary: colors.success,
      onTertiary: colors.onPrimary,
      tertiaryContainer: colors.success,
      onTertiaryContainer: colors.onPrimary,
      error: colors.danger,
      onError: colors.onPrimary,
      errorContainer: colors.danger,
      onErrorContainer: colors.onPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.surfaceAlt,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.border,
      outlineVariant: colors.border,
      shadow: colors.neutral950,
      scrim: colors.neutral950,
      inverseSurface: colors.textPrimary,
      onInverseSurface: colors.surface,
      inversePrimary: colors.primary,
      surfaceTint: colors.primary,
    ),
    scaffoldBackgroundColor: colors.background,
    textTheme: typography.toTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      titleTextStyle: typography.h2.copyWith(color: colors.textPrimary),
      iconTheme: IconThemeData(color: colors.textPrimary),
    ),
    dividerTheme: DividerThemeData(
      color: colors.border,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius.r12),
      ),
      titleTextStyle: typography.h2.copyWith(color: colors.textPrimary),
      contentTextStyle: typography.body.copyWith(color: colors.textSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: _spacing.s16,
        vertical: _spacing.s12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius.r12),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius.r12),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius.r12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius.r12),
        borderSide: BorderSide(color: colors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius.r12),
        borderSide: BorderSide(color: colors.danger, width: 1.5),
      ),
      hintStyle: typography.body.copyWith(color: colors.textTertiary),
      labelStyle: typography.body.copyWith(color: colors.textSecondary),
      errorStyle: typography.caption.copyWith(color: colors.danger),
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius.r12),
      ),
    ),
    extensions: [colors, _spacing, _radius, _elevation, typography],
  );
}
