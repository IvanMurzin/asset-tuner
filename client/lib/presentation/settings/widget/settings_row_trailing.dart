import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class SettingsRowTrailing extends StatelessWidget {
  const SettingsRowTrailing({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final spacing = context.dsSpacing;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.body.copyWith(color: colors.textSecondary),
          ),
        ),
        SizedBox(width: spacing.s4),
        Icon(Icons.chevron_right, color: colors.textTertiary),
      ],
    );
  }
}
