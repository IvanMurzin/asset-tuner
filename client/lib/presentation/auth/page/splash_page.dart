import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/components/ds_splash_layout.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/user/bloc/user_cubit.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<UserCubit, UserState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case UserStatus.unauthenticated:
            context.go(AppRoutes.signIn);
            break;
          case UserStatus.authenticated:
            context.go(AppRoutes.main);
            break;
          case UserStatus.error:
            if (context.mounted) {
              showDSSnackBar(
                context,
                variant: DSSnackBarVariant.error,
                message: state.failureMessage ?? l10n.errorGeneric,
              );
            }
            break;
          case UserStatus.initial:
          case UserStatus.loading:
            break;
        }
      },
      builder: (context, state) {
        final isLoading = state.status == UserStatus.initial || state.status == UserStatus.loading;

        return Scaffold(
          body: isLoading
              ? DSSplashLayout(title: l10n.appTitle, status: l10n.splashPreparingProfile)
              : state.status == UserStatus.error
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(context.dsSpacing.s24),
                    child: DSButton(
                      label: l10n.splashRetry,
                      onPressed: context.read<UserCubit>().bootstrap,
                    ),
                  ),
                )
              : DSSplashLayout(title: l10n.appTitle, status: l10n.splashPreparingProfile),
        );
      },
    );
  }
}
