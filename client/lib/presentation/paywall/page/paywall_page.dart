import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: DSAppBar(title: l10n.paywallTitle),
      body: Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(spacing.s24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary.withValues(alpha: 0.2),
                    colors.warning.withValues(alpha: 0.18),
                  ],
                ),
                borderRadius: BorderRadius.circular(context.dsRadius.r16),
                border: Border.all(color: colors.border.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.paywallHeader, style: typography.h2),
                  SizedBox(height: spacing.s8),
                  Text(
                    l10n.paywallBody,
                    style: typography.body.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.s24),
            DSCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.paywallBody,
                    style: typography.body.copyWith(color: colors.textSecondary),
                  ),
                  SizedBox(height: spacing.s16),
                  DSButton(
                    label: l10n.paywallDismiss,
                    variant: DSButtonVariant.secondary,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
