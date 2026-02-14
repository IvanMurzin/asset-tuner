import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_plan_card.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';
import 'package:asset_tuner/presentation/utils/supabase_error_message.dart';
import 'package:supabase_error_translator_flutter/supabase_error_translator_flutter.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key, required this.args});

  final PaywallArgs args;

  String _reasonText(AppLocalizations l10n, PaywallReason reason) {
    return switch (reason) {
      PaywallReason.accountsLimit => l10n.paywallReasonAccounts,
      PaywallReason.subaccountsLimit => l10n.paywallReasonSubaccounts,
      PaywallReason.baseCurrency => l10n.paywallReasonBaseCurrency,
    };
  }

  String _planTitle(AppLocalizations l10n, PaywallPlanOption plan) {
    return switch (plan) {
      PaywallPlanOption.monthly => l10n.paywallPlanMonthlyTitle,
      PaywallPlanOption.annual => l10n.paywallPlanAnnualTitle,
    };
  }

  String _planSubtitle(AppLocalizations l10n, PaywallPlanOption plan) {
    return switch (plan) {
      PaywallPlanOption.monthly => l10n.paywallPlanMonthlySubtitle,
      PaywallPlanOption.annual => l10n.paywallPlanAnnualSubtitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<PaywallCubit>()..load(reason: args.reason),
      child: BlocConsumer<PaywallCubit, PaywallState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<PaywallCubit>().consumeNavigation();
          switch (navigation.destination) {
            case PaywallDestination.closeUpgraded:
              context.pop(true);
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;
          final colors = context.dsColors;

          if (state.status == PaywallStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == PaywallStatus.error) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.paywallTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: l10n.errorGeneric,
                actionLabel: l10n.splashRetry,
                onAction: () =>
                    context.read<PaywallCubit>().load(reason: args.reason),
              ),
            );
          }

          final isPaid = (state.plan ?? 'free') == 'paid';
          final selectedPlan = state.selectedPlan;
          final showEntitlementsBanner = state.entitlementsUnverified;
          final showUpgradeError = state.upgradeFailureCode != null;

          return Scaffold(
            appBar: DSAppBar(title: l10n.paywallTitle),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(spacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DSCard(
                              padding: EdgeInsets.zero,
                              bordered: false,
                              elevation: DSElevationLevel.level0,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(
                                  spacing.s16 + spacing.s4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colors.primary.withValues(alpha: 0.26),
                                      colors.info.withValues(alpha: 0.18),
                                      colors.surface.withValues(alpha: 0.0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    context.dsRadius.r16,
                                  ),
                                  border: Border.all(
                                    color: colors.border.withValues(alpha: 0.7),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: spacing.s32 + spacing.s12,
                                          height: spacing.s32 + spacing.s12,
                                          decoration: BoxDecoration(
                                            color: colors.surface,
                                            borderRadius: BorderRadius.circular(
                                              context.dsRadius.r16,
                                            ),
                                            border: Border.all(
                                              color: colors.border,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.workspace_premium_outlined,
                                            color: colors.primary,
                                          ),
                                        ),
                                        SizedBox(width: spacing.s12),
                                        Expanded(
                                          child: Text(
                                            l10n.paywallHeaderTitle,
                                            style: typography.h2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: spacing.s12),
                                    Text(
                                      _reasonText(l10n, args.reason),
                                      style: typography.body.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (showEntitlementsBanner) ...[
                              SizedBox(height: spacing.s16),
                              DSInlineBanner(
                                title: l10n.paywallTitle,
                                message: l10n.paywallEntitlementsError,
                                variant: DSInlineBannerVariant.warning,
                              ),
                            ],
                            if (showUpgradeError) ...[
                              SizedBox(height: spacing.s16),
                              DSInlineBanner(
                                title: l10n.paywallTitle,
                                message: state.upgradeFailureCode != null
                                    ? resolveFailureMessage(
                                        context,
                                        code: state.upgradeFailureCode,
                                        rawMessage: state.upgradeFailureMessage,
                                        service: ErrorService.database,
                                      )
                                    : l10n.errorGeneric,
                                variant: DSInlineBannerVariant.danger,
                              ),
                            ],
                            SizedBox(height: spacing.s16 + spacing.s4),
                            DSSectionTitle(title: l10n.paywallIncludesTitle),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FeatureRow(
                                    text: l10n.paywallFeatureAccounts,
                                  ),
                                  SizedBox(height: spacing.s12),
                                  _FeatureRow(
                                    text: l10n.paywallFeatureSubaccounts,
                                  ),
                                  SizedBox(height: spacing.s12),
                                  _FeatureRow(
                                    text: l10n.paywallFeatureCurrencies,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.s16 + spacing.s4),
                            DSSectionTitle(title: l10n.paywallPlansTitle),
                            SizedBox(height: spacing.s12),
                            Column(
                              children: [
                                DSPlanCard(
                                  title: _planTitle(
                                    l10n,
                                    PaywallPlanOption.monthly,
                                  ),
                                  subtitle: _planSubtitle(
                                    l10n,
                                    PaywallPlanOption.monthly,
                                  ),
                                  selected:
                                      selectedPlan == PaywallPlanOption.monthly,
                                  onTap: isPaid
                                      ? null
                                      : () => context
                                            .read<PaywallCubit>()
                                            .selectPlan(
                                              PaywallPlanOption.monthly,
                                            ),
                                ),
                                SizedBox(height: spacing.s12),
                                DSPlanCard(
                                  title: _planTitle(
                                    l10n,
                                    PaywallPlanOption.annual,
                                  ),
                                  subtitle: _planSubtitle(
                                    l10n,
                                    PaywallPlanOption.annual,
                                  ),
                                  badgeText: l10n.paywallPlanRecommended,
                                  selected:
                                      selectedPlan == PaywallPlanOption.annual,
                                  onTap: isPaid
                                      ? null
                                      : () => context
                                            .read<PaywallCubit>()
                                            .selectPlan(
                                              PaywallPlanOption.annual,
                                            ),
                                ),
                              ],
                            ),
                            if (isPaid) ...[
                              SizedBox(height: spacing.s16),
                              DSInlineBanner(
                                title: l10n.paywallTitle,
                                message: l10n.paywallAlreadyPaid,
                                variant: DSInlineBannerVariant.success,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.s16),
                    DSButton(
                      label: l10n.paywallUpgrade,
                      fullWidth: true,
                      isLoading: state.isUpdating,
                      onPressed: isPaid || state.isUpdating
                          ? null
                          : () => context.read<PaywallCubit>().upgrade(),
                    ),
                    SizedBox(height: spacing.s12),
                    DSButton(
                      label: l10n.paywallDismiss,
                      variant: DSButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: () => context.pop(false),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: colors.primary, size: spacing.s16),
        SizedBox(width: spacing.s12),
        Expanded(child: Text(text, style: typography.body)),
      ],
    );
  }
}
