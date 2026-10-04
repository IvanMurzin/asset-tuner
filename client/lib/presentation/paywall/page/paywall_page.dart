import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/utils/external_url_launcher.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_footer.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_header.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_legal_text.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_loading_skeleton.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_plan_toggle.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_tier_card.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key, required this.args});

  final PaywallArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaywallCubit>(param1: args)..loadOfferings(),
      child: _PaywallView(args: args),
    );
  }
}

class _PaywallView extends StatefulWidget {
  const _PaywallView({required this.args});

  final PaywallArgs args;

  @override
  State<_PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<_PaywallView> {
  static bool _isPro(ProfileState state) => state.isReady && (state.profile?.isPro ?? false);

  @override
  void initState() {
    super.initState();
    // Listeners only see later changes, so the "already Pro on entry" case is checked once here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PaywallCubit>().onProfileChanged(
          isPro: _isPro(context.read<ProfileCubit>().state),
        );
      }
    });
  }

  Future<void> _verifyPro(BuildContext context) async {
    final paywallCubit = context.read<PaywallCubit>();
    final profileCubit = context.read<ProfileCubit>();
    final assetsCubit = context.read<AssetsCubit>();
    await profileCubit.syncSubscription(silent: false, force: true, placement: 'paywall_purchase');
    final isPro = _isPro(profileCubit.state);
    if (isPro) {
      try {
        await assetsCubit.refresh(silent: true, forceRefresh: true);
      } catch (_) {}
    }
    if (!paywallCubit.isClosed) {
      paywallCubit.onVerified(isPro: isPro);
    }
  }

  void _showFailure(BuildContext context, PaywallState state) {
    final l10n = AppLocalizations.of(context)!;
    final message = switch (state.failureCode) {
      'paywall_load_offerings' => l10n.paywallNoOfferings,
      'paywall_sync_not_pro' => l10n.paywallEntitlementsError,
      _ => state.failureMessage ?? l10n.errorGeneric,
    };
    logger.e('Paywall error: ${state.failureCode}');
    showDSSnackBar(context, variant: DSSnackBarVariant.error, message: message);
  }

  String _selectorMonthlyPrice(PaywallState paywall) {
    final monthly = paywall.monthlyPackage;
    if (monthly != null) {
      return monthly.storeProduct.priceString;
    }
    final annual = paywall.annualPackage;
    if (annual != null) {
      return annual.storeProduct.pricePerMonthString ?? annual.storeProduct.priceString;
    }
    return '--';
  }

  String _selectorYearlyPrice(PaywallState paywall) {
    final annual = paywall.annualPackage;
    if (annual != null) {
      return annual.storeProduct.priceString;
    }
    final monthly = paywall.monthlyPackage;
    if (monthly != null) {
      return monthly.storeProduct.pricePerYearString ?? monthly.storeProduct.priceString;
    }
    return '--';
  }

  String _selectedPrice(PaywallState paywall) {
    return switch (paywall.selectedOption) {
      PaywallPlanOption.monthly => _selectorMonthlyPrice(paywall),
      PaywallPlanOption.annual => _selectorYearlyPrice(paywall),
    };
  }

  String _selectedPeriod(PaywallState paywall, AppLocalizations l10n) {
    return switch (paywall.selectedOption) {
      PaywallPlanOption.monthly => l10n.paywallBillingPeriodMonthly,
      PaywallPlanOption.annual => l10n.paywallBillingPeriodAnnual,
    };
  }

  String _reasonText(AppLocalizations l10n) {
    return switch (widget.args.reason) {
      PaywallReason.onboarding => l10n.paywallReasonOnboarding,
      PaywallReason.accountsLimit => l10n.paywallReasonAccounts,
      PaywallReason.subaccountsLimit => l10n.paywallReasonSubaccounts,
      PaywallReason.baseCurrency => l10n.paywallReasonBaseCurrency,
      PaywallReason.manageSubscription => l10n.paywallReasonManageSubscription,
    };
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    await launchExternalUrl(
      context,
      url: url,
      errorMessage: AppLocalizations.of(context)!.errorGeneric,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final cubit = context.read<PaywallCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (prev, curr) => _isPro(prev) != _isPro(curr),
          listener: (context, state) => cubit.onProfileChanged(isPro: _isPro(state)),
        ),
        BlocListener<PaywallCubit, PaywallState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            switch (state.status) {
              case PaywallStatus.verifying:
                _verifyPro(context);
              case PaywallStatus.done:
                // The only place that closes the paywall; `done` is terminal, so this runs once.
                context.pop(null);
              case PaywallStatus.ready || PaywallStatus.processing:
                break;
            }
          },
        ),
        BlocListener<PaywallCubit, PaywallState>(
          listenWhen: (prev, curr) =>
              prev.failureCode != curr.failureCode && curr.failureCode != null,
          listener: _showFailure,
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, sessionState) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              return BlocBuilder<PaywallCubit, PaywallState>(
                builder: (context, paywall) {
                  if (!sessionState.isRevenueCatReady) {
                    return Scaffold(
                      body: DSInlineError(
                        title: l10n.genericErrorTitle,
                        message:
                            sessionState.revenueCatFailureMessage ?? l10n.paywallIdentityPending,
                        actionLabel: l10n.retryAction,
                        onAction: () => context.read<AuthCubit>().syncRevenueCat(),
                      ),
                    );
                  }

                  if (!profileState.isReady) {
                    if (profileState.status == ProfileStatus.initial ||
                        profileState.status == ProfileStatus.loading) {
                      return Scaffold(
                        body: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              spacing.s16,
                              spacing.s16,
                              spacing.s16,
                              spacing.s8,
                            ),
                            child: const PaywallLoadingSkeleton(),
                          ),
                        ),
                      );
                    }
                    return Scaffold(
                      body: DSInlineError(
                        title: l10n.genericErrorTitle,
                        message: profileState.failureMessage ?? l10n.errorGeneric,
                        actionLabel: l10n.retryAction,
                        onAction: () => context.read<ProfileCubit>().refresh(),
                      ),
                    );
                  }

                  // Already Pro and nothing in flight: the paywall is about to be dismissed.
                  if (_isPro(profileState) && paywall.status == PaywallStatus.ready) {
                    return const Scaffold(body: SizedBox.shrink());
                  }

                  final proCompactFeatures = [
                    l10n.paywallProFeatureAccounts,
                    l10n.paywallProFeatureSubaccounts,
                    l10n.paywallProFeatureFiat,
                    l10n.paywallProFeatureFreshRates,
                  ];

                  return Scaffold(
                    body: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          spacing.s16,
                          spacing.s4,
                          spacing.s16,
                          spacing.s8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PaywallHeader(
                              restoreLabel: l10n.paywallRestore,
                              isBusy: paywall.isBusy,
                              onClose: () => cubit.dismiss(logAnalytics: false),
                              onRestore: cubit.restore,
                            ),
                            SizedBox(height: spacing.s8),
                            Center(
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.asset(
                                      'assets/icon/icon.png',
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: spacing.s12),
                                  Text(
                                    l10n.paywallValueTitle,
                                    textAlign: TextAlign.center,
                                    style: typography.h2.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
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
                                    _reasonText(l10n),
                                    textAlign: TextAlign.center,
                                    style: typography.caption.copyWith(
                                      color: colors.textTertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: spacing.s4),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.s8),
                            Expanded(
                              child: !paywall.offeringsLoaded
                                  ? const PaywallLoadingSkeleton()
                                  : SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        children: [
                                          PaywallPlanToggle(
                                            monthlyLabel: l10n.paywallPlanMonthlyTitle,
                                            yearlyLabel: l10n.paywallPlanAnnualTitle,
                                            annualBadgeText: l10n.paywallMostPopular,
                                            selectedOption: paywall.selectedOption,
                                            monthlyEnabled: paywall.monthlyPackage != null,
                                            yearlyEnabled: paywall.annualPackage != null,
                                            monthlyPrice: _selectorMonthlyPrice(paywall),
                                            yearlyPrice: _selectorYearlyPrice(paywall),
                                            onChanged: cubit.selectPlan,
                                          ),
                                          SizedBox(height: spacing.s24),
                                          PaywallTierCard(
                                            title: l10n.paywallProTitle,
                                            features: proCompactFeatures,
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
                              isLoading: paywall.isBusy,
                              isContinueEnabled: paywall.canContinue,
                              onContinue: cubit.purchase,
                              onDismiss: cubit.dismiss,
                            ),
                            SizedBox(height: spacing.s4),
                            PaywallLegalText(
                              prefix: l10n.paywallLegalPrefixWithPrice(
                                _selectedPrice(paywall),
                                _selectedPeriod(paywall, l10n),
                              ),
                              termsLabel: l10n.paywallLegalTerms,
                              privacyLabel: l10n.paywallLegalPrivacy,
                              onTermsTap: () => _openUrl(context, AppConfig.instance.termsOfUseUrl),
                              onPrivacyTap: () =>
                                  _openUrl(context, AppConfig.instance.privacyPolicyUrl),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
