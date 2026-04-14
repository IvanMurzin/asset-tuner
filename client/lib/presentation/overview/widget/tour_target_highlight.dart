import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class TourTargetHighlight extends StatelessWidget {
  const TourTargetHighlight({super.key, required this.isActive, required this.child});

  final bool isActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = context.dsRadius;
    final colors = context.dsColors;
    final spacing = context.dsSpacing;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: isActive ? EdgeInsets.all(spacing.s4) : EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r16),
        border: isActive ? Border.all(color: colors.primary, width: 2) : null,
      ),
      child: child,
    );
  }
}
