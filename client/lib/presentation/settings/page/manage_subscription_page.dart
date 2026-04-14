import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/session/bloc/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class ManageSubscriptionPage extends StatelessWidget {
  const ManageSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SessionStatus.unauthenticated) {
          context.go(AppRoutes.signIn);
        }
      },
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, sessionState) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              if (!sessionState.isAuthenticated) {
                return Scaffold(
                  appBar: DSAppBar(title: l10n.subscriptionTitle),
                  body: DSInlineError(
                    title: l10n.splashErrorTitle,
                    message: l10n.errorGeneric,
                    actionLabel: l10n.splashRetry,
                    onAction: () => context.read<SessionCubit>().bootstrap(),
                  ),
                );
              }

              if (!profileState.isReady) {
                return Scaffold(
                  appBar: DSAppBar(title: l10n.subscriptionTitle),
                  body: DSInlineError(
                    title: l10n.splashErrorTitle,
                    message: profileState.failureMessage ?? l10n.errorGeneric,
                    actionLabel: l10n.splashRetry,
                    onAction: () => context.read<ProfileCubit>().refresh(),
                  ),
                );
              }

              final profile = profileState.profile!;
              final isPaid = profile.plan == 'pro';

              return Scaffold(
                appBar: DSAppBar(title: l10n.subscriptionTitle),
                body: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(context.dsSpacing.s24),
                    child: ListView(
                      children: [
                        DSSectionTitle(title: l10n.subscriptionStatusTitle),
                        SizedBox(height: context.dsSpacing.s12),
                        DSCard(
                          child: Text(
                            isPaid ? l10n.settingsPlanPaid : l10n.settingsPlanFree,
                            style: context.dsTypography.h2,
                          ),
                        ),
                        SizedBox(height: context.dsSpacing.s24),
                        DSSectionTitle(title: l10n.subscriptionTitle),
                        SizedBox(height: context.dsSpacing.s12),
                        DSCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DSButton(
                                label: isPaid ? l10n.subscriptionManage : l10n.subscriptionUpgrade,
                                fullWidth: true,
                                isLoading: profileState.isSyncingSubscription,
                                onPressed: profileState.isSyncingSubscription
                                    ? null
                                    : () async {
                                        if (isPaid) {
                                          await RevenueCatUI.presentCustomerCenter();
                                          if (!context.mounted) {
                                            return;
                                          }
                                          await context.read<ProfileCubit>().syncSubscription();
                                          if (!context.mounted) {
                                            return;
                                          }
                                          await context.read<AssetsCubit>().refresh(silent: true);
                                          return;
                                        }
                                        await context.push<bool>(
                                          AppRoutes.paywall,
                                          extra: const PaywallArgs(
                                            reason: PaywallReason.baseCurrency,
                                          ),
                                        );
                                      },
                              ),
                              SizedBox(height: context.dsSpacing.s12),
                              DSButton(
                                label: l10n.subscriptionRestore,
                                variant: DSButtonVariant.secondary,
                                fullWidth: true,
                                isLoading: profileState.isSyncingSubscription,
                                onPressed: profileState.isSyncingSubscription
                                    ? null
                                    : () async {
                                        try {
                                          await getIt<RevenueCatService>().restorePurchases();
                                          if (!context.mounted) {
                                            return;
                                          }
                                          await context.read<ProfileCubit>().syncSubscription();
                                          if (!context.mounted) {
                                            return;
                                          }
                                          await context.read<AssetsCubit>().refresh(silent: true);
                                          if (!context.mounted) {
                                            return;
                                          }
                                          showDSSnackBar(
                                            context,
                                            variant: DSSnackBarVariant.success,
                                            message: l10n.subscriptionRestoreSuccess,
                                          );
                                        } catch (_) {
                                          if (!context.mounted) {
                                            return;
                                          }
                                          showDSSnackBar(
                                            context,
                                            variant: DSSnackBarVariant.error,
                                            message: l10n.errorGeneric,
                                          );
                                        }
                                      },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
