import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/components/ds_splash_layout.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/session/bloc/session_cubit.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        BlocListener<SessionCubit, SessionState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            _handleNavigation(context);
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
            _handleNavigation(context);
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
                          profileState.status == ProfileStatus.loading));
              final hasBlockingError =
                  sessionState.status == SessionStatus.error ||
                  (sessionState.isAuthenticated &&
                      profileState.status == ProfileStatus.error &&
                      profileState.profile == null);

              return Scaffold(
                body: isLoading
                    ? DSSplashLayout(title: l10n.appTitle, status: l10n.splashPreparingProfile)
                    : hasBlockingError
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(context.dsSpacing.s24),
                          child: DSButton(
                            label: l10n.splashRetry,
                            onPressed: () => _retry(context),
                          ),
                        ),
                      )
                    : DSSplashLayout(title: l10n.appTitle, status: l10n.splashPreparingProfile),
              );
            },
          );
        },
      ),
    );
  }

  void _handleNavigation(BuildContext context) {
    final sessionState = context.read<SessionCubit>().state;
    final profileState = context.read<ProfileCubit>().state;

    if (sessionState.status == SessionStatus.unauthenticated) {
      context.go(AppRoutes.signIn);
      return;
    }

    if (sessionState.isAuthenticated && profileState.isReady) {
      context.go(AppRoutes.main);
    }
  }

  void _retry(BuildContext context) {
    context.read<SessionCubit>().bootstrap();
    context.read<ProfileCubit>().bootstrap();
  }
}
