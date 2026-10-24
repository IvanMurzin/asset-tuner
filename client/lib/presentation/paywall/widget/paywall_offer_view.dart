import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_footer.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_legal_text.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_loading_skeleton.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_plan_toggle.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_tier_card.dart';
import 'package:flutter/material.dart';

/// The Pro offer: value proposition, plan selection, purchase actions and legal text.
class PaywallOfferView extends StatelessWidget {
  const PaywallOfferView({
    super.key,
    required this.state,
    required this.reasonText,
    required this.onPlanChanged,
    required this.onContinue,
    required this.onDismiss,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  final PaywallState state;
  final String reasonText;
  final ValueChanged<PaywallPlanOption> onPlanChanged;
  final VoidCallback onContinue;
  final VoidCallback onDismiss;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Hero(reasonText: reasonText),
        SizedBox(height: spacing.s8),
        Expanded(
          child: state.offerings == PaywallOfferings.loading
              ? const PaywallLoadingSkeleton()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      PaywallPlanToggle(
                        monthlyLabel: l10n.paywallPlanMonthlyTitle,
                        yearlyLabel: l10n.paywallPlanAnnualTitle,
                        annualBadgeText: l10n.paywallMostPopular,
                        selectedOption: state.selectedOption,
                        monthlyEnabled: state.monthlyPackage != null,
                        yearlyEnabled: state.annualPackage != null,
                        monthlyPrice: _monthlyPrice,
                        yearlyPrice: _yearlyPrice,
                        onChanged: onPlanChanged,
                      ),
                      SizedBox(height: spacing.s24),
                      PaywallTierCard(
                        title: l10n.paywallProTitle,
                        features: [
                          l10n.paywallProFeatureAccounts,
                          l10n.paywallProFeatureSubaccounts,
                          l10n.paywallProFeatureFiat,
                          l10n.paywallProFeatureFreshRates,
                        ],
                        highlighted: true,
                        dense: true,
                      ),
                      SizedBox(height: spacing.s8),
                    ],
                  ),
                ),
        ),
        SizedBox(height: spacing.s8),
        PaywallFooter(
          continueLabel: l10n.paywallStartPro,
          dismissLabel: l10n.paywallContinueFree,
          isLoading: state.isBusy,
          isContinueEnabled: state.canContinue,
          onContinue: onContinue,
          onDismiss: onDismiss,
        ),
        SizedBox(height: spacing.s4),
        PaywallLegalText(
          prefix: l10n.paywallLegalPrefixWithPrice(_selectedPrice, _selectedPeriod(l10n)),
          termsLabel: l10n.paywallLegalTerms,
          privacyLabel: l10n.paywallLegalPrivacy,
          onTermsTap: onTermsTap,
          onPrivacyTap: onPrivacyTap,
        ),
      ],
    );
  }

  String get _monthlyPrice {
    final monthly = state.monthlyPackage;
    if (monthly != null) {
      return monthly.storeProduct.priceString;
    }
    final annual = state.annualPackage;
    if (annual != null) {
      return annual.storeProduct.pricePerMonthString ?? annual.storeProduct.priceString;
    }
    return '--';
  }

  String get _yearlyPrice {
    final annual = state.annualPackage;
    if (annual != null) {
      return annual.storeProduct.priceString;
    }
    final monthly = state.monthlyPackage;
    if (monthly != null) {
      return monthly.storeProduct.pricePerYearString ?? monthly.storeProduct.priceString;
    }
    return '--';
  }

  String get _selectedPrice => switch (state.selectedOption) {
    PaywallPlanOption.monthly => _monthlyPrice,
    PaywallPlanOption.annual => _yearlyPrice,
  };

  String _selectedPeriod(AppLocalizations l10n) => switch (state.selectedOption) {
    PaywallPlanOption.monthly => l10n.paywallBillingPeriodMonthly,
    PaywallPlanOption.annual => l10n.paywallBillingPeriodAnnual,
  };
}

class _Hero extends StatelessWidget {
  const _Hero({required this.reasonText});

  final String reasonText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset('assets/icon/icon.png', width: 52, height: 52, fit: BoxFit.cover),
          ),
          SizedBox(height: spacing.s12),
          Text(
            l10n.paywallValueTitle,
            textAlign: TextAlign.center,
            style: typography.h2.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: spacing.s8),
          Text(
            l10n.paywallValueSubtitle,
            textAlign: TextAlign.center,
            style: typography.body.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: spacing.s8),
          Text(
            reasonText,
            textAlign: TextAlign.center,
            style: typography.caption.copyWith(
              color: colors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: spacing.s4),
        ],
      ),
    );
  }
}
