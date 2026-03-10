import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/auth/bloc/sign_in_cubit.dart';
import 'package:asset_tuner/presentation/auth/widget/auth_hero.dart';
import 'package:asset_tuner/presentation/auth/widget/oauth_section.dart';
import 'package:asset_tuner/presentation/auth/widget/sign_in_email_field.dart';
import 'package:asset_tuner/presentation/auth/widget/sign_in_password_field.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<SignInCubit>(),
      child: BlocConsumer<SignInCubit, SignInState>(
        listenWhen: (prev, curr) =>
            curr.navigation != null ||
            (curr.bannerFailureCode != null &&
                curr.bannerFailureCode != prev.bannerFailureCode),
        listener: (context, state) async {
          final navigation = state.navigation;
          if (navigation != null) {
            switch (navigation.destination) {
              case SignInDestination.overview:
                context.go(AppRoutes.home);
            }
            context.read<SignInCubit>().consumeNavigation();
            return;
          }
          final message = state.bannerFailureCode != null
              ? (state.bannerFailureMessage ?? l10n.errorGeneric)
              : null;
          if (message != null && context.mounted) {
            showDSSnackBar(
              context,
              variant: DSSnackBarVariant.error,
              message: message,
            );
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;
          final isLoading = state.status == SignInStatus.loading;
          final providers = state.availableProviders;

          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: DSAppBar(title: l10n.signInTitle),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        spacing.s24,
                        spacing.s24,
                        spacing.s24,
                        spacing.s16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthHero(
                            title: l10n.signInTitle,
                            subtitle: l10n.signInBody,
                          ),
                          SizedBox(height: spacing.s24),
                          SignInEmailField(
                            label: l10n.emailLabel,
                            hint: l10n.emailHint,
                            errorText: _emailErrorText(l10n, state.emailError),
                          ),
                          SizedBox(height: spacing.s16),
                          SignInPasswordField(
                            label: l10n.passwordLabel,
                            hint: l10n.passwordHint,
                            errorText: _passwordErrorText(
                              l10n,
                              state.passwordError,
                            ),
                          ),
                          if (providers.isNotEmpty) ...[
                            SizedBox(height: spacing.s24),
                            Text(l10n.signInWith, style: typography.caption),
                            SizedBox(height: spacing.s12),
                            OAuthSection(
                              isLoading: isLoading,
                              providers: providers,
                              googleLabel: l10n.continueWithGoogle,
                              appleLabel: l10n.continueWithApple,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.s24,
                      spacing.s16,
                      spacing.s24,
                      spacing.s24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DSButton(
                          label: l10n.signInPrimary,
                          isLoading: isLoading,
                          fullWidth: true,
                          onPressed: isLoading
                              ? null
                              : context.read<SignInCubit>().signIn,
                        ),
                        SizedBox(height: spacing.s16),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go(AppRoutes.signUp),
                          child: Text(
                            l10n.switchToSignUp,
                            style: typography.body.copyWith(
                              color: context.dsColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _emailErrorText(AppLocalizations l10n, SignInFieldError? error) {
    return switch (error) {
      SignInFieldError.invalidEmail => l10n.validationInvalidEmail,
      _ => null,
    };
  }

  String? _passwordErrorText(AppLocalizations l10n, SignInFieldError? error) {
    return switch (error) {
      SignInFieldError.weakPassword => l10n.validationPasswordRule,
      _ => null,
    };
  }
}
