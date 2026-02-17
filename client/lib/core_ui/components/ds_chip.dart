import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSChip extends StatelessWidget {
  const DSChip({super.key, required this.label, this.onTap, this.icon});

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    return Material(
      color: colors.surfaceAlt,
      borderRadius: BorderRadius.circular(radius.r16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.r16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s12, vertical: spacing.s8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: spacing.s16, color: colors.textSecondary),
                SizedBox(width: spacing.s8),
              ],
              Text(
                label,
                style: typography.caption.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
