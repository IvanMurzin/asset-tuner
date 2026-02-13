import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/auth/bloc/sign_up_cubit.dart';
import 'package:asset_tuner/presentation/auth/widget/auth_hero.dart';
import 'package:asset_tuner/presentation/auth/widget/sign_up_confirm_password_field.dart';
import 'package:asset_tuner/presentation/auth/widget/sign_up_email_field.dart';
import 'package:asset_tuner/presentation/auth/widget/sign_up_password_field.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<SignUpCubit>(),
      child: BlocConsumer<SignUpCubit, SignUpState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.go(AppRoutes.otp, extra: navigation.email);
          context.read<SignUpCubit>().consumeNavigation();
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;
          final isLoading = state.status == SignUpStatus.loading;
          final bannerMessage = _bannerMessage(l10n, state);

          return Scaffold(
            appBar: DSAppBar(title: l10n.signUpTitle),
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
                            title: l10n.signUpTitle,
                            subtitle: l10n.signUpBody,
                          ),
                          SizedBox(height: spacing.s24),
                          if (bannerMessage != null)
                            DSInlineBanner(
                              title: state.bannerType == SignUpBannerType.success
                                  ? l10n.bannerOtpSuccessTitle
                                  : l10n.bannerSignUpError,
                              message: bannerMessage,
                              variant: state.bannerType == SignUpBannerType.success
                                  ? DSInlineBannerVariant.success
                                  : DSInlineBannerVariant.danger,
                            ),
                          if (bannerMessage != null) SizedBox(height: spacing.s16),
                          SignUpEmailField(
                            label: l10n.emailLabel,
                            hint: l10n.emailHint,
                            errorText: _emailErrorText(l10n, state.emailError),
                          ),
                          SizedBox(height: spacing.s16),
                          SignUpPasswordField(
                            label: l10n.passwordLabel,
                            hint: l10n.passwordHint,
                            errorText: _passwordErrorText(
                              l10n,
                              state.passwordError,
                            ),
                          ),
                          SizedBox(height: spacing.s16),
                          SignUpConfirmPasswordField(
                            label: l10n.confirmPasswordLabel,
                            hint: l10n.confirmPasswordHint,
                            errorText: _confirmErrorText(
                              l10n,
                              state.confirmPasswordError,
                            ),
                          ),
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
                          label: l10n.signUpPrimary,
                          isLoading: isLoading,
                          fullWidth: true,
                          onPressed: isLoading
                              ? null
                              : context.read<SignUpCubit>().submit,
                        ),
                        SizedBox(height: spacing.s16),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go(AppRoutes.signIn),
                          child: Text(
                            l10n.switchToSignIn,
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

  String? _emailErrorText(AppLocalizations l10n, SignUpFieldError? error) {
    return switch (error) {
      SignUpFieldError.invalidEmail => l10n.validationInvalidEmail,
      _ => null,
    };
  }

  String? _passwordErrorText(AppLocalizations l10n, SignUpFieldError? error) {
    return switch (error) {
      SignUpFieldError.weakPassword => l10n.validationPasswordRule,
      _ => null,
    };
  }

  String? _confirmErrorText(AppLocalizations l10n, SignUpFieldError? error) {
    return switch (error) {
      SignUpFieldError.mismatch => l10n.validationPasswordMismatch,
      _ => null,
    };
  }

  String? _bannerMessage(AppLocalizations l10n, SignUpState state) {
    switch (state.bannerType) {
      case SignUpBannerType.success:
        final email = state.bannerEmail ?? '';
        return l10n.bannerOtpSuccessBodyWithEmail(email);
      case SignUpBannerType.failure:
        return _failureMessage(l10n, state.bannerFailureCode);
      case null:
        return null;
    }
  }

  String _failureMessage(AppLocalizations l10n, String? code) {
    return switch (code) {
      'rate_limited' => l10n.errorRateLimited,
      'network' => l10n.errorNetwork,
      'unauthorized' => l10n.errorUnauthorized,
      'conflict' => l10n.errorConflict,
      _ => l10n.errorGeneric,
    };
  }
}
