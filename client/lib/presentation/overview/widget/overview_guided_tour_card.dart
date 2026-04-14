import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class OverviewGuidedTourCard extends StatelessWidget {
  const OverviewGuidedTourCard({
    super.key,
    required this.title,
    required this.body,
    required this.progressLabel,
    required this.nextLabel,
    required this.skipLabel,
    required this.onSkip,
    required this.onNext,
  });

  final String title;
  final String body;
  final String progressLabel;
  final String nextLabel;
  final String skipLabel;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final radius = context.dsRadius;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(spacing.s16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(radius.r16),
          border: Border.all(color: colors.border),
          boxShadow: context.dsElevation.e2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(progressLabel, style: typography.caption.copyWith(color: colors.textSecondary)),
            SizedBox(height: spacing.s8),
            Text(title, style: typography.h3.copyWith(color: colors.textPrimary)),
            SizedBox(height: spacing.s8),
            Text(body, style: typography.body.copyWith(color: colors.textSecondary)),
            SizedBox(height: spacing.s16),
            Row(
              children: [
                Expanded(
                  child: DSButton(
                    label: skipLabel,
                    variant: DSButtonVariant.secondary,
                    onPressed: onSkip,
                  ),
                ),
                SizedBox(width: spacing.s8),
                Expanded(
                  child: DSButton(label: nextLabel, onPressed: onNext),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
