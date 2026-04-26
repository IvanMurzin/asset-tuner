import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ManageSubscriptionFeaturesCard extends StatelessWidget {
  const ManageSubscriptionFeaturesCard({super.key, required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = _buildFeatures(isPaid, l10n);

    return DSCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.dsSpacing.s16),
            child: DSSectionTitle(title: l10n.subscriptionFeaturesTitle),
          ),
          Divider(height: 1, color: context.dsColors.border),
          for (int i = 0; i < features.length; i++) ...[
            _FeatureRow(text: features[i].text, enabled: features[i].enabled),
            if (i < features.length - 1) Divider(height: 1, color: context.dsColors.border),
          ],
        ],
      ),
    );
  }

  List<_FeatureItem> _buildFeatures(bool isPaid, AppLocalizations l10n) {
    if (isPaid) {
      return [
        _FeatureItem(l10n.paywallProFeatureAccounts, enabled: true),
        _FeatureItem(l10n.paywallProFeatureSubaccounts, enabled: true),
        _FeatureItem(l10n.paywallProFeatureFiat, enabled: true),
        _FeatureItem(l10n.paywallProFeatureCrypto, enabled: true),
      ];
    }

    return [
      _FeatureItem(l10n.paywallFreeFeatureAccounts, enabled: true),
      _FeatureItem(l10n.paywallFreeFeatureSubaccounts, enabled: true),
      _FeatureItem(l10n.paywallFreeFeatureFiat, enabled: true),
      _FeatureItem(l10n.paywallFreeFeatureCrypto, enabled: true),
      _FeatureItem(l10n.paywallProFeatureAccounts, enabled: false),
      _FeatureItem(l10n.paywallProFeatureFiat, enabled: false),
    ];
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text, required this.enabled});

  final String text;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s16, vertical: spacing.s12),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            size: 20,
            color: enabled ? colors.success : colors.textTertiary,
          ),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Text(
              text,
              style: typography.body.copyWith(
                color: enabled ? colors.textPrimary : colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem(this.text, {required this.enabled});

  final String text;
  final bool enabled;
}
