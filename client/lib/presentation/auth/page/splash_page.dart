import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/local_storage/onboarding_paywall_storage.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/components/ds_splash_layout.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/session/bloc/session_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final OnboardingPaywallStorage _onboardingPaywallStorage = OnboardingPaywallStorage();
  bool _isOpeningOnboardingPaywall = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        BlocListener<SessionCubit, SessionState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            _handleNavigation();
            if (state.status == SessionStatus.error && context.mounted) {
              showDSSnackBar(
                context,
                variant: DSSnackBarVariant.error,
                message: state.failureMessage ?? l10n.errorGeneric,
              );
            }
          },
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            _handleNavigation();
            if (state.status == ProfileStatus.error && context.mounted) {
              showDSSnackBar(
                context,
                variant: DSSnackBarVariant.error,
                message: state.failureMessage ?? l10n.errorGeneric,
              );
            }
          },
        ),
      ],
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, sessionState) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final isLoading =
                  sessionState.status == SessionStatus.initial ||
                  (sessionState.isAuthenticated &&
                      (profileState.status == ProfileStatus.initial ||
                          profileState.status == ProfileStatus.loading ||
                          sessionState.revenueCatStatus == RevenueCatIdentityStatus.syncing));
              final hasBlockingError =
                  sessionState.status == SessionStatus.error ||
                  sessionState.revenueCatStatus == RevenueCatIdentityStatus.error ||
                  (sessionState.isAuthenticated &&
                      profileState.status == ProfileStatus.error &&
                      profileState.profile == null);

              return Scaffold(
                body: isLoading
                    ? DSSplashLayout(title: l10n.appTitle, status: l10n.splashPreparingProfile)
                    : hasBlockingError
                    ? DSInlineError(
                        title: l10n.splashErrorTitle,
                        message: sessionState.revenueCatFailureMessage ?? l10n.errorGeneric,
                        actionLabel: l10n.splashRetry,
                        onAction: () => _retry(context),
                      )
                    : DSSplashLayout(title: l10n.appTitle, status: l10n.splashPreparingProfile),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleNavigation() async {
    final sessionState = context.read<SessionCubit>().state;
    final profileState = context.read<ProfileCubit>().state;

    if (sessionState.status == SessionStatus.unauthenticated) {
      context.go(AppRoutes.signIn);
      return;
    }

    if (sessionState.isAuthenticated && profileState.isReady && sessionState.isRevenueCatReady) {
      final profile = profileState.profile;
      if (profile?.plan != 'pro' && await _shouldShowOnboardingPaywall()) {
        if (!mounted || _isOpeningOnboardingPaywall) {
          return;
        }
        _isOpeningOnboardingPaywall = true;
        await _onboardingPaywallStorage.setSeen();
        if (!mounted) {
          return;
        }
        getIt<AppAnalytics>().log(
          AnalyticsEventName.lockedFeatureTapped,
          parameters: {
            AnalyticsParams.feature: 'onboarding_paywall',
            AnalyticsParams.placement: 'splash',
          },
        );
        await context.push(
          AppRoutes.paywall,
          extra: const PaywallArgs(reason: PaywallReason.onboarding),
        );
        if (!mounted) {
          return;
        }
        _isOpeningOnboardingPaywall = false;
      }
      if (!mounted) {
        return;
      }
      context.go(AppRoutes.main);
    }
  }

  Future<bool> _shouldShowOnboardingPaywall() async {
    if (_isOpeningOnboardingPaywall) {
      return false;
    }
    return !await _onboardingPaywallStorage.getSeen();
  }

  void _retry(BuildContext context) {
    context.read<SessionCubit>().bootstrap();
    context.read<ProfileCubit>().bootstrap();
    context.read<SessionCubit>().syncRevenueCat();
  }
}
