import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_chip.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
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

          return Scaffold(
            appBar: DSAppBar(
              title: l10n.mainTitle,
              actions: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: spacing.s12),
                    child: DSChip(
                      label: baseCurrency,
                      icon: Icons.currency_exchange,
                      onTap: () async {
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

  Future<void> _openCreateAccountFlow(BuildContext context) async {
    final createdAccountId = await context.push<String>(AppRoutes.accountNew);
    if (!context.mounted ||
        createdAccountId == null ||
        createdAccountId.isEmpty) {
      return;
    }
    await context.read<OverviewCubit>().load();
    if (!context.mounted) {
      return;
    }
    await context.push<bool>(
      AppRoutes.accountDetail.replaceFirst(':id', createdAccountId),
    );
    if (context.mounted) {
      await context.read<OverviewCubit>().load();
    }
  }

  Future<void> _openAccountDetail(
    BuildContext context,
    String accountId,
  ) async {
    await context.push<bool>(
      AppRoutes.accountDetail.replaceFirst(':id', accountId),
    );
    if (context.mounted) {
      await context.read<OverviewCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;

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
          actionLabel: l10n.mainAddAccount,
          onAction: () => _openCreateAccountFlow(context),
          icon: Icons.account_balance_outlined,
        ),
      );
    }

    if (status == OverviewStatus.emptyNoAssets ||
        status == OverviewStatus.emptyNoBalances) {
      return ListView(
        children: [
          _SummaryCard(
            totalLabel: l10n.overviewTotalLabel,
            totalValue: _formatMoney(context, baseCurrency, Decimal.zero),
            ratesText: ratesText,
            pricedTotalLabel: null,
            pricedTotalValue: null,
          ),
          SizedBox(height: spacing.s24),
          DSEmptyState(
            title: status == OverviewStatus.emptyNoAssets
                ? l10n.subaccountEmptyTitle
                : l10n.positionHistoryEmptyTitle,
            message: status == OverviewStatus.emptyNoAssets
                ? l10n.subaccountEmptyBody
                : l10n.positionHistoryEmptyBody,
            actionLabel: l10n.mainAddAccount,
            onAction: () => _openCreateAccountFlow(context),
            icon: Icons.add_circle_outline,
          ),
        ],
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
        for (final item in state.accounts) ...[
          _AccountCard(
            item: item,
            baseCurrency: baseCurrency,
            onTap: () => _openAccountDetail(context, item.accountId),
          ),
          SizedBox(height: spacing.s12),
        ],
        SizedBox(height: spacing.s8),
        DSButton(
          label: l10n.mainAddAccount,
          leadingIcon: Icons.add,
          fullWidth: true,
          onPressed: () => _openCreateAccountFlow(context),
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
            colors.primary.withValues(alpha: 0.22),
            colors.info.withValues(alpha: 0.16),
          ],
        ),
        borderRadius: BorderRadius.circular(context.dsRadius.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            totalLabel,
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.s8),
          Text(totalValue, style: typography.h1),
          if (pricedTotalLabel != null && pricedTotalValue != null) ...[
            SizedBox(height: spacing.s12),
            Text(
              '$pricedTotalLabel: $pricedTotalValue',
              style: typography.body.copyWith(color: colors.textSecondary),
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

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.item,
    required this.baseCurrency,
    required this.onTap,
  });

  final OverviewAccountItem item;
  final String baseCurrency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final spacing = context.dsSpacing;

    final gradient = switch (item.accountType) {
      AccountType.bank => [
        colors.primary.withValues(alpha: 0.22),
        colors.surface,
      ],
      AccountType.wallet => [
        colors.info.withValues(alpha: 0.22),
        colors.surface,
      ],
      AccountType.exchange => [
        colors.success.withValues(alpha: 0.22),
        colors.surface,
      ],
      AccountType.cash => [
        colors.warning.withValues(alpha: 0.25),
        colors.surface,
      ],
      AccountType.other => [
        colors.textTertiary.withValues(alpha: 0.2),
        colors.surface,
      ],
    };

    final totalText =
        '$baseCurrency ${context.dsFormatters.formatDecimalFromDecimal(item.total, maximumFractionDigits: 2)}';

    return InkWell(
      borderRadius: BorderRadius.circular(context.dsRadius.r16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(spacing.s16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(context.dsRadius.r16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.accountName, style: typography.h3),
            SizedBox(height: spacing.s8),
            Text(
              totalText,
              style: typography.body.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: spacing.s8),
            Text(
              '${item.subaccountsCount} ${AppLocalizations.of(context)!.subaccountsCountLabel}',
              style: typography.caption.copyWith(color: colors.textSecondary),
            ),
          ],
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
          DSSkeleton(height: 18, width: 96),
          SizedBox(height: spacing.s12),
          DSSkeleton(height: 38, width: 180),
          SizedBox(height: spacing.s8),
          DSSkeleton(height: 14, width: 150),
        ],
      ),
    );
  }
}

class _AccountsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    return Column(
      children: [
        for (var i = 0; i < 4; i++) ...[
          DSCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSSkeleton(height: 20, width: 140),
                SizedBox(height: spacing.s8),
                DSSkeleton(height: 16, width: 96),
                SizedBox(height: spacing.s8),
                DSSkeleton(height: 12, width: 120),
              ],
            ),
          ),
          if (i != 3) SizedBox(height: spacing.s12),
        ],
      ],
    );
  }
}
