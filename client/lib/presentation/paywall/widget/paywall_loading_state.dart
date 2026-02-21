import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class PaywallLoadingState extends StatelessWidget {
  const PaywallLoadingState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSLoader(size: spacing.s32),
          SizedBox(height: spacing.s12),
          Text(
            message,
            style: typography.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
