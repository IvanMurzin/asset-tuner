import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/components/ds_splash_layout.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/auth/bloc/splash_cubit.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<SplashCubit>(),
      child: BlocConsumer<SplashCubit, SplashState>(
        listenWhen: (prev, curr) =>
            curr is SplashRoute ||
            (curr is SplashError && prev is! SplashError),
        listener: (context, state) {
          if (state case SplashRoute(:final destination)) {
            switch (destination) {
              case SplashDestination.signIn:
                context.go(AppRoutes.signIn);
              case SplashDestination.onboardingBaseCurrency:
                context.go(AppRoutes.onboardingBaseCurrency);
              case SplashDestination.main:
                context.go(AppRoutes.main);
            }
            return;
          }
          if (state case SplashError(:final failureCode, :final failureMessage)) {
            if (context.mounted) {
              showDSSnackBar(
                context,
                variant: DSSnackBarVariant.error,
                message: _failureMessage(l10n, failureCode, failureMessage),
              );
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: switch (state) {
              SplashLoading(:final stage) => DSSplashLayout(
                title: l10n.appTitle,
                status: stage == SplashStage.restoring
                    ? l10n.splashRestoring
                    : l10n.splashPreparingProfile,
              ),
              SplashError() => Center(
                child: Padding(
                  padding: EdgeInsets.all(context.dsSpacing.s24),
                  child: DSButton(
                    label: l10n.splashRetry,
                    onPressed: context.read<SplashCubit>().restore,
                  ),
                ),
              ),
              SplashRoute() => DSSplashLayout(
                title: l10n.appTitle,
                status: l10n.splashPreparingProfile,
              ),
            },
          );
        },
      ),
    );
  }

  String _failureMessage(AppLocalizations l10n, String code, String? message) {
    if (message != null && message.trim().isNotEmpty) return message.trim();
    return switch (code) {
      'rate_limited' => l10n.errorRateLimited,
      'network' => l10n.errorNetwork,
      'unauthorized' => l10n.errorUnauthorized,
      'conflict' => l10n.errorConflict,
      _ => l10n.errorGeneric,
    };
  }
}
