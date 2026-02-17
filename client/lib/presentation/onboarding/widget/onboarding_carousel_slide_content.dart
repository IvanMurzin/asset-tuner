import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/presentation/onboarding/widget/onboarding_carousel_chip.dart';
import 'package:asset_tuner/presentation/onboarding/widget/onboarding_carousel_icon_bubble.dart';

class OnboardingCarouselSlideContent extends StatelessWidget {
  const OnboardingCarouselSlideContent({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.chipLabels,
    this.parallaxOffset = 0.0,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<String> chipLabels;
  final double parallaxOffset;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final spacing = context.dsSpacing;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: Offset(parallaxOffset * -14.0, 0),
          child: OnboardingCarouselIconBubble(icon: icon, tint: colors.primary),
        ),
        SizedBox(height: spacing.s24),
        Text(title, style: typography.h2),
        SizedBox(height: spacing.s12),
        Text(body, style: typography.body.copyWith(color: colors.textSecondary, height: 1.35)),
        SizedBox(height: spacing.s24),
        Wrap(
          spacing: spacing.s8,
          runSpacing: spacing.s8,
          children: chipLabels.map((label) => OnboardingCarouselChip(label: label)).toList(),
        ),
      ],
    );
  }
}
