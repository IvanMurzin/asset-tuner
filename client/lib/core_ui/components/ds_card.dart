import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

enum DSElevationLevel { level0, level1, level2 }

class DSCard extends StatelessWidget {
  const DSCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation = DSElevationLevel.level1,
    this.bordered = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final DSElevationLevel elevation;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final radius = context.dsRadius;
    final elevationTokens = context.dsElevation;

    final shadows = switch (elevation) {
      DSElevationLevel.level0 => elevationTokens.e0,
      DSElevationLevel.level1 => elevationTokens.e1,
      DSElevationLevel.level2 => elevationTokens.e2,
    };

    final borderRadius = BorderRadius.circular(radius.r12);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: borderRadius,
        boxShadow: shadows,
        border: bordered ? Border.all(color: colors.border) : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: padding ?? EdgeInsets.all(spacing.s16),
          child: child,
        ),
      ),
    );
  }
}
