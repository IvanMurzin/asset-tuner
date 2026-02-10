import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_shimmer.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSSkeleton extends StatelessWidget {
  const DSSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shimmer = true,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final radius = borderRadius ?? BorderRadius.circular(context.dsRadius.r12);

    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: colors.surfaceAlt, borderRadius: radius),
    );

    if (!shimmer) {
      return box;
    }

    return DSShimmer(
      baseColor: colors.surfaceAlt,
      highlightColor: colors.surface,
      child: box,
    );
  }
}
