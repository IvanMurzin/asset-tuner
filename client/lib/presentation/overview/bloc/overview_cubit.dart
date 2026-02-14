import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/local_storage/overview_cache_storage.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/core/utils/decimal_math.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/usecase/get_account_assets_usecase.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/balance/usecase/get_current_balances_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/usecase/get_latest_usd_rates_usecase.dart';

part 'overview_cubit.freezed.dart';
part 'overview_state.dart';

enum OverviewDestination { signIn }

@injectable
class OverviewCubit extends Cubit<OverviewState> {
  OverviewCubit(
    this._getCachedSession,
    this._getProfile,
    this._bootstrapProfile,
    this._getAccounts,
    this._getAccountAssets,
    this._getAssets,
    this._getCurrentBalances,
    this._getLatestUsdRates,
    this._cache,
  ) : super(const OverviewState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final GetAccountsUseCase _getAccounts;
  final GetAccountAssetsUseCase _getAccountAssets;
  final GetAssetsUseCase _getAssets;
  final GetCurrentBalancesUseCase _getCurrentBalances;
  final GetLatestUsdRatesUseCase _getLatestUsdRates;
  final OverviewCacheStorage _cache;

  Future<void> load() async {
    emit(state.copyWith(status: OverviewStatus.loading, failureCode: null, failureMessage: null));
    await _fetchAndEmit(silent: false);
  }

  Future<void> refresh() async {
    await _fetchAndEmit(silent: true);
  }

  Future<void> _fetchAndEmit({required bool silent}) async {
    void maybeEmit(OverviewState next) {
      if (isClosed) return;
      if (silent) {
        if (next != state || next.navigation != null) {
          emit(next);
        }
      } else {
        emit(next);
      }
    }

    final session = await _getCachedSession();
    if (session == null) {
      maybeEmit(
        state.copyWith(
          status: OverviewStatus.error,
          failureCode: 'unauthorized',
          navigation: const OverviewNavigation(
            destination: OverviewDestination.signIn,
          ),
        ),
      );
      return;
    }

    final profile = await _loadProfile();
    if (profile == null) {
      await _tryUseCache(session.userId, emit: maybeEmit);
      return;
    }

    final rates = await _getLatestUsdRates();
    final ratesSnapshot = switch (rates) {
      Success<RatesSnapshotEntity?>(value: final snapshot) => snapshot,
      FailureResult<RatesSnapshotEntity?>() => null,
    };

    final accounts = await _getAccounts();
    final accountsList = switch (accounts) {
      Success<List<AccountEntity>>(value: final list) => list,
      FailureResult<List<AccountEntity>>() => null,
    };
    if (accountsList == null) {
      final failure =
          (accounts as FailureResult<List<AccountEntity>>).failure;
      await _tryUseCache(
        session.userId,
        failureCode: failure.code,
        failureMessage: failure.message,
        emit: maybeEmit,
      );
      return;
    }

    final activeAccounts = accountsList.where((a) => !a.archived).toList();
    if (activeAccounts.isEmpty) {
      maybeEmit(
        state.copyWith(
          status: OverviewStatus.emptyNoAccounts,
          baseCurrency: profile.baseCurrency,
          ratesAsOf: ratesSnapshot?.asOf,
        ),
      );
      return;
    }

    final assetsResult = await _getAssets();
    final assets = switch (assetsResult) {
      Success<List<AssetEntity>>(value: final list) => list,
      FailureResult<List<AssetEntity>>() => null,
    };
    if (assets == null) {
      final failure =
          (assetsResult as FailureResult<List<AssetEntity>>).failure;
      await _tryUseCache(
        session.userId,
        failureCode: failure.code,
        failureMessage: failure.message,
        emit: maybeEmit,
      );
      return;
    }
    final assetsById = {for (final a in assets) a.id: a};
    final baseAsset = assets
        .where((a) => a.code == profile.baseCurrency)
        .firstOrNull;

    final positionsByAccount = <String, List<AccountAssetEntity>>{};
    for (final account in activeAccounts) {
      final positions = await _getAccountAssets(accountId: account.id);
      switch (positions) {
        case Success<List<AccountAssetEntity>>(value: final list):
          positionsByAccount[account.id] = list;
        case FailureResult<List<AccountAssetEntity>>(failure: final failure):
          await _tryUseCache(
            session.userId,
            failureCode: failure.code,
            failureMessage: failure.message,
            emit: maybeEmit,
          );
          return;
      }
    }

    final allPositionIds = positionsByAccount.values
        .expand((e) => e.map((p) => p.id))
        .toSet();
    Map<String, Decimal> currentByPosition = const <String, Decimal>{};
    if (allPositionIds.isNotEmpty) {
      final balances = await _getCurrentBalances(subaccountIds: allPositionIds);
      final balancesMap = switch (balances) {
        Success<Map<String, Decimal>>(value: final map) => map,
        FailureResult<Map<String, Decimal>>() => null,
      };
      if (balancesMap == null) {
        final failure =
            (balances as FailureResult<Map<String, Decimal>>).failure;
        await _tryUseCache(
          session.userId,
          failureCode: failure.code,
          failureMessage: failure.message,
          emit: maybeEmit,
        );
        return;
      }
      currentByPosition = balancesMap;
    }

    final baseUsdPrice = _baseUsdPrice(
      baseCurrencyCode: profile.baseCurrency,
      baseAssetId: baseAsset?.id,
      snapshot: ratesSnapshot,
    );

    final unpriced = <OverviewUnpricedHolding>[];
    var hasUnpriced = false;
    var globalPricedTotal = Decimal.zero;

    final accountItems = <OverviewAccountItem>[];
    for (final account in activeAccounts) {
      final positions = positionsByAccount[account.id] ?? const [];
      var accountTotal = Decimal.zero;
      var accountHasUnpriced = false;

      for (final position in positions) {
        final original = currentByPosition[position.id];
        if (original == null || original == Decimal.zero) {
          continue;
        }
        final asset = assetsById[position.assetId];
        final assetCode = asset?.code ?? '?';
        final assetUsd = ratesSnapshot?.usdPriceByAssetId[position.assetId];
        if (baseUsdPrice == null || ratesSnapshot == null || assetUsd == null) {
          hasUnpriced = true;
          accountHasUnpriced = true;
          unpriced.add(
            OverviewUnpricedHolding(assetCode: assetCode, amount: original),
          );
          continue;
        }
        final baseValue = divideToDecimal(original * assetUsd, baseUsdPrice);
        accountTotal += baseValue;
        globalPricedTotal += baseValue;
      }

      accountItems.add(
        OverviewAccountItem(
          accountId: account.id,
          accountName: account.name,
          accountType: account.type,
          total: accountTotal,
          subaccountsCount: positions.length,
          hasUnpricedHoldings: accountHasUnpriced,
        ),
      );
    }
    final globalFullTotal = hasUnpriced ? null : globalPricedTotal;

    final computedAt = DateTime.now();
    await _cache.writeSnapshot(
      session.userId,
      StoredOverviewSnapshot(
        computedAtIso: computedAt.toIso8601String(),
        baseCurrencyCode: profile.baseCurrency,
        fullTotal: globalFullTotal?.toString(),
        pricedTotal: hasUnpriced ? globalPricedTotal.toString() : null,
        hasUnpricedHoldings: hasUnpriced,
        ratesAsOfIso: ratesSnapshot?.asOf.toIso8601String(),
        accountTotals: accountItems
            .map(
              (a) => StoredOverviewAccountTotal(
                accountId: a.accountId,
                accountName: a.accountName,
                total: a.total.toString(),
                hasUnpriced: a.hasUnpricedHoldings,
              ),
            )
            .toList(),
        unpricedHoldings: unpriced
            .map(
              (u) => StoredUnpricedHolding(
                assetCode: u.assetCode,
                amount: u.amount.toString(),
              ),
            )
            .toList(),
      ),
    );

    maybeEmit(
      state.copyWith(
        status: OverviewStatus.ready,
        baseCurrency: profile.baseCurrency,
        ratesAsOf: ratesSnapshot?.asOf,
        fullTotal: globalFullTotal,
        pricedTotal: hasUnpriced ? globalPricedTotal : null,
        hasUnpricedHoldings: hasUnpriced,
        accounts: accountItems
          ..sort((a, b) => a.accountName.compareTo(b.accountName)),
        unpricedHoldings: unpriced,
        isOffline: false,
        offlineCachedAt: null,
      ),
    );
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<ProfileEntity?> _loadProfile() async {
    final result = await _getProfile();
    switch (result) {
      case Success<ProfileEntity>(value: final profile):
        return profile;
      case FailureResult<ProfileEntity>():
        final bootstrap = await _bootstrapProfile();
        switch (bootstrap) {
          case Success(value: final data):
            return data.profile;
          case FailureResult():
            return null;
        }
    }
  }

  Future<void> _tryUseCache(
    String userId, {
    String? failureCode,
    String? failureMessage,
    void Function(OverviewState)? emit,
  }) async {
    final doEmit = emit ?? this.emit;
    final cached = await _cache.readSnapshot(userId);
    if (isClosed) return;
    if (cached == null) {
      doEmit(
        state.copyWith(
          status: OverviewStatus.error,
          failureCode: failureCode ?? 'unknown',
          failureMessage: failureMessage,
        ),
      );
      return;
    }

    doEmit(
      state.copyWith(
        status: OverviewStatus.ready,
        baseCurrency: cached.baseCurrencyCode,
        ratesAsOf: cached.ratesAsOf,
        fullTotal: cached.fullTotalDecimal,
        pricedTotal: cached.pricedTotalDecimal,
        hasUnpricedHoldings: cached.hasUnpricedHoldings,
        accounts:
            cached.accountTotals
                .map(
                  (a) => OverviewAccountItem(
                    accountId: a.accountId,
                    accountName: a.accountName,
                    accountType: AccountType.other,
                    total: a.totalDecimal ?? Decimal.zero,
                    subaccountsCount: 0,
                    hasUnpricedHoldings: a.hasUnpriced,
                  ),
                )
                .toList()
              ..sort((a, b) => a.accountName.compareTo(b.accountName)),
        unpricedHoldings: cached.unpricedHoldings
            .map(
              (u) => OverviewUnpricedHolding(
                assetCode: u.assetCode,
                amount: u.amountDecimal,
              ),
            )
            .toList(),
        isOffline: true,
        offlineCachedAt: cached.computedAt,
        failureCode: failureCode,
        failureMessage: failureMessage,
      ),
    );
  }
}

Decimal? _baseUsdPrice({
  required String baseCurrencyCode,
  required String? baseAssetId,
  required RatesSnapshotEntity? snapshot,
}) {
  if (baseCurrencyCode == 'USD') {
    return Decimal.one;
  }
  if (baseAssetId == null) {
    return null;
  }
  return snapshot?.usdPriceByAssetId[baseAssetId];
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }
}
