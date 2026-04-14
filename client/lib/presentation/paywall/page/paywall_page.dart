import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_error_banner.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_footer.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_header.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_legal_text.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_loading_skeleton.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_plan_toggle.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_tier_card.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/session/bloc/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key, required this.args});

  final PaywallArgs args;

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  final RevenueCatService _revenueCatService = getIt<RevenueCatService>();

  Package? _monthlyPackage;
  Package? _annualPackage;
  PaywallPlanOption _selectedOption = PaywallPlanOption.annual;
  bool _isLoadingOfferings = true;
  bool _isProcessingAction = false;
  String? _errorMessage;

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

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoadingOfferings = true;
      _errorMessage = null;
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
        _errorMessage = AppLocalizations.of(context)!.paywallNoOfferings;
      });
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

  Future<void> _onContinuePressed() async {
    final package = _selectedPackage;
    if (package == null || _isProcessingAction) {
      return;
    }

    setState(() {
      _isProcessingAction = true;
      _errorMessage = null;
    });

    try {
      await _revenueCatService.purchasePackage(package);
      await _onPurchaseOrRestoreCompleted();
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code != PurchasesErrorCode.purchaseCancelledError && mounted) {
        setState(() {
          _errorMessage = error.message ?? AppLocalizations.of(context)!.errorGeneric;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.errorGeneric;
        });
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
      _errorMessage = null;
    });

    try {
      await _revenueCatService.restorePurchases();
      await _onPurchaseOrRestoreCompleted();
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.errorGeneric;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  Future<void> _onPurchaseOrRestoreCompleted() async {
    await context.read<ProfileCubit>().syncSubscription();
    if (!mounted) {
      return;
    }
    try {
      await context.read<AssetsCubit>().refresh(silent: true);
    } catch (_) {}
    if (!mounted) {
      return;
    }
    context.pop(null);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      showDSSnackBar(
        context,
        variant: DSSnackBarVariant.error,
        message: AppLocalizations.of(context)!.errorGeneric,
      );
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      showDSSnackBar(
        context,
        variant: DSSnackBarVariant.error,
        message: AppLocalizations.of(context)!.errorGeneric,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final config = AppConfig.instance;

    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SessionStatus.unauthenticated) {
          context.go(AppRoutes.signIn);
        }
      },
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, sessionState) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              if (!sessionState.isAuthenticated) {
                return Scaffold(
                  body: DSInlineError(
                    title: l10n.splashErrorTitle,
                    message: l10n.errorGeneric,
                    actionLabel: l10n.splashRetry,
                    onAction: () => context.read<SessionCubit>().bootstrap(),
                  ),
                );
              }

              if (!profileState.isReady) {
                return Scaffold(
                  body: DSInlineError(
                    title: l10n.splashErrorTitle,
                    message: profileState.failureMessage ?? l10n.errorGeneric,
                    actionLabel: l10n.splashRetry,
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

              final freeFeatures = [
                l10n.paywallFreeFeatureAccounts,
                l10n.paywallFreeFeatureSubaccounts,
                l10n.paywallFreeFeatureFiat,
                l10n.paywallFreeFeatureCrypto,
              ];

              final proFeatures = [
                l10n.paywallProFeatureAccounts,
                l10n.paywallProFeatureSubaccounts,
                l10n.paywallProFeatureFiat,
                l10n.paywallProFeatureCrypto,
              ];

              final freeCompactFeatures = [freeFeatures[0], freeFeatures[1], freeFeatures[2]];

              final proCompactFeatures = [proFeatures[0], proFeatures[1], proFeatures[2]];

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
                                l10n.paywallUnlockTitle,
                                textAlign: TextAlign.center,
                                style: typography.h2.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: spacing.s8),
                              Text(
                                l10n.paywallSubtitle,
                                textAlign: TextAlign.center,
                                style: typography.body.copyWith(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: spacing.s4),
                            ],
                          ),
                        ),
                        SizedBox(height: spacing.s8),
                        if (_errorMessage != null) ...[
                          PaywallErrorBanner(
                            title: l10n.paywallTitle,
                            message: _errorMessage!,
                            actionLabel: l10n.splashRetry,
                            onAction: _loadOfferings,
                          ),
                          SizedBox(height: spacing.s8),
                        ],
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
                                        selectedOption: _selectedOption,
                                        monthlyEnabled: _monthlyEnabled,
                                        yearlyEnabled: _annualEnabled,
                                        monthlyPrice: _selectorMonthlyPrice(),
                                        yearlyPrice: _selectorYearlyPrice(),
                                        onChanged: (next) => setState(() => _selectedOption = next),
                                      ),
                                      SizedBox(height: spacing.s8),
                                      PaywallTierCard(
                                        title: l10n.paywallFreeTitle,
                                        features: freeCompactFeatures,
                                        dense: true,
                                      ),
                                      SizedBox(height: spacing.s8),
                                      PaywallTierCard(
                                        title: l10n.paywallProTitle,
                                        features: proCompactFeatures,
                                        highlighted: true,
                                        badgeText: l10n.paywallMostPopular,
                                        dense: true,
                                      ),
                                      SizedBox(height: spacing.s8),
                                    ],
                                  ),
                                ),
                        ),
                        SizedBox(height: spacing.s8),
                        PaywallFooter(
                          continueLabel: l10n.paywallContinue,
                          dismissLabel: l10n.paywallDismiss,
                          isLoading: _isProcessingAction,
                          isContinueEnabled: _canContinue,
                          onContinue: _onContinuePressed,
                          onDismiss: () => context.pop(null),
                        ),
                        SizedBox(height: spacing.s4),
                        PaywallLegalText(
                          prefix: l10n.paywallLegalPrefix,
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
      ),
    );
  }
}
