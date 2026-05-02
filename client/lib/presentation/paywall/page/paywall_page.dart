import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core/utils/external_url_launcher.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_footer.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_header.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_legal_text.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_loading_skeleton.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_plan_toggle.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_tier_card.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key, required this.args});

  final PaywallArgs args;

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  final RevenueCatService _revenueCatService = getIt<RevenueCatService>();
  final AppAnalytics _analytics = getIt<AppAnalytics>();

  Package? _monthlyPackage;
  Package? _annualPackage;
  PaywallPlanOption _selectedOption = PaywallPlanOption.annual;
  bool _isLoadingOfferings = true;
  bool _isProcessingAction = false;
  bool _didLogView = false;

  bool get _monthlyEnabled => _monthlyPackage != null;
  bool get _annualEnabled => _annualPackage != null;

  Package? get _selectedPackage {
    if (_selectedOption == PaywallPlanOption.monthly) {
      return _monthlyPackage;
    }
    return _annualPackage;
  }

  bool get _canContinue {
    return !_isLoadingOfferings && !_isProcessingAction && _selectedPackage != null;
  }

  String get _reasonName {
    return switch (widget.args.reason) {
      PaywallReason.onboarding => 'onboarding',
      PaywallReason.accountsLimit => 'accounts_limit',
      PaywallReason.subaccountsLimit => 'subaccounts_limit',
      PaywallReason.baseCurrency => 'base_currency',
      PaywallReason.manageSubscription => 'manage_subscription',
    };
  }

  String get _placement {
    return switch (widget.args.reason) {
      PaywallReason.onboarding => 'onboarding',
      PaywallReason.manageSubscription => 'manage_subscription',
      _ => 'feature_gate',
    };
  }

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoadingOfferings = true;
    });

    try {
      final offerings = await _revenueCatService.getOfferings();
      final offering = offerings.current;
      final available = offering?.availablePackages ?? const <Package>[];

      var annual = offering?.annual ?? _findByType(available, PackageType.annual);
      var monthly = offering?.monthly ?? _findByType(available, PackageType.monthly);

      annual ??= _findByPeriod(available, 'P1Y');
      monthly ??= _findByPeriod(available, 'P1M');

      annual ??= _firstDifferent(available, monthly);
      monthly ??= _firstDifferent(available, annual);

      if (annual == null && monthly == null && available.isNotEmpty) {
        annual = available.first;
      }

      final selected = annual != null ? PaywallPlanOption.annual : PaywallPlanOption.monthly;

      if (!mounted) {
        return;
      }

      setState(() {
        _annualPackage = annual;
        _monthlyPackage = monthly;
        _selectedOption = selected;
        _isLoadingOfferings = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingOfferings = false;
      });
      _showError(AppLocalizations.of(context)!.paywallNoOfferings, code: 'paywall_load_offerings');
    }
  }

  Package? _findByType(List<Package> packages, PackageType type) {
    for (final package in packages) {
      if (package.packageType == type) {
        return package;
      }
    }
    return null;
  }

  Package? _findByPeriod(List<Package> packages, String periodCode) {
    for (final package in packages) {
      if (package.storeProduct.subscriptionPeriod == periodCode) {
        return package;
      }
    }
    return null;
  }

  Package? _firstDifferent(List<Package> packages, Package? excluded) {
    for (final package in packages) {
      if (excluded == null || package.identifier != excluded.identifier) {
        return package;
      }
    }
    return null;
  }

  String _selectorMonthlyPrice() {
    final monthly = _monthlyPackage;
    if (monthly != null) {
      return monthly.storeProduct.priceString;
    }
    final annual = _annualPackage;
    if (annual != null) {
      return annual.storeProduct.pricePerMonthString ?? annual.storeProduct.priceString;
    }
    return '--';
  }

  String _selectorYearlyPrice() {
    final annual = _annualPackage;
    if (annual != null) {
      return annual.storeProduct.priceString;
    }
    final monthly = _monthlyPackage;
    if (monthly != null) {
      return monthly.storeProduct.pricePerYearString ?? monthly.storeProduct.priceString;
    }
    return '--';
  }

  String _selectedPrice() {
    return switch (_selectedOption) {
      PaywallPlanOption.monthly => _selectorMonthlyPrice(),
      PaywallPlanOption.annual => _selectorYearlyPrice(),
    };
  }

  String _selectedPeriod(AppLocalizations l10n) {
    return switch (_selectedOption) {
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

  void _logViewIfNeeded() {
    if (_didLogView || _isLoadingOfferings) {
      return;
    }
    _didLogView = true;
    _analytics.log(
      AnalyticsEventName.paywallViewed,
      parameters: {
        'placement': _placement,
        'reason': _reasonName,
        'variant': 'subscription_v1',
        'selected_plan': _selectedOption.name,
      },
    );
  }

  void _onPlanChanged(PaywallPlanOption next) {
    setState(() => _selectedOption = next);
    _analytics.log(
      AnalyticsEventName.planSelected,
      parameters: {
        'placement': _placement,
        'plan': next.name,
        'package_id': _selectedPackage?.identifier,
      },
    );
  }

  void _onDismissPressed() {
    _analytics.log(
      AnalyticsEventName.paywallDismissed,
      parameters: {'placement': _placement, 'reason': _reasonName, 'variant': 'subscription_v1'},
    );
    context.pop(null);
  }

  Future<void> _onContinuePressed() async {
    final package = _selectedPackage;
    if (package == null || _isProcessingAction) {
      return;
    }

    setState(() {
      _isProcessingAction = true;
    });

    try {
      _analytics.log(
        AnalyticsEventName.purchaseStarted,
        parameters: {
          'placement': _placement,
          'reason': _reasonName,
          'plan': _selectedOption.name,
          'package_id': package.identifier,
        },
      );
      await _revenueCatService.purchasePackage(package);
      _analytics.log(
        AnalyticsEventName.purchaseSucceeded,
        parameters: {
          'placement': _placement,
          'reason': _reasonName,
          'plan': _selectedOption.name,
          'package_id': package.identifier,
        },
      );
      await _onPurchaseOrRestoreCompleted();
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      _analytics.log(
        AnalyticsEventName.purchaseFailed,
        parameters: {
          'placement': _placement,
          'reason': _reasonName,
          'plan': _selectedOption.name,
          'package_id': package.identifier,
          'failure_code': code.name,
          'cancelled': code == PurchasesErrorCode.purchaseCancelledError,
        },
      );
      if (code != PurchasesErrorCode.purchaseCancelledError && mounted) {
        _showError(
          error.message ?? AppLocalizations.of(context)!.errorGeneric,
          code: 'paywall_purchase',
        );
      }
    } catch (_) {
      _analytics.log(
        AnalyticsEventName.purchaseFailed,
        parameters: {
          'placement': _placement,
          'reason': _reasonName,
          'plan': _selectedOption.name,
          'package_id': package.identifier,
          'failure_code': 'unknown',
          'cancelled': false,
        },
      );
      if (mounted) {
        _showError(AppLocalizations.of(context)!.errorGeneric, code: 'paywall_purchase');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  Future<void> _onRestorePressed() async {
    if (_isProcessingAction) {
      return;
    }

    setState(() {
      _isProcessingAction = true;
    });

    try {
      _analytics.log(AnalyticsEventName.restoreStarted, parameters: {'placement': _placement});
      await _revenueCatService.restorePurchases();
      _analytics.log(AnalyticsEventName.restoreSucceeded, parameters: {'placement': _placement});
      await _onPurchaseOrRestoreCompleted();
    } catch (_) {
      _analytics.log(
        AnalyticsEventName.restoreFailed,
        parameters: {'placement': _placement, 'failure_code': 'unknown'},
      );
      if (mounted) {
        _showError(AppLocalizations.of(context)!.errorGeneric, code: 'paywall_restore');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  Future<void> _onPurchaseOrRestoreCompleted() async {
    final isPro = await _syncSubscriptionAndConfirmPro();
    if (!mounted) {
      return;
    }
    if (!isPro) {
      _showError(
        AppLocalizations.of(context)!.paywallEntitlementsError,
        code: 'paywall_sync_not_pro',
      );
      return;
    }
    try {
      await context.read<AssetsCubit>().refresh(silent: true, forceRefresh: true);
    } catch (_) {}
    if (!mounted) {
      return;
    }
    context.pop(null);
  }

  Future<bool> _syncSubscriptionAndConfirmPro() async {
    final profileCubit = context.read<ProfileCubit>();
    await profileCubit.syncSubscription(silent: false, force: true, placement: 'paywall_purchase');
    if (!mounted) {
      return false;
    }
    final state = profileCubit.state;
    return state.isReady && state.profile?.plan == 'pro';
  }

  Future<void> _openUrl(String url) async {
    await launchExternalUrl(
      context,
      url: url,
      errorMessage: AppLocalizations.of(context)!.errorGeneric,
    );
  }

  void _showError(String message, {required String code}) {
    if (!mounted) {
      return;
    }
    logger.e('Paywall error: $code');
    showDSSnackBar(context, variant: DSSnackBarVariant.error, message: message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final config = AppConfig.instance;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, sessionState) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            if (!sessionState.isRevenueCatReady) {
              return Scaffold(
                body: DSInlineError(
                  title: l10n.genericErrorTitle,
                  message: sessionState.revenueCatFailureMessage ?? l10n.paywallIdentityPending,
                  actionLabel: l10n.retryAction,
                  onAction: () => context.read<AuthCubit>().syncRevenueCat(),
                ),
              );
            }

            if (!profileState.isReady) {
              return Scaffold(
                body: DSInlineError(
                  title: l10n.genericErrorTitle,
                  message: profileState.failureMessage ?? l10n.errorGeneric,
                  actionLabel: l10n.retryAction,
                  onAction: () => context.read<ProfileCubit>().refresh(),
                ),
              );
            }

            if (profileState.profile?.plan == 'pro') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.pop(null);
                }
              });
              return const Scaffold(body: SizedBox.shrink());
            }

            _logViewIfNeeded();

            final proCompactFeatures = [
              l10n.paywallProFeatureAccounts,
              l10n.paywallProFeatureSubaccounts,
              l10n.paywallProFeatureFiat,
              l10n.paywallProFeatureFreshRates,
            ];

            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(spacing.s16, spacing.s4, spacing.s16, spacing.s8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PaywallHeader(
                        restoreLabel: l10n.paywallRestore,
                        isBusy: _isProcessingAction,
                        onClose: () => context.pop(null),
                        onRestore: _onRestorePressed,
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
                        child: _isLoadingOfferings
                            ? const PaywallLoadingSkeleton()
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    PaywallPlanToggle(
                                      monthlyLabel: l10n.paywallPlanMonthlyTitle,
                                      yearlyLabel: l10n.paywallPlanAnnualTitle,
                                      annualBadgeText: l10n.paywallMostPopular,
                                      selectedOption: _selectedOption,
                                      monthlyEnabled: _monthlyEnabled,
                                      yearlyEnabled: _annualEnabled,
                                      monthlyPrice: _selectorMonthlyPrice(),
                                      yearlyPrice: _selectorYearlyPrice(),
                                      onChanged: _onPlanChanged,
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
                        isLoading: _isProcessingAction,
                        isContinueEnabled: _canContinue,
                        onContinue: _onContinuePressed,
                        onDismiss: _onDismissPressed,
                      ),
                      SizedBox(height: spacing.s4),
                      PaywallLegalText(
                        prefix: l10n.paywallLegalPrefixWithPrice(
                          _selectedPrice(),
                          _selectedPeriod(l10n),
                        ),
                        termsLabel: l10n.paywallLegalTerms,
                        privacyLabel: l10n.paywallLegalPrivacy,
                        onTermsTap: () => _openUrl(config.termsOfUseUrl),
                        onPrivacyTap: () => _openUrl(config.privacyPolicyUrl),
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
  }
}
