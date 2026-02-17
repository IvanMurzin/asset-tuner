import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class OnboardingCarouselChip extends StatelessWidget {
  const OnboardingCarouselChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final radius = context.dsRadius;
    final spacing = context.dsSpacing;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius.r12),
        border: Border.all(color: colors.border.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.s12, vertical: spacing.s8),
        child: Text(label, style: typography.caption.copyWith(color: colors.textSecondary)),
      ),
    );
  }
}
