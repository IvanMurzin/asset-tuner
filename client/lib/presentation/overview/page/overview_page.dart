import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/local_storage/guided_tour_storage.dart';
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
import 'package:asset_tuner/presentation/overview/widget/overview_guided_tour_card.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_loading_skeleton.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_summary_card.dart';
import 'package:asset_tuner/presentation/overview/widget/tour_target_highlight.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_account_item.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        if ((profileState.status == ProfileStatus.initial ||
                profileState.status == ProfileStatus.loading) &&
            profileState.profile == null) {
          return const Scaffold(body: SafeArea(child: OverviewLoadingSkeleton()));
        }

        if (profileState.status == ProfileStatus.error && profileState.profile == null) {
          return Scaffold(
            appBar: DSAppBar(title: l10n.mainTitle),
            body: DSInlineError(
              title: l10n.splashErrorTitle,
              message: profileState.failureMessage ?? l10n.errorGeneric,
              actionLabel: l10n.splashRetry,
              onAction: () => context.read<ProfileCubit>().refresh(),
            ),
          );
        }

        final baseCurrency = profileState.profile?.baseCurrency ?? 'USD';

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
                    onTap: () => context.go(AppRoutes.baseCurrencySettings),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                final accountsCubit = context.read<AccountsCubit>();
                final assetsCubit = context.read<AssetsCubit>();
                await accountsCubit.refresh();
                await assetsCubit.refresh();
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
                          padding: EdgeInsets.symmetric(horizontal: context.dsSpacing.s24),
                          child: DSInlineError(
                            title: l10n.splashErrorTitle,
                            message: accountsState.failureMessage ?? l10n.errorGeneric,
                            actionLabel: l10n.splashRetry,
                            onAction: () => context.read<AccountsCubit>().load(),
                          ),
                        ),
                      ],
                    );
                  }

                  return BlocBuilder<AssetsCubit, AssetsState>(
                    builder: (context, assetsState) {
                      return _OverviewReady(
                        accounts: accountsState.accounts,
                        profileState: profileState,
                        assetsState: assetsState,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OverviewReady extends StatefulWidget {
  const _OverviewReady({
    required this.accounts,
    required this.profileState,
    required this.assetsState,
  });

  final List<AccountEntity> accounts;
  final ProfileState profileState;
  final AssetsState assetsState;

  @override
  State<_OverviewReady> createState() => _OverviewReadyState();
}

class _OverviewReadyState extends State<_OverviewReady> {
  final GuidedTourStorage _guidedTourStorage = GuidedTourStorage();
  bool _tourVisible = false;
  int _tourStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGuidedTourState();
  }

  Future<void> _loadGuidedTourState() async {
    final completed = await _guidedTourStorage.getCompleted();
    if (!mounted || completed) {
      return;
    }
    setState(() {
      _tourVisible = true;
      _tourStepIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final baseCurrency = widget.profileState.profile?.baseCurrency ?? 'USD';
    final snapshot = widget.assetsState.snapshot;

    final baseUsdPrice = _resolveBaseUsdPrice(widget.profileState, snapshot);

    final activeAccounts = widget.accounts.where((item) => !item.archived).toList();
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

    final total = items.fold<Decimal>(Decimal.zero, (acc, item) => acc + item.total);

    final ratesText = snapshot?.asOf == null
        ? l10n.overviewRatesUnavailable
        : l10n.overviewRatesUpdatedAt(context.dsFormatters.formatDateTime(snapshot!.asOf));

    final showSummaryHighlight = _tourVisible && _tourStepIndex == 0;
    final showAddAccountHighlight = _tourVisible && _tourStepIndex == 1;

    final listContent = items.isEmpty
        ? ListView(
            children: [
              SizedBox(height: spacing.s24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                child: TourTargetHighlight(
                  isActive: showSummaryHighlight,
                  child: OverviewSummaryCard(
                    totalLabel: l10n.overviewTotalLabel,
                    totalValue: context.dsFormatters.formatMoney(Decimal.zero, baseCurrency),
                    pricedTotalLabel: null,
                    pricedTotalValue: null,
                    ratesText: ratesText,
                  ),
                ),
              ),
              SizedBox(height: spacing.s24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                child: TourTargetHighlight(
                  isActive: showAddAccountHighlight,
                  child: DSEmptyCard(
                    icon: Icons.account_balance_outlined,
                    title: l10n.overviewEmptyNoAccountsTitle,
                    message: l10n.overviewEmptyNoAccountsBody,
                    actionLabel: l10n.mainAddAccount,
                    actionLeadingIcon: Icons.add,
                    onAction: () => _openCreateAccountFlow(context),
                  ),
                ),
              ),
            ],
          )
        : ListView(
            children: [
              SizedBox(height: spacing.s24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                child: TourTargetHighlight(
                  isActive: showSummaryHighlight,
                  child: OverviewSummaryCard(
                    totalLabel: l10n.overviewTotalLabel,
                    totalValue: context.dsFormatters.formatMoney(total, baseCurrency),
                    pricedTotalLabel: null,
                    pricedTotalValue: null,
                    ratesText: ratesText,
                  ),
                ),
              ),
              SizedBox(height: spacing.s24),
              for (final section in _groupByType(items))
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
                child: TourTargetHighlight(
                  isActive: showAddAccountHighlight,
                  child: DSButton(
                    label: l10n.mainAddAccount,
                    leadingIcon: Icons.add,
                    fullWidth: true,
                    onPressed: () => _openCreateAccountFlow(context),
                  ),
                ),
              ),
              SizedBox(height: spacing.s24),
            ],
          );

    if (!_tourVisible) {
      return listContent;
    }

    final steps = _buildTourSteps(l10n);
    final step = steps[_tourStepIndex];
    final isLastStep = _tourStepIndex == steps.length - 1;

    return Stack(
      children: [
        listContent,
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(spacing.s16, spacing.s16, spacing.s16, spacing.s24),
            child: OverviewGuidedTourCard(
              title: step.title,
              body: step.body,
              progressLabel: step.progressLabel,
              nextLabel: isLastStep ? l10n.guidedTourFinish : l10n.guidedTourNext,
              skipLabel: l10n.guidedTourSkip,
              onSkip: _skipTour,
              onNext: isLastStep ? _completeTour : _nextTourStep,
            ),
          ),
        ),
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

  Decimal? _resolveBaseUsdPrice(ProfileState profileState, RatesSnapshotEntity? snapshot) {
    final baseCurrency = profileState.profile?.baseCurrency ?? 'USD';
    if (baseCurrency == 'USD') {
      return Decimal.one;
    }
    final baseAssetId = profileState.profile?.baseAssetId;
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

  Future<void> _nextTourStep() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _tourStepIndex += 1;
    });
  }

  Future<void> _skipTour() async {
    await _finishTour();
  }

  Future<void> _completeTour() async {
    await _finishTour();
  }

  Future<void> _finishTour() async {
    await _guidedTourStorage.setCompleted();
    if (!mounted) {
      return;
    }
    setState(() {
      _tourVisible = false;
      _tourStepIndex = 0;
    });
  }

  List<_OverviewTourStepData> _buildTourSteps(AppLocalizations l10n) {
    return [
      _OverviewTourStepData(
        title: l10n.guidedTourOverviewStep1Title,
        body: l10n.guidedTourOverviewStep1Body,
        progressLabel: l10n.guidedTourProgress(1, 3),
      ),
      _OverviewTourStepData(
        title: l10n.guidedTourOverviewStep2Title,
        body: l10n.guidedTourOverviewStep2Body,
        progressLabel: l10n.guidedTourProgress(2, 3),
      ),
      _OverviewTourStepData(
        title: l10n.guidedTourOverviewStep3Title,
        body: l10n.guidedTourOverviewStep3Body,
        progressLabel: l10n.guidedTourProgress(3, 3),
      ),
    ];
  }
}

class _OverviewTourStepData {
  const _OverviewTourStepData({
    required this.title,
    required this.body,
    required this.progressLabel,
  });

  final String title;
  final String body;
  final String progressLabel;
}
