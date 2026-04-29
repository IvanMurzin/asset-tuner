import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/utils/external_url_launcher.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/auth/bloc/sign_up_cubit.dart';
import 'package:asset_tuner/presentation/auth/widget/auth_hero.dart';
import 'package:asset_tuner/presentation/auth/widget/oauth_section.dart';
import 'package:asset_tuner/presentation/auth/widget/sign_up_confirm_password_field.dart';
import 'package:asset_tuner/presentation/auth/widget/sign_up_email_field.dart';
import 'package:asset_tuner/presentation/auth/widget/sign_up_legal_text.dart';
import 'package:asset_tuner/presentation/auth/widget/sign_up_password_field.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<SignUpCubit>(),
      child: BlocConsumer<SignUpCubit, SignUpState>(
        listenWhen: (prev, curr) =>
            (prev.status != curr.status && curr.status == SignUpStatus.otpSent) ||
            (curr.bannerType != prev.bannerType && curr.bannerType != null),
        listener: (context, state) {
          if (state.status == SignUpStatus.otpSent && state.otpEmail != null) {
            if (state.bannerType == SignUpBannerType.success) {
              final message = _bannerMessage(context, l10n, state);
              if (message != null && context.mounted) {
                showDSSnackBar(
                  context,
                  variant: DSSnackBarVariant.success,
                  message: message,
                  duration: const Duration(seconds: 3),
                );
              }
            }
            if (context.mounted) {
              context.go(AppRoutes.otp, extra: state.otpEmail);
            }
            return;
          }
          final message = _bannerMessage(context, l10n, state);
          if (message != null && context.mounted) {
            showDSSnackBar(context, variant: DSSnackBarVariant.error, message: message);
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
          final typography = context.dsTypography;
          final isLoading = state.status == SignUpStatus.loading;
          final providers = state.availableProviders;

          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: DSAppBar(title: l10n.signUpTitle),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                padding: EdgeInsets.fromLTRB(
                  spacing.s24,
                  spacing.s24,
                  spacing.s24,
                  spacing.s24 + keyboardInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthHero(title: l10n.signUpTitle, subtitle: l10n.signUpBody),
                    SizedBox(height: spacing.s24),
                    SignUpEmailField(
                      label: l10n.emailLabel,
                      hint: l10n.emailHint,
                      errorText: _emailErrorText(l10n, state.emailError),
                    ),
                    SizedBox(height: spacing.s16),
                    SignUpPasswordField(
                      label: l10n.passwordLabel,
                      hint: l10n.passwordHint,
                      errorText: _passwordErrorText(l10n, state.passwordError),
                    ),
                    SizedBox(height: spacing.s16),
                    SignUpConfirmPasswordField(
                      label: l10n.confirmPasswordLabel,
                      hint: l10n.confirmPasswordHint,
                      errorText: _confirmErrorText(l10n, state.confirmPasswordError),
                    ),
                    if (providers.isNotEmpty) ...[
                      SizedBox(height: spacing.s24),
                      Text(
                        l10n.signInWith,
                        style: typography.caption.copyWith(color: context.dsColors.textSecondary),
                      ),
                      SizedBox(height: spacing.s12),
                      OAuthSection(
                        isLoading: isLoading,
                        providers: providers,
                        googleLabel: l10n.continueWithGoogle,
                        appleLabel: l10n.continueWithApple,
                        onProviderPressed: context.read<SignUpCubit>().signUpWithProvider,
                      ),
                    ],
                    SizedBox(height: spacing.s24),
                    DSButton(
                      label: l10n.signUpPrimary,
                      isLoading: isLoading,
                      fullWidth: true,
                      onPressed: isLoading ? null : context.read<SignUpCubit>().submit,
                    ),
                    SizedBox(height: spacing.s16),
                    TextButton(
                      onPressed: isLoading ? null : () => context.go(AppRoutes.signIn),
                      child: Text(
                        l10n.switchToSignIn,
                        style: typography.body.copyWith(color: context.dsColors.primary),
                      ),
                    ),
                    SizedBox(height: spacing.s12),
                    SignUpLegalText(
                      prefix: l10n.signUpLegalPrefix,
                      termsLabel: l10n.signUpLegalTerms,
                      privacyLabel: l10n.signUpLegalPrivacy,
                      onTermsTap: isLoading
                          ? null
                          : () => launchExternalUrl(
                              context,
                              url: AppConfig.instance.termsOfUseUrl,
                              errorMessage: l10n.errorGeneric,
                            ),
                      onPrivacyTap: isLoading
                          ? null
                          : () => launchExternalUrl(
                              context,
                              url: AppConfig.instance.privacyPolicyUrl,
                              errorMessage: l10n.errorGeneric,
                            ),
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

  String? _bannerMessage(BuildContext context, AppLocalizations l10n, SignUpState state) {
    switch (state.bannerType) {
      case SignUpBannerType.success:
        final email = state.bannerEmail ?? '';
        return l10n.bannerOtpSuccessBodyWithEmail(email);
      case SignUpBannerType.failure:
        return state.bannerFailureCode != null
            ? (state.bannerFailureMessage ?? l10n.errorGeneric)
            : l10n.errorGeneric;
      case null:
        return null;
    }
  }
}
