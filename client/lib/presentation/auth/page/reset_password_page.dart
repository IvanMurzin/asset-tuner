import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_otp_input.dart';
import 'package:asset_tuner/core_ui/components/ds_password_field.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/auth/bloc/reset_password_cubit.dart';
import 'package:asset_tuner/presentation/auth/widget/auth_hero.dart';

/// Opened from Sign in with the typed email as `extra`.
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final initialEmail = (GoRouterState.of(context).extra as String?) ?? '';
    return BlocProvider(
      create: (_) => getIt<ResetPasswordCubit>()..setInitialEmail(initialEmail),
      child: const _ResetPasswordView(),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView();

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text != value) {
      controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listenWhen: (prev, curr) =>
          (curr.bannerFailureCode != null && curr.bannerFailureCode != prev.bannerFailureCode) ||
          curr.resendSuccess ||
          (curr.step == ResetPasswordStep.done && prev.step != ResetPasswordStep.done),
      listener: (context, state) {
        if (state.step == ResetPasswordStep.done) {
          showDSSnackBar(
            context,
            variant: DSSnackBarVariant.success,
            message: l10n.resetPasswordSuccess,
          );
          // Verifying the code signed the user in; this route is public but not an auth-flow
          // route, so the auth guard leaves it to the page to move on once the password is set.
          context.go(AppRoutes.main);
          return;
        }
        if (state.resendSuccess) {
          context.read<ResetPasswordCubit>().clearResendSuccess();
          showDSSnackBar(
            context,
            variant: DSSnackBarVariant.success,
            message: l10n.otpResendSuccess,
          );
          return;
        }
        showDSSnackBar(
          context,
          variant: DSSnackBarVariant.error,
          message: state.bannerFailureMessage ?? l10n.errorGeneric,
        );
      },
      builder: (context, state) {
        _sync(_emailController, state.email);
        _sync(_codeController, state.code);
        _sync(_passwordController, state.password);
        _sync(_confirmController, state.confirmPassword);

        final spacing = context.dsSpacing;
        final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
        final codeStep = state.step != ResetPasswordStep.email;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: DSAppBar(title: l10n.resetPasswordTitle),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                spacing.s24,
                spacing.s24,
                spacing.s24,
                spacing.s24 + keyboardInset,
              ),
              child: codeStep ? _codeStep(context, l10n, state) : _emailStep(context, l10n, state),
            ),
          ),
        );
      },
    );
  }

  Widget _emailStep(BuildContext context, AppLocalizations l10n, ResetPasswordState state) {
    final spacing = context.dsSpacing;
    final cubit = context.read<ResetPasswordCubit>();
    final isLoading = state.status == ResetPasswordStatus.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthHero(title: l10n.resetPasswordTitle, subtitle: l10n.resetPasswordEmailBody),
        SizedBox(height: spacing.s24),
        DSTextField(
          label: l10n.emailLabel,
          hintText: l10n.emailHint,
          controller: _emailController,
          enabled: !isLoading,
          errorText: state.emailError == ResetPasswordFieldError.invalidEmail
              ? l10n.validationInvalidEmail
              : null,
          keyboardType: TextInputType.emailAddress,
          onChanged: cubit.updateEmail,
        ),
        SizedBox(height: spacing.s24),
        DSButton(
          label: l10n.resetPasswordSendCode,
          isLoading: isLoading,
          fullWidth: true,
          onPressed: isLoading ? null : cubit.requestCode,
        ),
      ],
    );
  }

  Widget _codeStep(BuildContext context, AppLocalizations l10n, ResetPasswordState state) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final cubit = context.read<ResetPasswordCubit>();
    final isLoading = state.status != ResetPasswordStatus.idle || state.step.isDone;
    final canResend = !isLoading && !state.isResendInProgress && state.resendCooldownUntil == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthHero(title: l10n.resetPasswordTitle, subtitle: l10n.resetPasswordCodeBody(state.email)),
        SizedBox(height: spacing.s24),
        DSOtpInput(
          controller: _codeController,
          onChanged: cubit.updateCode,
          errorText: state.codeError == ResetPasswordFieldError.invalidCode
              ? l10n.validationOtpLength
              : null,
          enabled: !isLoading,
          autofocus: true,
        ),
        SizedBox(height: spacing.s8),
        Align(
          child: TextButton(
            onPressed: canResend ? cubit.resend : null,
            child: Text(
              l10n.resendOtp,
              style: typography.body.copyWith(
                color: canResend ? colors.primary : colors.textTertiary,
              ),
            ),
          ),
        ),
        SizedBox(height: spacing.s16),
        DSPasswordField(
          label: l10n.resetPasswordNewPasswordLabel,
          hintText: l10n.passwordHint,
          controller: _passwordController,
          enabled: !isLoading,
          errorText: state.passwordError == ResetPasswordFieldError.weakPassword
              ? l10n.validationPasswordRule
              : null,
          onChanged: cubit.updatePassword,
        ),
        SizedBox(height: spacing.s16),
        DSPasswordField(
          label: l10n.confirmPasswordLabel,
          hintText: l10n.confirmPasswordHint,
          controller: _confirmController,
          enabled: !isLoading,
          errorText: switch (state.confirmPasswordError) {
            ResetPasswordFieldError.confirmRequired => l10n.validationConfirmPasswordRequired,
            ResetPasswordFieldError.mismatch => l10n.validationPasswordMismatch,
            _ => null,
          },
          onChanged: cubit.updateConfirmPassword,
        ),
        SizedBox(height: spacing.s24),
        DSButton(
          label: l10n.resetPasswordSubmit,
          isLoading: isLoading,
          fullWidth: true,
          onPressed: isLoading ? null : cubit.submit,
        ),
        SizedBox(height: spacing.s12),
        TextButton(
          onPressed: isLoading ? null : cubit.changeEmail,
          child: Text(l10n.changeEmail, style: typography.body.copyWith(color: colors.primary)),
        ),
      ],
    );
  }
}

extension on ResetPasswordStep {
  bool get isDone => this == ResetPasswordStep.done;
}
