import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class OnboardingCarouselIconBubble extends StatelessWidget {
  const OnboardingCarouselIconBubble({super.key, required this.icon, required this.tint});

  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final radius = context.dsRadius;
    final elevation = context.dsElevation;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r16),
        border: Border.all(color: colors.border.withValues(alpha: 0.55)),
        boxShadow: elevation.e1,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withValues(alpha: 0.22), colors.surface.withValues(alpha: 0.90)],
        ),
      ),
      child: Icon(icon, size: 34, color: tint),
    );
  }
}
