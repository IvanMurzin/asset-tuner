import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/core/utils/decimal_math.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';
import 'package:asset_tuner/domain/balance/usecase/get_balance_history_usecase.dart';
import 'package:asset_tuner/domain/balance/usecase/get_current_balances_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
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
  AnalyticsCubit(this._getSubaccounts, this._getCurrentBalances, this._getHistory)
    : super(const AnalyticsState());

  final GetSubaccountsUseCase _getSubaccounts;
  final GetCurrentBalancesUseCase _getCurrentBalances;
  final GetBalanceHistoryUseCase _getHistory;

  bool _isFetching = false;
  bool _queuedFetch = false;
  bool _queuedSilent = true;
  ProfileEntity? _queuedProfile;
  RatesSnapshotEntity? _queuedRates;
  List<AssetEntity> _queuedAssets = const [];
  List<AccountEntity> _queuedAccounts = const [];
  String? _queuedFingerprint;
  String? _lastSourceFingerprint;

  Future<void> onSourceDataReady(
    ProfileEntity profile,
    RatesSnapshotEntity? rates,
    List<AssetEntity> assets,
    List<AccountEntity> accounts,
  ) async {
    final activeAccounts = accounts.where((a) => !a.archived).toList(growable: false);
    final fingerprint = _sourceFingerprint(
      profile: profile,
      rates: rates,
      accounts: activeAccounts,
      assets: assets,
    );
    if (fingerprint == _lastSourceFingerprint && state.status == AnalyticsStatus.ready) {
      return;
    }
    await _fetchFromSource(
      profile: profile,
      rates: rates,
      assets: assets,
      accounts: activeAccounts,
      silent: state.status == AnalyticsStatus.ready,
      fingerprint: fingerprint,
    );
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  void invalidateCache() {
    _lastSourceFingerprint = null;
  }

  String _sourceFingerprint({
    required ProfileEntity profile,
    required RatesSnapshotEntity? rates,
    required List<AccountEntity> accounts,
    required List<AssetEntity> assets,
  }) {
    final accountIds = accounts.map((a) => a.id).toList()..sort();
    final assetIds = assets.map((a) => a.id).toList()..sort();
    return '${profile.baseCurrency}|${profile.baseAssetId ?? ""}|'
        '${accountIds.join(",")}|${assetIds.join(",")}|'
        '${rates?.asOf.toIso8601String() ?? ""}';
  }

  Future<void> _fetchFromSource({
    required ProfileEntity profile,
    required RatesSnapshotEntity? rates,
    required List<AssetEntity> assets,
    required List<AccountEntity> accounts,
    required bool silent,
    required String fingerprint,
  }) async {
    if (_isFetching) {
      _queuedFetch = true;
      _queuedSilent = _queuedSilent && silent;
      _queuedProfile = profile;
      _queuedRates = rates;
      _queuedAssets = assets;
      _queuedAccounts = accounts;
      _queuedFingerprint = fingerprint;
      return;
    }

    _isFetching = true;
    try {
      if (!silent) {
        emit(
          state.copyWith(status: AnalyticsStatus.loading, failureCode: null, failureMessage: null),
        );
      }

      if (accounts.isEmpty) {
        _lastSourceFingerprint = fingerprint;
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

      final assetById = {for (final item in assets) item.id: item};
      final baseAsset = assets.firstWhereOrNull((a) => a.code == profile.baseCurrency);
      final baseUsdPrice = _baseUsdPrice(
        baseCurrencyCode: profile.baseCurrency,
        baseAssetId: baseAsset?.id,
        snapshot: rates,
      );

      final subaccountsResults = await Future.wait(
        accounts.map((a) => _getSubaccounts(accountId: a.id)),
      );
      if (isClosed) return;

      final subaccountsByAccount = <String, List<SubaccountEntity>>{};
      for (var i = 0; i < accounts.length; i++) {
        final result = subaccountsResults[i];
        switch (result) {
          case Success<List<SubaccountEntity>>(value: final value):
            subaccountsByAccount[accounts[i].id] = value;
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
        _lastSourceFingerprint = fingerprint;
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

      final historyResults = await Future.wait(
        subaccounts.map((s) => _getHistory(subaccountId: s.id, limit: 20)),
      );
      if (isClosed) return;

      for (var i = 0; i < subaccounts.length; i++) {
        final subaccount = subaccounts[i];
        final historyResult = historyResults[i];
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
          if (diff == null || diff.compareTo(Decimal.zero) == 0) {
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
      _lastSourceFingerprint = fingerprint;
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
        final nextProfile = _queuedProfile;
        final nextRates = _queuedRates;
        final nextAssets = _queuedAssets;
        final nextAccounts = _queuedAccounts;
        final nextFingerprint = _queuedFingerprint ?? '';
        _queuedFetch = false;
        _queuedSilent = true;
        _queuedProfile = null;
        _queuedRates = null;
        _queuedAssets = const [];
        _queuedAccounts = const [];
        _queuedFingerprint = null;
        if (nextProfile != null) {
          await _fetchFromSource(
            profile: nextProfile,
            rates: nextRates,
            assets: nextAssets,
            accounts: nextAccounts,
            silent: nextSilent,
            fingerprint: nextFingerprint,
          );
        }
      }
    }
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
