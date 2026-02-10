import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_chip.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/presentation/overview/bloc/overview_cubit.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  String _ratesText(
    BuildContext context,
    AppLocalizations l10n,
    DateTime? asOf,
  ) {
    if (asOf == null) {
      return l10n.overviewRatesUnavailable;
    }
    return l10n.overviewRatesUpdatedAt(
      context.dsFormatters.formatDateTime(asOf),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<OverviewCubit>()..load(),
      child: BlocConsumer<OverviewCubit, OverviewState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<OverviewCubit>().consumeNavigation();
          switch (navigation.destination) {
            case OverviewDestination.signIn:
              context.go(AppRoutes.signIn);
          }
        },
        builder: (context, state) {
          final baseCurrency = state.baseCurrency ?? 'USD';
          final canMutate = !state.isOffline;

          return Scaffold(
            appBar: DSAppBar(
              title: l10n.overviewTitle,
              actions: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: spacing.s12),
                    child: DSChip(
                      label: baseCurrency,
                      icon: Icons.currency_exchange,
                      onTap: !canMutate
                          ? null
                          : () async {
                              await context.push<String>(
                                AppRoutes.baseCurrencySettings,
                              );
                              if (context.mounted) {
                                await context.read<OverviewCubit>().load();
                              }
                            },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.push(AppRoutes.settings),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => context.read<OverviewCubit>().load(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.s24,
                    spacing.s24,
                    spacing.s24,
                    spacing.s16,
                  ),
                  child: _OverviewBody(
                    state: state,
                    baseCurrency: baseCurrency,
                    ratesText: _ratesText(context, l10n, state.ratesAsOf),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({
    required this.state,
    required this.baseCurrency,
    required this.ratesText,
  });

  final OverviewState state;
  final String baseCurrency;
  final String ratesText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;

    final status = state.status;
    if (status == OverviewStatus.loading) {
      return ListView(
        children: [
          _SummarySkeleton(),
          SizedBox(height: spacing.s24),
          _AccountsSkeleton(),
        ],
      );
    }

    if (status == OverviewStatus.error) {
      return ListView(
        children: [
          DSInlineError(
            title: l10n.splashErrorTitle,
            message: _failureMessage(l10n, state.failureCode),
            actionLabel: l10n.splashRetry,
            onAction: () => context.read<OverviewCubit>().load(),
          ),
        ],
      );
    }

    if (status == OverviewStatus.emptyNoAccounts) {
      return Center(
        child: DSEmptyState(
          title: l10n.overviewEmptyNoAccountsTitle,
          message: l10n.overviewEmptyNoAccountsBody,
          actionLabel: l10n.overviewEmptyNoAccountsCta,
          onAction: () => context.push(AppRoutes.accountNew),
          icon: Icons.account_balance_outlined,
        ),
      );
    }

    if (status == OverviewStatus.emptyNoAssets) {
      return Center(
        child: DSEmptyState(
          title: l10n.overviewEmptyNoAssetsTitle,
          message: l10n.overviewEmptyNoAssetsBody,
          actionLabel: l10n.overviewEmptyNoAssetsCta,
          onAction: () => context.push(AppRoutes.accounts),
          icon: Icons.add_circle_outline,
        ),
      );
    }

    if (status == OverviewStatus.emptyNoBalances) {
      return Center(
        child: DSEmptyState(
          title: l10n.overviewEmptyNoBalancesTitle,
          message: l10n.overviewEmptyNoBalancesBody,
          actionLabel: l10n.overviewEmptyNoBalancesCta,
          onAction: () => context.push(AppRoutes.accounts),
          icon: Icons.timeline_outlined,
        ),
      );
    }

    final totalText = state.fullTotal == null
        ? l10n.notAvailable
        : _formatMoney(context, baseCurrency, state.fullTotal!);
    final pricedTotalText = state.pricedTotal == null
        ? null
        : _formatMoney(context, baseCurrency, state.pricedTotal!);

    return ListView(
      children: [
        if (state.isOffline) ...[
          DSInlineBanner(
            title: l10n.offlineTitle,
            message: l10n.offlineShowingLastSaved(
              context.dsFormatters.formatDateTime(
                state.offlineCachedAt ?? DateTime.now(),
              ),
            ),
            variant: DSInlineBannerVariant.warning,
          ),
          SizedBox(height: spacing.s16),
        ],
        _SummaryCard(
          totalLabel: l10n.overviewTotalLabel,
          totalValue: totalText,
          pricedTotalLabel: state.hasUnpricedHoldings
              ? l10n.overviewPricedTotalLabel
              : null,
          pricedTotalValue: state.hasUnpricedHoldings ? pricedTotalText : null,
          ratesText: ratesText,
        ),
        SizedBox(height: spacing.s24),
        DSSectionTitle(title: l10n.accountsActiveSection),
        SizedBox(height: spacing.s12),
        DSCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < state.accounts.length; i++) ...[
                _AccountRow(
                  item: state.accounts[i],
                  baseCurrency: baseCurrency,
                ),
                if (i != state.accounts.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
        if (state.hasUnpricedHoldings) ...[
          SizedBox(height: spacing.s24),
          DSInlineBanner(
            title: l10n.overviewMissingRatesTitle,
            message: l10n.overviewMissingRatesBody,
            variant: DSInlineBannerVariant.warning,
          ),
          SizedBox(height: spacing.s16),
          DSSectionTitle(title: l10n.overviewUnpricedHoldingsTitle),
          SizedBox(height: spacing.s12),
          DSCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < state.unpricedHoldings.length; i++) ...[
                  _UnpricedRow(item: state.unpricedHoldings[i]),
                  if (i != state.unpricedHoldings.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
        SizedBox(height: spacing.s16),
        Text(
          l10n.pullToRefreshHint,
          style: typography.caption.copyWith(color: colors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _failureMessage(AppLocalizations l10n, String? code) {
    return switch (code) {
      'network' => l10n.errorNetwork,
      'unauthorized' => l10n.errorUnauthorized,
      'forbidden' => l10n.errorForbidden,
      'not_found' => l10n.errorNotFound,
      'validation' => l10n.errorValidation,
      'conflict' => l10n.errorConflict,
      'rate_limited' => l10n.errorRateLimited,
      _ => l10n.errorGeneric,
    };
  }

  String _formatMoney(BuildContext context, String code, Decimal value) {
    return '$code ${context.dsFormatters.formatDecimalFromDecimal(value, maximumFractionDigits: 2)}';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalLabel,
    required this.totalValue,
    required this.pricedTotalLabel,
    required this.pricedTotalValue,
    required this.ratesText,
  });

  final String totalLabel;
  final String totalValue;
  final String? pricedTotalLabel;
  final String? pricedTotalValue;
  final String ratesText;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.s24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.18),
            colors.info.withValues(alpha: 0.16),
          ],
        ),
        borderRadius: BorderRadius.circular(context.dsRadius.r16),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(totalLabel, style: typography.h3),
          SizedBox(height: spacing.s8),
          Text(
            totalValue,
            style: typography.totalNumeric.copyWith(color: colors.textPrimary),
          ),
          if (pricedTotalLabel != null && pricedTotalValue != null) ...[
            SizedBox(height: spacing.s12),
            Text(
              pricedTotalLabel!,
              style: typography.caption.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.s4),
            Text(
              pricedTotalValue!,
              style: typography.h2.copyWith(color: colors.textPrimary),
            ),
          ],
          SizedBox(height: spacing.s12),
          Text(
            ratesText,
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.item, required this.baseCurrency});

  final OverviewAccountItem item;
  final String baseCurrency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trailing = item.hasUnpricedHoldings
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.notAvailable,
                style: context.dsTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.dsColors.textPrimary,
                ),
              ),
              SizedBox(height: context.dsSpacing.s4),
              Text(
                l10n.overviewPartialHint,
                style: context.dsTypography.caption.copyWith(
                  color: context.dsColors.textSecondary,
                ),
              ),
            ],
          )
        : Text(
            '$baseCurrency ${context.dsFormatters.formatDecimalFromDecimal(item.total, maximumFractionDigits: 2)}',
            style: context.dsTypography.body.copyWith(
              fontWeight: FontWeight.w700,
              color: context.dsColors.textPrimary,
            ),
          );

    return DSListRow(
      title: item.accountName,
      trailing: trailing,
      onTap: () => context.push(
        AppRoutes.accountDetail.replaceFirst(':id', item.accountId),
      ),
    );
  }
}

class _UnpricedRow extends StatelessWidget {
  const _UnpricedRow({required this.item});

  final OverviewUnpricedHolding item;

  @override
  Widget build(BuildContext context) {
    final amountText = context.dsFormatters.formatDecimalFromDecimal(
      item.amount,
      maximumFractionDigits: 8,
    );
    return DSListRow(
      title: item.assetCode,
      trailing: Text(
        amountText,
        style: context.dsTypography.body.copyWith(
          fontWeight: FontWeight.w700,
          color: context.dsColors.textPrimary,
        ),
      ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DSSkeleton(width: 120, height: 16),
          SizedBox(height: spacing.s12),
          const DSSkeleton(width: 200, height: 32),
          SizedBox(height: spacing.s12),
          const DSSkeleton(width: 160, height: 14),
        ],
      ),
    );
  }
}

class _AccountsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    return DSCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < 4; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s16,
                vertical: spacing.s12,
              ),
              child: Row(
                children: [
                  const Expanded(child: DSSkeleton(height: 14)),
                  SizedBox(width: spacing.s12),
                  const DSSkeleton(width: 72, height: 14),
                ],
              ),
            ),
            if (i != 3) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
