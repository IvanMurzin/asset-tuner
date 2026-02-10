import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<PaywallCubit>()..load(),
      child: BlocConsumer<PaywallCubit, PaywallState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<PaywallCubit>().consumeNavigation();
          switch (navigation.destination) {
            case PaywallDestination.closeUpgraded:
              context.pop(true);
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;
          final colors = context.dsColors;

          if (state.status == PaywallStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == PaywallStatus.error) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.paywallTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: l10n.errorGeneric,
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<PaywallCubit>().load(),
              ),
            );
          }

          final isPaid = (state.plan ?? 'free') == 'paid';

          return Scaffold(
            appBar: DSAppBar(title: l10n.paywallTitle),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(spacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DSCard(
                              padding: EdgeInsets.zero,
                              bordered: false,
                              elevation: DSElevationLevel.level0,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(
                                  spacing.s16 + spacing.s4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colors.primary.withValues(alpha: 0.26),
                                      colors.info.withValues(alpha: 0.18),
                                      colors.surface.withValues(alpha: 0.0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    context.dsRadius.r16,
                                  ),
                                  border: Border.all(
                                    color: colors.border.withValues(alpha: 0.7),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: spacing.s32 + spacing.s12,
                                          height: spacing.s32 + spacing.s12,
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
                                            Icons.workspace_premium_outlined,
                                            color: colors.primary,
                                          ),
                                        ),
                                        SizedBox(width: spacing.s12),
                                        Expanded(
                                          child: Text(
                                            l10n.paywallHeader,
                                            style: typography.h2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: spacing.s12),
                                    Text(
                                      l10n.paywallBody,
                                      style: typography.body.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: spacing.s16 + spacing.s4),
                            DSSectionTitle(title: l10n.paywallIncludesTitle),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FeatureRow(
                                    text: l10n.paywallFeatureCurrencies,
                                  ),
                                  SizedBox(height: spacing.s12),
                                  _FeatureRow(text: l10n.paywallFeatureUpdates),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.s16 + spacing.s4),
                            DSCard(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _PlanPill(
                                      title: l10n.settingsPlanFree,
                                      selected: !isPaid,
                                    ),
                                  ),
                                  SizedBox(width: spacing.s12),
                                  Expanded(
                                    child: _PlanPill(
                                      title: l10n.settingsPlanPaid,
                                      selected: isPaid,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isPaid) ...[
                              SizedBox(height: spacing.s16),
                              DSInlineBanner(
                                title: l10n.paywallTitle,
                                message: l10n.paywallAlreadyPaid,
                                variant: DSInlineBannerVariant.success,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.s16),
                    DSButton(
                      label: l10n.subscriptionUpgrade,
                      fullWidth: true,
                      isLoading: state.isUpdating,
                      onPressed: isPaid || state.isUpdating
                          ? null
                          : () => context.read<PaywallCubit>().upgrade(),
                    ),
                    SizedBox(height: spacing.s12),
                    DSButton(
                      label: l10n.paywallDismiss,
                      variant: DSButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: () => context.pop(false),
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
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: colors.primary, size: spacing.s16),
        SizedBox(width: spacing.s12),
        Expanded(child: Text(text, style: typography.body)),
      ],
    );
  }
}

class _PlanPill extends StatelessWidget {
  const _PlanPill({required this.title, required this.selected});

  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final radius = context.dsRadius;
    final typography = context.dsTypography;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s12,
        vertical: spacing.s12,
      ),
      decoration: BoxDecoration(
        color: selected
            ? colors.primary.withValues(alpha: 0.10)
            : colors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius.r12),
        border: Border.all(
          color: selected
              ? colors.primary.withValues(alpha: 0.55)
              : colors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? Icons.check_circle : Icons.circle_outlined,
            color: selected ? colors.primary : colors.textTertiary,
            size: spacing.s16,
          ),
          SizedBox(width: spacing.s8),
          Flexible(
            child: Text(
              title,
              style: typography.button.copyWith(
                color: selected ? colors.textPrimary : colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
