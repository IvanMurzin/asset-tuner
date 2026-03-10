import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_otp_input.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/auth/bloc/otp_cubit.dart';
import 'package:asset_tuner/presentation/auth/widget/auth_hero.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late final TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = (GoRouterState.of(context).extra as String?) ?? '';

    return BlocProvider(
      create: (_) => getIt<OtpCubit>()..setEmail(email),
      child: BlocConsumer<OtpCubit, OtpState>(
        listenWhen: (prev, curr) =>
            curr.navigation != null ||
            (curr.bannerFailureCode != null &&
                curr.bannerFailureCode != prev.bannerFailureCode) ||
            curr.resendSuccess,
        listener: (context, state) async {
          if (state.resendSuccess) {
            context.read<OtpCubit>().clearResendSuccess();
            if (context.mounted) {
              showDSSnackBar(
                context,
                variant: DSSnackBarVariant.success,
                message: l10n.otpResendSuccess,
              );
            }
            return;
          }
          final navigation = state.navigation;
          if (navigation != null) {
            switch (navigation.destination) {
              case OtpDestination.overview:
                context.go(AppRoutes.home);
              case OtpDestination.signIn:
                context.go(AppRoutes.signIn);
            }
            context.read<OtpCubit>().consumeNavigation();
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
          final isLoading = state.status == OtpStatus.loading;
          final otpEnabled = !isLoading && !state.isResendInProgress;

          if (_otpController.text != state.code) {
            _otpController.text = state.code;
            _otpController.selection = TextSelection.collapsed(
              offset: _otpController.text.length,
            );
          }

          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: DSAppBar(title: l10n.otpTitle),
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
                            title: l10n.otpTitle,
                            subtitle: l10n.otpBodyWithEmail(email),
                          ),
                          SizedBox(height: spacing.s32),
                          DSOtpInput(
                            controller: _otpController,
                            onChanged: context.read<OtpCubit>().updateCode,
                            errorText: _codeErrorText(l10n, state.codeError),
                            enabled: otpEnabled,
                            autofocus: true,
                          ),
                          SizedBox(height: spacing.s16),
                          _ResendCaption(
                            isLoading: isLoading,
                            isResendInProgress: state.isResendInProgress,
                            onResend: () => context.read<OtpCubit>().resend(),
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
                          label: l10n.verifyOtp,
                          isLoading: isLoading,
                          fullWidth: true,
                          onPressed: isLoading
                              ? null
                              : context.read<OtpCubit>().verify,
                        ),
                        SizedBox(height: spacing.s12),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go(AppRoutes.signUp),
                          child: Text(
                            l10n.changeEmail,
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

  String? _codeErrorText(AppLocalizations l10n, OtpFieldError? error) {
    return switch (error) {
      OtpFieldError.invalidLength => l10n.validationOtpLength,
      _ => null,
    };
  }
}

class _ResendCaption extends StatelessWidget {
  const _ResendCaption({
    required this.isLoading,
    required this.isResendInProgress,
    required this.onResend,
  });

  final bool isLoading;
  final bool isResendInProgress;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final disabled = isLoading || isResendInProgress;

    if (disabled) {
      return Align(
        alignment: Alignment.center,
        child: Text(
          l10n.resendOtp,
          style: typography.body.copyWith(color: colors.textTertiary),
        ),
      );
    }

    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: onResend,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          l10n.resendOtp,
          style: typography.body.copyWith(color: colors.primary),
        ),
      ),
    );
  }
}
