import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSFullScreenLoader extends StatelessWidget {
  const DSFullScreenLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    return Container(
      color: colors.background.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DSLoader(),
            if (message != null) ...[
              SizedBox(height: spacing.s12),
              Text(
                message!,
                style: typography.caption.copyWith(color: colors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
