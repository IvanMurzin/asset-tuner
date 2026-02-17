import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSSectionTitle extends StatelessWidget {
  const DSSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final typography = context.dsTypography;
    final colors = context.dsColors;

    return Text(title, style: typography.h3.copyWith(color: colors.textPrimary));
  }
}
