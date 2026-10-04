import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/utils/external_url_launcher.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_body.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_loading_skeleton.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_offer_view.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_scaffold.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key, required this.args});

  final PaywallArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaywallCubit>(param1: args)..loadOfferings(),
      child: _PaywallView(args: args),
    );
  }
}

class _PaywallView extends StatefulWidget {
  const _PaywallView({required this.args});

  final PaywallArgs args;

  @override
  State<_PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<_PaywallView> {
  @override
  void initState() {
    super.initState();
    // Listeners only see later changes, so the "already Pro on entry" case is checked once here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PaywallCubit>().onProfileChanged(
          isPro: context.read<ProfileCubit>().state.isPro,
        );
      }
    });
  }

  Future<void> _verifyPro(BuildContext context) async {
    final paywallCubit = context.read<PaywallCubit>();
    final profileCubit = context.read<ProfileCubit>();
    final assetsCubit = context.read<AssetsCubit>();
    await profileCubit.syncSubscription(silent: false, force: true, placement: 'paywall_purchase');
    final isPro = profileCubit.state.isPro;
    if (isPro) {
      try {
        await assetsCubit.refresh(silent: true, forceRefresh: true);
      } catch (_) {}
    }
    if (!paywallCubit.isClosed) {
      paywallCubit.onVerified(isPro: isPro);
    }
  }

  void _showFailure(BuildContext context, PaywallState state) {
    final l10n = AppLocalizations.of(context)!;
    final message = switch (state.failureCode) {
      'paywall_load_offerings' => l10n.paywallNoOfferings,
      'paywall_sync_not_pro' => l10n.paywallEntitlementsError,
      _ => state.failureMessage ?? l10n.errorGeneric,
    };
    logger.e('Paywall error: ${state.failureCode}');
    showDSSnackBar(context, variant: DSSnackBarVariant.error, message: message);
  }

  String _reasonText(AppLocalizations l10n) {
    return switch (widget.args.reason) {
      PaywallReason.onboarding => l10n.paywallReasonOnboarding,
      PaywallReason.accountsLimit => l10n.paywallReasonAccounts,
      PaywallReason.subaccountsLimit => l10n.paywallReasonSubaccounts,
      PaywallReason.baseCurrency => l10n.paywallReasonBaseCurrency,
      PaywallReason.manageSubscription => l10n.paywallReasonManageSubscription,
    };
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    await launchExternalUrl(
      context,
      url: url,
      errorMessage: AppLocalizations.of(context)!.errorGeneric,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PaywallCubit>();
    final paywall = context.watch<PaywallCubit>().state;
    final body = resolvePaywallBody(
      auth: context.watch<AuthCubit>().state,
      profile: context.watch<ProfileCubit>().state,
      paywall: paywall,
    );

    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (prev, curr) => prev.isPro != curr.isPro,
          listener: (context, state) => cubit.onProfileChanged(isPro: state.isPro),
        ),
        BlocListener<PaywallCubit, PaywallState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            switch (state.status) {
              case PaywallStatus.verifying:
                _verifyPro(context);
              case PaywallStatus.done:
                // The only place that closes the paywall; `done` is terminal, so this runs once.
                context.pop(null);
              case PaywallStatus.ready || PaywallStatus.processing:
                break;
            }
          },
        ),
        BlocListener<PaywallCubit, PaywallState>(
          listenWhen: (prev, curr) =>
              prev.failureCode != curr.failureCode && curr.failureCode != null,
          listener: _showFailure,
        ),
      ],
      child: PaywallScaffold(
        restoreLabel: l10n.paywallRestore,
        isBusy: paywall.isBusy,
        onClose: () => cubit.dismiss(logAnalytics: false),
        onRestore: body is PaywallBodyOffer ? cubit.restore : null,
        body: switch (body) {
          PaywallBodyIdentityError(:final message) => DSInlineError(
            title: l10n.genericErrorTitle,
            message: message ?? l10n.paywallIdentityPending,
            actionLabel: l10n.retryAction,
            onAction: () => context.read<AuthCubit>().syncRevenueCat(),
          ),
          PaywallBodyProfileLoading() => const PaywallLoadingSkeleton(),
          PaywallBodyProfileError(:final message) => DSInlineError(
            title: l10n.genericErrorTitle,
            message: message ?? l10n.errorGeneric,
            actionLabel: l10n.retryAction,
            onAction: () => context.read<ProfileCubit>().refresh(),
          ),
          PaywallBodyClosing() => const SizedBox.shrink(),
          PaywallBodyOffer() => PaywallOfferView(
            state: paywall,
            reasonText: _reasonText(l10n),
            onPlanChanged: cubit.selectPlan,
            onContinue: cubit.purchase,
            onDismiss: cubit.dismiss,
            onTermsTap: () => _openUrl(context, AppConfig.instance.termsOfUseUrl),
            onPrivacyTap: () => _openUrl(context, AppConfig.instance.privacyPolicyUrl),
          ),
        },
      ),
    );
  }
}
