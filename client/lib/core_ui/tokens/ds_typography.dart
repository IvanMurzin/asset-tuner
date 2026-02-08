import 'package:flutter/material.dart';

final class DSTypography {
  DSTypography._();

  static const TextStyle display = TextStyle(
    fontSize: 36,
    height: 1.12,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w400,
  );

  static TextTheme textTheme(Color textColor, Color secondaryTextColor) {
    return TextTheme(
      displayLarge: display.copyWith(color: textColor),
      headlineMedium: headline.copyWith(color: textColor),
      titleLarge: title.copyWith(color: textColor),
      bodyLarge: body.copyWith(color: textColor),
      labelLarge: label.copyWith(color: textColor),
      bodyMedium: body.copyWith(color: secondaryTextColor),
      bodySmall: caption.copyWith(color: secondaryTextColor),
      labelMedium: label.copyWith(color: secondaryTextColor),
    );
  }
}
