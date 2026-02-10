import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSErrorState extends StatelessWidget {
  const DSErrorState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon ?? Icons.error_outline,
          size: spacing.s32,
          color: colors.danger,
        ),
        SizedBox(height: spacing.s12),
        Text(
          title,
          style: typography.h3.copyWith(color: colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing.s8),
        Text(
          message,
          style: typography.body.copyWith(color: colors.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: spacing.s16),
          DSButton(
            label: actionLabel!,
            variant: DSButtonVariant.secondary,
            onPressed: onAction,
          ),
        ],
      ],
    );
  }
}
