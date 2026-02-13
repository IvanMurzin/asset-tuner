import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

enum DSSnackBarVariant { success, error, info }

void showDSSnackBar(
  BuildContext context, {
  required DSSnackBarVariant variant,
  required String message,
  Duration duration = const Duration(seconds: 4),
}) {
  final colors = context.dsColors;
  final spacing = context.dsSpacing;
  final typography = context.dsTypography;
  final radius = context.dsRadius;

  final backgroundColor = switch (variant) {
    DSSnackBarVariant.success => colors.success,
    DSSnackBarVariant.error => colors.danger,
    DSSnackBarVariant.info => colors.textPrimary,
  };
  const contentColor = Color(0xFFFFFFFF);

  final icon = switch (variant) {
    DSSnackBarVariant.success => Icons.check_circle_outline,
    DSSnackBarVariant.error => Icons.error_outline,
    DSSnackBarVariant.info => Icons.info_outline,
  };

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: contentColor, size: 22),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Text(
              message,
              style: typography.body.copyWith(color: contentColor),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(spacing.s16, spacing.s8, spacing.s16, spacing.s24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.r12),
      ),
      duration: duration,
    ),
  );
}
