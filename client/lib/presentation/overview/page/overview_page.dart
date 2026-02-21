import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/route_extra_args.dart';
import 'package:asset_tuner/core/utils/decimal_math.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_chip.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_card.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_account_card.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_loading_skeleton.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_summary_card.dart';
import 'package:asset_tuner/presentation/rate/bloc/usd_rates_cubit.dart';
import 'package:asset_tuner/presentation/user/bloc/user_cubit.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_account_item.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<UserCubit, UserState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == UserStatus.unauthenticated) {
          context.go(AppRoutes.signIn);
        }
      },
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          final baseCurrency = userState.profile?.baseCurrency ?? 'USD';

          return Scaffold(
            appBar: DSAppBar(
              title: l10n.mainTitle,
              actions: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: context.dsSpacing.s12),
                    child: DSChip(
                      label: baseCurrency,
                      icon: Icons.currency_exchange,
                      onTap: () =>
                          context.push<String>(AppRoutes.baseCurrencySettings),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  final accountsCubit = context.read<AccountsCubit>();
                  final usdRatesCubit = context.read<UsdRatesCubit>();
                  await accountsCubit.refresh();
                  await usdRatesCubit.refresh();
                },
                child: BlocBuilder<AccountsCubit, AccountsState>(
                  builder: (context, accountsState) {
                    if (accountsState.status == AccountsStatus.loading &&
                        accountsState.accounts.isEmpty) {
                      return const OverviewLoadingSkeleton();
                    }

                    if (accountsState.status == AccountsStatus.error &&
                        accountsState.accounts.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: context.dsSpacing.s24),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.dsSpacing.s24,
                            ),
                            child: DSInlineError(
                              title: l10n.splashErrorTitle,
                              message:
                                  accountsState.failureMessage ??
                                  l10n.errorGeneric,
                              actionLabel: l10n.splashRetry,
                              onAction: () =>
                                  context.read<AccountsCubit>().load(),
                            ),
                          ),
                        ],
                      );
                    }

                    return BlocBuilder<UsdRatesCubit, UsdRatesState>(
                      builder: (context, ratesState) {
                        return _OverviewReady(
                          accounts: accountsState.accounts,
                          userState: userState,
                          ratesState: ratesState,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OverviewReady extends StatelessWidget {
  const _OverviewReady({
    required this.accounts,
    required this.userState,
    required this.ratesState,
  });

  final List<AccountEntity> accounts;
  final UserState userState;
  final UsdRatesState ratesState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final baseCurrency = userState.profile?.baseCurrency ?? 'USD';
    final snapshot = ratesState.snapshot;

    final baseUsdPrice = _resolveBaseUsdPrice(userState, snapshot);

    final activeAccounts = accounts.where((item) => !item.archived).toList();
    final items =
        activeAccounts
            .map(
              (account) => OverviewAccountItem(
                accountId: account.id,
                accountName: account.name,
                accountType: account.type,
                total: _toBase(
                  totalUsd: account.totals?.totalUsd,
                  baseCurrency: baseCurrency,
                  baseUsdPrice: baseUsdPrice,
                ),
                subaccountsCount: account.subaccountsCount ?? 0,
                hasUnpricedHoldings: false,
              ),
            )
            .toList()
          ..sort((a, b) => a.accountName.compareTo(b.accountName));

    final total = items.fold<Decimal>(
      Decimal.zero,
      (acc, item) => acc + item.total,
    );

    final ratesText = snapshot?.asOf == null
        ? l10n.overviewRatesUnavailable
        : l10n.overviewRatesUpdatedAt(
            context.dsFormatters.formatDateTime(snapshot!.asOf),
          );

    if (items.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: spacing.s24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.s24),
            child: OverviewSummaryCard(
              totalLabel: l10n.overviewTotalLabel,
              totalValue: context.dsFormatters.formatMoney(
                Decimal.zero,
                baseCurrency,
              ),
              pricedTotalLabel: null,
              pricedTotalValue: null,
              ratesText: ratesText,
            ),
          ),
          SizedBox(height: spacing.s24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.s24),
            child: DSEmptyCard(
              icon: Icons.account_balance_outlined,
              title: l10n.overviewEmptyNoAccountsTitle,
              message: l10n.overviewEmptyNoAccountsBody,
              actionLabel: l10n.mainAddAccount,
              actionLeadingIcon: Icons.add,
              onAction: () => _openCreateAccountFlow(context),
            ),
          ),
        ],
      );
    }

    final grouped = _groupByType(items);

    return ListView(
      children: [
        SizedBox(height: spacing.s24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s24),
          child: OverviewSummaryCard(
            totalLabel: l10n.overviewTotalLabel,
            totalValue: context.dsFormatters.formatMoney(total, baseCurrency),
            pricedTotalLabel: null,
            pricedTotalValue: null,
            ratesText: ratesText,
          ),
        ),
        SizedBox(height: spacing.s24),
        for (final section in grouped)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSSectionTitle(title: _typeLabel(l10n, section.type)),
                SizedBox(height: spacing.s12),
                for (var i = 0; i < section.items.length; i++) ...[
                  OverviewAccountCard(
                    item: section.items[i],
                    baseCurrency: baseCurrency,
                    onTap: () => context.push(
                      AppRoutes.accountDetail.replaceFirst(
                        ':accountId',
                        section.items[i].accountId,
                      ),
                      extra: AccountDetailExtra(
                        initialTitle: section.items[i].accountName,
                        initialAccountType: section.items[i].accountType,
                      ),
                    ),
                  ),
                  if (i != section.items.length - 1) const SizedBox(height: 10),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s24),
          child: DSButton(
            label: l10n.mainAddAccount,
            leadingIcon: Icons.add,
            fullWidth: true,
            onPressed: () => _openCreateAccountFlow(context),
          ),
        ),
        SizedBox(height: spacing.s24),
      ],
    );
  }

  Decimal _toBase({
    required Decimal? totalUsd,
    required String baseCurrency,
    required Decimal? baseUsdPrice,
  }) {
    final usd = totalUsd ?? Decimal.zero;
    if (baseCurrency == 'USD') {
      return usd;
    }
    if (baseUsdPrice == null || baseUsdPrice == Decimal.zero) {
      return Decimal.zero;
    }
    return divideToDecimal(usd, baseUsdPrice);
  }

  Decimal? _resolveBaseUsdPrice(
    UserState userState,
    RatesSnapshotEntity? snapshot,
  ) {
    final baseCurrency = userState.profile?.baseCurrency ?? 'USD';
    if (baseCurrency == 'USD') {
      return Decimal.one;
    }
    final baseAssetId = userState.profile?.baseAssetId;
    if (baseAssetId == null) {
      return null;
    }
    return snapshot?.usdPriceByAssetId[baseAssetId];
  }

  List<({AccountType type, List<OverviewAccountItem> items})> _groupByType(
    List<OverviewAccountItem> items,
  ) {
    final byType = <AccountType, List<OverviewAccountItem>>{
      AccountType.bank: [],
      AccountType.exchange: [],
      AccountType.wallet: [],
      AccountType.cash: [],
      AccountType.other: [],
    };

    for (final item in items) {
      byType[item.accountType]!.add(item);
    }

    final ordered = <({AccountType type, List<OverviewAccountItem> items})>[];
    for (final type in const [
      AccountType.bank,
      AccountType.exchange,
      AccountType.wallet,
      AccountType.cash,
      AccountType.other,
    ]) {
      final section = byType[type]!;
      if (section.isNotEmpty) {
        ordered.add((type: type, items: section));
      }
    }
    return ordered;
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

  Future<void> _openCreateAccountFlow(BuildContext context) async {
    await context.push<String>(AppRoutes.accountNew);
  }
}
