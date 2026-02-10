import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSDialog extends StatelessWidget {
  const DSDialog({
    super.key,
    required this.title,
    this.content,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.isDestructive = false,
  });

  final String title;
  final Widget? content;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final radius = context.dsRadius;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.r12),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: typography.h2.copyWith(color: colors.textPrimary),
            ),
            if (content != null) ...[
              SizedBox(height: spacing.s12),
              DefaultTextStyle(
                style: typography.body.copyWith(color: colors.textSecondary),
                child: content!,
              ),
            ],
            SizedBox(height: spacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (secondaryLabel != null && onSecondary != null) ...[
                  DSButton(
                    label: secondaryLabel!,
                    variant: DSButtonVariant.secondary,
                    onPressed: onSecondary,
                  ),
                  SizedBox(width: spacing.s8),
                ],
                DSButton(
                  label: primaryLabel,
                  variant: isDestructive
                      ? DSButtonVariant.danger
                      : DSButtonVariant.primary,
                  onPressed: onPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
