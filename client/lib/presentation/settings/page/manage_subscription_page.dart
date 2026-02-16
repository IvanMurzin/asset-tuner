import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/settings/bloc/manage_subscription_cubit.dart';

class ManageSubscriptionPage extends StatelessWidget {
  const ManageSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<ManageSubscriptionCubit>()..load(),
      child: BlocBuilder<ManageSubscriptionCubit, ManageSubscriptionState>(
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;
          final colors = context.dsColors;

          if (state.status == ManageSubscriptionStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == ManageSubscriptionStatus.error) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.subscriptionTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: l10n.errorGeneric,
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<ManageSubscriptionCubit>().load(),
              ),
            );
          }

          final bannerText = _bannerText(l10n, state.banner);

          final planText = (state.plan ?? 'free') == 'paid'
              ? l10n.settingsPlanPaid
              : l10n.settingsPlanFree;
          final isPaid = (state.plan ?? 'free') == 'paid';

          return Scaffold(
            appBar: DSAppBar(title: l10n.subscriptionTitle),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(spacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bannerText != null) ...[
                      DSInlineBanner(
                        title: l10n.subscriptionTitle,
                        message: bannerText,
                        variant:
                            state.banner ==
                                ManageSubscriptionBanner.updateFailure
                            ? DSInlineBannerVariant.danger
                            : DSInlineBannerVariant.success,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DSSectionTitle(title: l10n.subscriptionStatusTitle),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              padding: EdgeInsets.zero,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(spacing.s16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colors.primary.withValues(alpha: 0.16),
                                      colors.surface.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: spacing.s32 + spacing.s8,
                                          height: spacing.s32 + spacing.s8,
                                          decoration: BoxDecoration(
                                            color: colors.surface,
                                            borderRadius: BorderRadius.circular(
                                              context.dsRadius.r16,
                                            ),
                                            border: Border.all(
                                              color: colors.border,
                                            ),
                                          ),
                                          child: Icon(
                                            isPaid
                                                ? Icons
                                                      .workspace_premium_outlined
                                                : Icons.lock_open_outlined,
                                            color: colors.primary,
                                          ),
                                        ),
                                        SizedBox(width: spacing.s12),
                                        Expanded(
                                          child: Text(
                                            planText,
                                            style: typography.h2,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: spacing.s12),
                                    Text(
                                      isPaid
                                          ? l10n.subscriptionPaidBody
                                          : l10n.subscriptionFreeBody,
                                      style: typography.body.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: spacing.s16 + spacing.s4),
                            DSSectionTitle(title: l10n.subscriptionTitle),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DSButton(
                                    label: isPaid
                                        ? l10n.subscriptionManage
                                        : l10n.subscriptionUpgrade,
                                    fullWidth: true,
                                    isLoading: state.isUpdating,
                                    onPressed: state.isUpdating
                                        ? null
                                        : () => _onManageOrUpgrade(
                                              context,
                                              isPaid,
                                            ),
                                  ),
                                  SizedBox(height: spacing.s12),
                                  DSButton(
                                    label: l10n.subscriptionRestore,
                                    variant: DSButtonVariant.secondary,
                                    fullWidth: true,
                                    isLoading: state.isUpdating,
                                    onPressed: state.isUpdating
                                        ? null
                                        : () => context
                                              .read<ManageSubscriptionCubit>()
                                              .restore(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Future<void> _onManageOrUpgrade(
    BuildContext context,
    bool isPaid,
  ) async {
    final cubit = context.read<ManageSubscriptionCubit>();
    if (isPaid) {
      await RevenueCatUI.presentCustomerCenter();
      cubit.onCustomerCenterClosed();
    } else {
      await RevenueCatUI.presentPaywall(displayCloseButton: true);
      cubit.load();
    }
  }

  String? _bannerText(AppLocalizations l10n, ManageSubscriptionBanner? banner) {
    return switch (banner) {
      ManageSubscriptionBanner.manageSuccess => l10n.subscriptionManageSuccess,
      ManageSubscriptionBanner.restoreSuccess =>
        l10n.subscriptionRestoreSuccess,
      ManageSubscriptionBanner.cancelSuccess => l10n.subscriptionCancelSuccess,
      ManageSubscriptionBanner.updateFailure => l10n.settingsEntitlementsError,
      null => null,
    };
  }
}
