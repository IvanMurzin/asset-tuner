import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/core/utils/decimal_math.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';
import 'package:asset_tuner/domain/balance/usecase/get_balance_history_usecase.dart';
import 'package:asset_tuner/domain/balance/usecase/get_current_balances_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/usecase/get_latest_usd_rates_usecase.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/domain/subaccount/usecase/get_subaccounts_usecase.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'analytics_cubit.freezed.dart';
part 'analytics_state.dart';

enum AnalyticsDestination { signIn }

@injectable
class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit(
    this._getCachedSession,
    this._getProfile,
    this._getSubaccounts,
    this._getAssets,
    this._getCurrentBalances,
    this._getHistory,
    this._getLatestUsdRates,
  ) : super(const AnalyticsState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final GetSubaccountsUseCase _getSubaccounts;
  final GetAssetsUseCase _getAssets;
  final GetCurrentBalancesUseCase _getCurrentBalances;
  final GetBalanceHistoryUseCase _getHistory;
  final GetLatestUsdRatesUseCase _getLatestUsdRates;

  List<AccountEntity> _accounts = const <AccountEntity>[];
  bool _isFetching = false;
  bool _queuedFetch = false;
  bool _queuedSilent = true;

  Future<void> load() async {
    await _fetch(silent: false);
  }

  Future<void> refresh() async {
    if (state.status != AnalyticsStatus.ready) {
      return;
    }
    await _fetch(silent: true);
  }

  Future<void> onAccountsChanged(List<AccountEntity> accounts) async {
    final nextAccounts = accounts.where((a) => !a.archived).toList(growable: false);
    if (_sameAccounts(_accounts, nextAccounts)) {
      return;
    }
    _accounts = nextAccounts;
    await _fetch(silent: state.status == AnalyticsStatus.ready);
  }

  Future<void> _fetch({required bool silent}) async {
    if (_isFetching) {
      _queuedFetch = true;
      _queuedSilent = _queuedSilent && silent;
      return;
    }

    _isFetching = true;
    try {
      if (!silent) {
        emit(
          state.copyWith(status: AnalyticsStatus.loading, failureCode: null, failureMessage: null),
        );
      }

      final session = await _getCachedSession();
      if (isClosed) return;
      if (session == null) {
        emit(
          state.copyWith(
            status: AnalyticsStatus.error,
            failureCode: 'unauthorized',
            navigation: const AnalyticsNavigation(destination: AnalyticsDestination.signIn),
          ),
        );
        return;
      }

      final profile = await _loadProfile();
      if (isClosed) return;
      if (profile == null) {
        emit(state.copyWith(status: AnalyticsStatus.error, failureCode: 'unknown'));
        return;
      }

      final ratesResult = await _getLatestUsdRates();
      final rates = switch (ratesResult) {
        Success<RatesSnapshotEntity?>(value: final value) => value,
        FailureResult<RatesSnapshotEntity?>() => null,
      };

      final accounts = _accounts;

      if (accounts.isEmpty) {
        emit(
          state.copyWith(
            status: AnalyticsStatus.ready,
            baseCurrency: profile.baseCurrency,
            breakdown: const [],
            updates: const [],
          ),
        );
        return;
      }

      final assetsResult = await _getAssets();
      if (isClosed) return;
      List<AssetEntity> assets;
      switch (assetsResult) {
        case Success<List<AssetEntity>>(value: final value):
          assets = value;
        case FailureResult<List<AssetEntity>>(failure: final failure):
          emit(
            state.copyWith(
              status: AnalyticsStatus.error,
              failureCode: failure.code,
              failureMessage: failure.message,
            ),
          );
          return;
      }

      final assetById = {for (final item in assets) item.id: item};
      final baseAsset = assets.firstWhereOrNull((a) => a.code == profile.baseCurrency);
      final baseUsdPrice = _baseUsdPrice(
        baseCurrencyCode: profile.baseCurrency,
        baseAssetId: baseAsset?.id,
        snapshot: rates,
      );

      final subaccountsByAccount = <String, List<SubaccountEntity>>{};
      for (final account in accounts) {
        final result = await _getSubaccounts(accountId: account.id);
        if (isClosed) return;
        switch (result) {
          case Success<List<SubaccountEntity>>(value: final value):
            subaccountsByAccount[account.id] = value;
          case FailureResult<List<SubaccountEntity>>(failure: final failure):
            emit(
              state.copyWith(
                status: AnalyticsStatus.error,
                failureCode: failure.code,
                failureMessage: failure.message,
              ),
            );
            return;
        }
      }

      final subaccounts = subaccountsByAccount.values.expand((list) => list).toList();
      final subaccountIds = subaccounts.map((item) => item.id).toSet();
      if (subaccountIds.isEmpty) {
        emit(
          state.copyWith(
            status: AnalyticsStatus.ready,
            baseCurrency: profile.baseCurrency,
            breakdown: const [],
            updates: const [],
          ),
        );
        return;
      }

      final balancesResult = await _getCurrentBalances(subaccountIds: subaccountIds);
      if (isClosed) return;
      Map<String, Decimal> balances;
      switch (balancesResult) {
        case Success<Map<String, Decimal>>(value: final value):
          balances = value;
        case FailureResult<Map<String, Decimal>>(failure: final failure):
          emit(
            state.copyWith(
              status: AnalyticsStatus.error,
              failureCode: failure.code,
              failureMessage: failure.message,
            ),
          );
          return;
      }

      final breakdownTotals = <String, Decimal>{};
      final breakdownOriginalTotals = <String, Decimal>{};
      Decimal total = Decimal.zero;

      for (final subaccount in subaccounts) {
        final amount = balances[subaccount.id] ?? Decimal.zero;
        if (amount == Decimal.zero) {
          continue;
        }
        final asset = assetById[subaccount.assetId];
        final priced = _toBaseAmount(
          amount: amount,
          assetId: subaccount.assetId,
          baseUsdPrice: baseUsdPrice,
          rates: rates,
        );
        if (asset == null || priced == null) {
          continue;
        }
        total += priced;
        breakdownTotals.update(asset.code, (current) => current + priced, ifAbsent: () => priced);
        breakdownOriginalTotals.update(
          asset.code,
          (current) => current + amount,
          ifAbsent: () => amount,
        );
      }

      final breakdown = breakdownTotals.entries.map((entry) {
        final percent = total == Decimal.zero
            ? Decimal.zero
            : divideToDecimal(entry.value * Decimal.fromInt(100), total);
        return AnalyticsBreakdownItem(
          assetCode: entry.key,
          value: entry.value,
          percent: percent,
          originalAmount: breakdownOriginalTotals[entry.key] ?? Decimal.zero,
        );
      }).toList()..sort((a, b) => b.value.compareTo(a.value));

      final updates = <AnalyticsUpdateItem>[];
      final accountById = {for (final account in accounts) account.id: account};

      for (final subaccount in subaccounts) {
        final historyResult = await _getHistory(subaccountId: subaccount.id, limit: 20);
        if (isClosed) return;

        final entries = switch (historyResult) {
          Success(value: final page) => page.entries,
          FailureResult<BalanceHistoryPageEntity>() => const <BalanceEntryEntity>[],
        };

        final asset = assetById[subaccount.assetId];
        final account = accountById[subaccount.accountId];
        if (asset == null || account == null) {
          continue;
        }

        for (final entry in entries) {
          final diff = entry.diffAmount;
          if (diff == null) {
            continue;
          }
          final diffBase = _toBaseAmount(
            amount: diff,
            assetId: subaccount.assetId,
            baseUsdPrice: baseUsdPrice,
            rates: rates,
          );
          if (diffBase == null) {
            continue;
          }
          updates.add(
            AnalyticsUpdateItem(
              accountName: account.name,
              subaccountName: subaccount.name,
              assetCode: asset.code,
              diffAmount: diff,
              diffBaseAmount: diffBase,
              entryDate: entry.entryDate,
            ),
          );
        }
      }

      updates.sort((a, b) => b.entryDate.compareTo(a.entryDate));

      if (isClosed) return;
      emit(
        state.copyWith(
          status: AnalyticsStatus.ready,
          baseCurrency: profile.baseCurrency,
          ratesAsOf: rates?.asOf,
          breakdown: breakdown,
          updates: updates,
        ),
      );
    } finally {
      _isFetching = false;
      if (_queuedFetch) {
        final nextSilent = _queuedSilent;
        _queuedFetch = false;
        _queuedSilent = true;
        await _fetch(silent: nextSilent);
      }
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<ProfileEntity?> _loadProfile() async {
    final profileResult = await _getProfile();
    switch (profileResult) {
      case Success<ProfileEntity>(value: final profile):
        return profile;
      case FailureResult<ProfileEntity>():
        return null;
    }
  }

  bool _sameAccounts(List<AccountEntity> current, List<AccountEntity> next) {
    if (current.length != next.length) {
      return false;
    }
    for (var index = 0; index < current.length; index++) {
      final left = current[index];
      final right = next[index];
      if (left.id != right.id || left.updatedAt != right.updatedAt) {
        return false;
      }
    }
    return true;
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

Decimal? _toBaseAmount({
  required Decimal amount,
  required String assetId,
  required Decimal? baseUsdPrice,
  required RatesSnapshotEntity? rates,
}) {
  if (baseUsdPrice == null || rates == null) {
    return null;
  }
  final assetUsd = rates.usdPriceByAssetId[assetId];
  if (assetUsd == null) {
    return null;
  }
  return divideToDecimal(amount * assetUsd, baseUsdPrice);
}

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T item) test) {
    for (final item in this) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }
}
