import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSEmptyCard extends StatelessWidget {
  const DSEmptyCard({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.icon,
    this.actionLeadingIcon,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData? icon;
  final IconData? actionLeadingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.s24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius.r16),
        border: Border.all(color: colors.border.withValues(alpha: 0.7)),
        boxShadow: context.dsElevation.e1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: spacing.s32, color: colors.textSecondary),
            SizedBox(height: spacing.s12),
          ],
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
          SizedBox(height: spacing.s24),
          DSButton(
            label: actionLabel,
            leadingIcon: actionLeadingIcon,
            fullWidth: true,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}
