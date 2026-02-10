import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSLoader extends StatelessWidget {
  const DSLoader({super.key, this.size, this.strokeWidth = 2.5, this.color});

  final double? size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final resolvedSize = size ?? spacing.s24;

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? colors.primary),
      ),
    );
  }
}
