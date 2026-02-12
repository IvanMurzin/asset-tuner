import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/overview/bloc/overview_cubit.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_account_card.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_loading_skeleton.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_summary_card.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OverviewBody extends StatelessWidget {
  const OverviewBody({
    super.key,
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
      return const OverviewLoadingSkeleton();
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
          OverviewSummaryCard(
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
    final groupedAccounts = _groupAccounts(state.accounts);

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
        OverviewSummaryCard(
          totalLabel: l10n.overviewTotalLabel,
          totalValue: totalText,
          pricedTotalLabel: state.hasUnpricedHoldings
              ? l10n.overviewPricedTotalLabel
              : null,
          pricedTotalValue: state.hasUnpricedHoldings ? pricedTotalText : null,
          ratesText: ratesText,
        ),
        SizedBox(height: spacing.s24),
        for (final section in groupedAccounts) ...[
          DSSectionTitle(title: _typeLabel(l10n, section.type)),
          SizedBox(height: spacing.s12),
          for (var i = 0; i < section.items.length; i++) ...[
            OverviewAccountCard(
              item: section.items[i],
              baseCurrency: baseCurrency,
              onTap: () =>
                  _openAccountDetail(context, section.items[i].accountId),
            ),
            if (i != section.items.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 20),
        ],
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

  List<({AccountType type, List<OverviewAccountItem> items})> _groupAccounts(
    List<OverviewAccountItem> accounts,
  ) {
    final byType = <AccountType, List<OverviewAccountItem>>{
      AccountType.bank: [],
      AccountType.exchange: [],
      AccountType.wallet: [],
      AccountType.cash: [],
      AccountType.other: [],
    };

    for (final item in accounts) {
      byType[item.accountType]?.add(item);
    }

    return [
      for (final type in [
        AccountType.bank,
        AccountType.exchange,
        AccountType.wallet,
        AccountType.cash,
        AccountType.other,
      ])
        if ((byType[type] ?? const []).isNotEmpty)
          (
            type: type,
            items: [...(byType[type] ?? const [])]
              ..sort((a, b) => a.accountName.compareTo(b.accountName)),
          ),
    ];
  }

  String _typeLabel(AppLocalizations l10n, AccountType type) {
    return switch (type) {
      AccountType.bank => l10n.accountsTypeBank,
      AccountType.wallet => l10n.accountsTypeCryptoWallet,
      AccountType.exchange => l10n.accountsTypeExchange,
      AccountType.cash => l10n.accountsTypeCash,
      AccountType.other => l10n.accountsTypeOther,
    };
  }
}
