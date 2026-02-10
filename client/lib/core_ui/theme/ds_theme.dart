import 'dart:ui';

import 'package:flutter/material.dart';

class DSColors extends ThemeExtension<DSColors> {
  const DSColors({
    required this.primary,
    required this.primaryHover,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnPrimary,
    required this.border,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.neutral0,
    required this.neutral50,
    required this.neutral100,
    required this.neutral200,
    required this.neutral300,
    required this.neutral400,
    required this.neutral500,
    required this.neutral600,
    required this.neutral700,
    required this.neutral900,
    required this.neutral950,
  });

  final Color primary;
  final Color primaryHover;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnPrimary;
  final Color border;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color neutral0;
  final Color neutral50;
  final Color neutral100;
  final Color neutral200;
  final Color neutral300;
  final Color neutral400;
  final Color neutral500;
  final Color neutral600;
  final Color neutral700;
  final Color neutral900;
  final Color neutral950;

  @override
  DSColors copyWith({
    Color? primary,
    Color? primaryHover,
    Color? onPrimary,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnPrimary,
    Color? border,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? neutral0,
    Color? neutral50,
    Color? neutral100,
    Color? neutral200,
    Color? neutral300,
    Color? neutral400,
    Color? neutral500,
    Color? neutral600,
    Color? neutral700,
    Color? neutral900,
    Color? neutral950,
  }) {
    return DSColors(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      onPrimary: onPrimary ?? this.onPrimary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      neutral0: neutral0 ?? this.neutral0,
      neutral50: neutral50 ?? this.neutral50,
      neutral100: neutral100 ?? this.neutral100,
      neutral200: neutral200 ?? this.neutral200,
      neutral300: neutral300 ?? this.neutral300,
      neutral400: neutral400 ?? this.neutral400,
      neutral500: neutral500 ?? this.neutral500,
      neutral600: neutral600 ?? this.neutral600,
      neutral700: neutral700 ?? this.neutral700,
      neutral900: neutral900 ?? this.neutral900,
      neutral950: neutral950 ?? this.neutral950,
    );
  }

  @override
  DSColors lerp(ThemeExtension<DSColors>? other, double t) {
    if (other is! DSColors) {
      return this;
    }

    return DSColors(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryHover:
          Color.lerp(primaryHover, other.primaryHover, t) ?? primaryHover,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t) ?? surfaceAlt,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textTertiary:
          Color.lerp(textTertiary, other.textTertiary, t) ?? textTertiary,
      textOnPrimary:
          Color.lerp(textOnPrimary, other.textOnPrimary, t) ?? textOnPrimary,
      border: Color.lerp(border, other.border, t) ?? border,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      info: Color.lerp(info, other.info, t) ?? info,
      neutral0: Color.lerp(neutral0, other.neutral0, t) ?? neutral0,
      neutral50: Color.lerp(neutral50, other.neutral50, t) ?? neutral50,
      neutral100: Color.lerp(neutral100, other.neutral100, t) ?? neutral100,
      neutral200: Color.lerp(neutral200, other.neutral200, t) ?? neutral200,
      neutral300: Color.lerp(neutral300, other.neutral300, t) ?? neutral300,
      neutral400: Color.lerp(neutral400, other.neutral400, t) ?? neutral400,
      neutral500: Color.lerp(neutral500, other.neutral500, t) ?? neutral500,
      neutral600: Color.lerp(neutral600, other.neutral600, t) ?? neutral600,
      neutral700: Color.lerp(neutral700, other.neutral700, t) ?? neutral700,
      neutral900: Color.lerp(neutral900, other.neutral900, t) ?? neutral900,
      neutral950: Color.lerp(neutral950, other.neutral950, t) ?? neutral950,
    );
  }
}

class DSSpacing extends ThemeExtension<DSSpacing> {
  const DSSpacing({
    required this.s4,
    required this.s8,
    required this.s12,
    required this.s16,
    required this.s24,
    required this.s32,
  });

  final double s4;
  final double s8;
  final double s12;
  final double s16;
  final double s24;
  final double s32;

  @override
  DSSpacing copyWith({
    double? s4,
    double? s8,
    double? s12,
    double? s16,
    double? s24,
    double? s32,
  }) {
    return DSSpacing(
      s4: s4 ?? this.s4,
      s8: s8 ?? this.s8,
      s12: s12 ?? this.s12,
      s16: s16 ?? this.s16,
      s24: s24 ?? this.s24,
      s32: s32 ?? this.s32,
    );
  }

  @override
  DSSpacing lerp(ThemeExtension<DSSpacing>? other, double t) {
    if (other is! DSSpacing) {
      return this;
    }

    return DSSpacing(
      s4: lerpDouble(s4, other.s4, t) ?? s4,
      s8: lerpDouble(s8, other.s8, t) ?? s8,
      s12: lerpDouble(s12, other.s12, t) ?? s12,
      s16: lerpDouble(s16, other.s16, t) ?? s16,
      s24: lerpDouble(s24, other.s24, t) ?? s24,
      s32: lerpDouble(s32, other.s32, t) ?? s32,
    );
  }
}

class DSRadius extends ThemeExtension<DSRadius> {
  const DSRadius({required this.r8, required this.r12, required this.r16});

  final double r8;
  final double r12;
  final double r16;

  @override
  DSRadius copyWith({double? r8, double? r12, double? r16}) {
    return DSRadius(
      r8: r8 ?? this.r8,
      r12: r12 ?? this.r12,
      r16: r16 ?? this.r16,
    );
  }

  @override
  DSRadius lerp(ThemeExtension<DSRadius>? other, double t) {
    if (other is! DSRadius) {
      return this;
    }

    return DSRadius(
      r8: lerpDouble(r8, other.r8, t) ?? r8,
      r12: lerpDouble(r12, other.r12, t) ?? r12,
      r16: lerpDouble(r16, other.r16, t) ?? r16,
    );
  }
}

class DSElevation extends ThemeExtension<DSElevation> {
  const DSElevation({required this.e0, required this.e1, required this.e2});

  final List<BoxShadow> e0;
  final List<BoxShadow> e1;
  final List<BoxShadow> e2;

  @override
  DSElevation copyWith({
    List<BoxShadow>? e0,
    List<BoxShadow>? e1,
    List<BoxShadow>? e2,
  }) {
    return DSElevation(e0: e0 ?? this.e0, e1: e1 ?? this.e1, e2: e2 ?? this.e2);
  }

  @override
  DSElevation lerp(ThemeExtension<DSElevation>? other, double t) {
    if (other is! DSElevation) {
      return this;
    }

    return DSElevation(
      e0: BoxShadow.lerpList(e0, other.e0, t) ?? e0,
      e1: BoxShadow.lerpList(e1, other.e1, t) ?? e1,
      e2: BoxShadow.lerpList(e2, other.e2, t) ?? e2,
    );
  }
}

class DSTypography extends ThemeExtension<DSTypography> {
  const DSTypography({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.body,
    required this.caption,
    required this.button,
    required this.label,
    required this.totalNumeric,
  });

  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle body;
  final TextStyle caption;
  final TextStyle button;
  final TextStyle label;
  final TextStyle totalNumeric;

  static DSTypography fromColors(DSColors colors) {
    return DSTypography(
      h1: TextStyle(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      h2: TextStyle(
        fontSize: 20,
        height: 26 / 20,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      h3: TextStyle(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      body: TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
      ),
      caption: TextStyle(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      button: TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      label: TextStyle(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      totalNumeric: TextStyle(
        fontSize: 34,
        height: 40 / 34,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  TextTheme toTextTheme() {
    return TextTheme(
      displaySmall: h1,
      titleLarge: h2,
      titleMedium: h3,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: button,
      labelMedium: label,
    );
  }

  @override
  DSTypography copyWith({
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? body,
    TextStyle? caption,
    TextStyle? button,
    TextStyle? label,
    TextStyle? totalNumeric,
  }) {
    return DSTypography(
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      body: body ?? this.body,
      caption: caption ?? this.caption,
      button: button ?? this.button,
      label: label ?? this.label,
      totalNumeric: totalNumeric ?? this.totalNumeric,
    );
  }

  @override
  DSTypography lerp(ThemeExtension<DSTypography>? other, double t) {
    if (other is! DSTypography) {
      return this;
    }

    return DSTypography(
      h1: TextStyle.lerp(h1, other.h1, t) ?? h1,
      h2: TextStyle.lerp(h2, other.h2, t) ?? h2,
      h3: TextStyle.lerp(h3, other.h3, t) ?? h3,
      body: TextStyle.lerp(body, other.body, t) ?? body,
      caption: TextStyle.lerp(caption, other.caption, t) ?? caption,
      button: TextStyle.lerp(button, other.button, t) ?? button,
      label: TextStyle.lerp(label, other.label, t) ?? label,
      totalNumeric:
          TextStyle.lerp(totalNumeric, other.totalNumeric, t) ?? totalNumeric,
    );
  }
}

extension DSTokens on BuildContext {
  DSColors get dsColors => Theme.of(this).extension<DSColors>()!;
  DSSpacing get dsSpacing => Theme.of(this).extension<DSSpacing>()!;
  DSRadius get dsRadius => Theme.of(this).extension<DSRadius>()!;
  DSElevation get dsElevation => Theme.of(this).extension<DSElevation>()!;
  DSTypography get dsTypography => Theme.of(this).extension<DSTypography>()!;
}
