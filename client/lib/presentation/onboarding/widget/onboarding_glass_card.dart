import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class OnboardingGlassCard extends StatelessWidget {
  const OnboardingGlassCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = context.dsRadius;
    final colors = context.dsColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius.r16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.neutral0.withValues(alpha: 0.12),
                colors.neutral0.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(radius.r16),
            border: Border.all(color: colors.border.withValues(alpha: 0.55)),
          ),
          child: child,
        ),
      ),
    );
  }
}
