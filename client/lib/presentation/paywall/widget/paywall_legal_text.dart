import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class PaywallLegalText extends StatelessWidget {
  const PaywallLegalText({
    super.key,
    required this.prefix,
    required this.termsLabel,
    required this.privacyLabel,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final String prefix;
  final String termsLabel;
  final String privacyLabel;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: spacing.s4,
      runSpacing: spacing.s4,
      children: [
        Text(
          prefix,
          textAlign: TextAlign.center,
          style: typography.caption.copyWith(color: colors.textTertiary),
        ),
        GestureDetector(
          onTap: onTermsTap,
          child: Text(
            termsLabel,
            style: typography.caption.copyWith(
              color: colors.textSecondary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Text('•', style: typography.caption.copyWith(color: colors.textTertiary)),
        GestureDetector(
          onTap: onPrivacyTap,
          child: Text(
            privacyLabel,
            style: typography.caption.copyWith(
              color: colors.textSecondary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
