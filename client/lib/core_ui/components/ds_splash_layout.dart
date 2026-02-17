import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSSplashLayout extends StatelessWidget {
  const DSSplashLayout({super.key, required this.title, this.status});

  final String title;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: typography.h1),
          SizedBox(height: spacing.s16),
          const DSLoader(),
          if (status != null) ...[
            SizedBox(height: spacing.s12),
            Text(status!, style: typography.caption.copyWith(color: colors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
