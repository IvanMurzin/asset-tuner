import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class PaywallFooter extends StatelessWidget {
  const PaywallFooter({
    super.key,
    required this.continueLabel,
    required this.dismissLabel,
    required this.onContinue,
    required this.onDismiss,
    this.isLoading = false,
    this.isContinueEnabled = true,
  });

  final String continueLabel;
  final String dismissLabel;
  final VoidCallback? onContinue;
  final VoidCallback? onDismiss;
  final bool isLoading;
  final bool isContinueEnabled;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DSButton(
          label: continueLabel,
          fullWidth: true,
          isLoading: isLoading,
          onPressed: isContinueEnabled ? onContinue : null,
        ),
        SizedBox(height: spacing.s8),
        TextButton(
          onPressed: isLoading ? null : onDismiss,
          child: Text(
            dismissLabel,
            style: typography.h3.copyWith(
              color: isLoading ? colors.textTertiary : colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
