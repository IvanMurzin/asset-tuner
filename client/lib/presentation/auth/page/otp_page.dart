import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/auth/bloc/otp_cubit.dart';
import 'package:asset_tuner/presentation/auth/widget/auth_hero.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = (GoRouterState.of(context).extra as String?) ?? '';

    return BlocProvider(
      create: (_) => getIt<OtpCubit>()..setEmail(email),
      child: BlocConsumer<OtpCubit, OtpState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          switch (navigation.destination) {
            case OtpDestination.onboardingBaseCurrency:
              context.go(AppRoutes.onboardingBaseCurrency);
            case OtpDestination.overview:
              context.go(AppRoutes.overview);
            case OtpDestination.signIn:
              context.go(AppRoutes.signIn);
          }
          context.read<OtpCubit>().consumeNavigation();
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;
          final isLoading = state.status == OtpStatus.loading;
          final bannerText = _failureMessage(l10n, state.bannerFailureCode);

          return Scaffold(
            appBar: DSAppBar(title: l10n.otpTitle),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(spacing.s24, spacing.s24, spacing.s24, spacing.s32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthHero(title: l10n.otpTitle, subtitle: l10n.otpBodyWithEmail(email)),
                    SizedBox(height: spacing.s24),
                    if (bannerText != null)
                      DSInlineBanner(
                        title: l10n.bannerOtpError,
                        message: bannerText,
                        variant: DSInlineBannerVariant.danger,
                      ),
                    if (bannerText != null) SizedBox(height: spacing.s16),
                    Text(l10n.otpCodeLabel, style: typography.label),
                    SizedBox(height: spacing.s8),
                    DSTextField(
                      label: null,
                      hintText: l10n.otpCodeHint,
                      enabled: !isLoading,
                      errorText: _codeErrorText(l10n, state.codeError),
                      keyboardType: TextInputType.number,
                      onChanged: context.read<OtpCubit>().updateCode,
                    ),
                    SizedBox(height: spacing.s24),
                    DSButton(
                      label: l10n.verifyOtp,
                      isLoading: isLoading,
                      fullWidth: true,
                      onPressed: isLoading ? null : context.read<OtpCubit>().verify,
                    ),
                    SizedBox(height: spacing.s12),
                    TextButton(
                      onPressed: isLoading ? null : () => context.go(AppRoutes.signUp),
                      child: Text(
                        l10n.changeEmail,
                        style: typography.body.copyWith(color: context.dsColors.primary),
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

  String? _codeErrorText(AppLocalizations l10n, OtpFieldError? error) {
    return switch (error) {
      OtpFieldError.invalidLength => l10n.validationOtpLength,
      _ => null,
    };
  }

  String? _failureMessage(AppLocalizations l10n, String? code) {
    if (code == null) {
      return null;
    }
    return switch (code) {
      'rate_limited' => l10n.errorRateLimited,
      'network' => l10n.errorNetwork,
      'unauthorized' => l10n.errorUnauthorized,
      'conflict' => l10n.errorConflict,
      _ => l10n.errorGeneric,
    };
  }
}
