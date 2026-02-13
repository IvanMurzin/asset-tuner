import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/core/utils/decimal_math.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/usecase/get_account_assets_usecase.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';
import 'package:asset_tuner/domain/balance/usecase/get_balance_history_usecase.dart';
import 'package:asset_tuner/domain/balance/usecase/get_current_balances_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/usecase/get_latest_usd_rates_usecase.dart';

part 'analytics_cubit.freezed.dart';
part 'analytics_state.dart';

enum AnalyticsDestination { signIn }

@injectable
class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit(
    this._getCachedSession,
    this._getProfile,
    this._bootstrapProfile,
    this._getAccounts,
    this._getAccountAssets,
    this._getAssets,
    this._getCurrentBalances,
    this._getHistory,
    this._getLatestUsdRates,
  ) : super(const AnalyticsState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final GetAccountsUseCase _getAccounts;
  final GetAccountAssetsUseCase _getAccountAssets;
  final GetAssetsUseCase _getAssets;
  final GetCurrentBalancesUseCase _getCurrentBalances;
  final GetBalanceHistoryUseCase _getHistory;
  final GetLatestUsdRatesUseCase _getLatestUsdRates;

  Future<void> load() async {
    await _fetch(silent: false);
  }

  Future<void> refresh() async {
    if (state.status != AnalyticsStatus.ready) {
      return;
    }
    await _fetch(silent: true);
  }

  Future<void> _fetch({required bool silent}) async {
    if (!silent) {
      emit(state.copyWith(status: AnalyticsStatus.loading, failureCode: null));
    }

    final session = await _getCachedSession();
    if (isClosed) return;
    if (session == null) {
      emit(
        state.copyWith(
          status: AnalyticsStatus.error,
          failureCode: 'unauthorized',
          navigation: const AnalyticsNavigation(
            destination: AnalyticsDestination.signIn,
          ),
        ),
      );
      return;
    }

    final profile = await _loadProfile();
    if (isClosed) return;
    if (profile == null) {
      emit(
        state.copyWith(status: AnalyticsStatus.error, failureCode: 'unknown'),
      );
      return;
    }

    final ratesResult = await _getLatestUsdRates();
    final rates = switch (ratesResult) {
      Success<RatesSnapshotEntity?>(value: final value) => value,
      FailureResult<RatesSnapshotEntity?>() => null,
    };

    final accountsResult = await _getAccounts();
    if (isClosed) return;
    List<AccountEntity> accounts;
    switch (accountsResult) {
      case Success<List<AccountEntity>>(value: final value):
        accounts = value.where((a) => !a.archived).toList();
      case FailureResult<List<AccountEntity>>(failure: final failure):
        emit(
          state.copyWith(
            status: AnalyticsStatus.error,
            failureCode: failure.code,
          ),
        );
        return;
    }

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
          ),
        );
        return;
    }

    final assetById = {for (final item in assets) item.id: item};
    final baseAsset = assets.firstWhereOrNull(
      (a) => a.code == profile.baseCurrency,
    );
    final baseUsdPrice = _baseUsdPrice(
      baseCurrencyCode: profile.baseCurrency,
      baseAssetId: baseAsset?.id,
      snapshot: rates,
    );

    final subaccountsByAccount = <String, List<AccountAssetEntity>>{};
    for (final account in accounts) {
      final result = await _getAccountAssets(accountId: account.id);
      if (isClosed) return;
      switch (result) {
        case Success<List<AccountAssetEntity>>(value: final value):
          subaccountsByAccount[account.id] = value;
        case FailureResult<List<AccountAssetEntity>>(failure: final failure):
          emit(
            state.copyWith(
              status: AnalyticsStatus.error,
              failureCode: failure.code,
            ),
          );
          return;
      }
    }

    final subaccounts = subaccountsByAccount.values
        .expand((list) => list)
        .toList();
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

    final balancesResult = await _getCurrentBalances(
      subaccountIds: subaccountIds,
    );
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
          ),
        );
        return;
    }

    final breakdownTotals = <String, Decimal>{};
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
      breakdownTotals.update(
        asset.code,
        (current) => current + priced,
        ifAbsent: () => priced,
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
      );
    }).toList()..sort((a, b) => b.value.compareTo(a.value));

    final updates = <AnalyticsUpdateItem>[];
    final accountById = {for (final account in accounts) account.id: account};

    for (final subaccount in subaccounts) {
      final historyResult = await _getHistory(
        subaccountId: subaccount.id,
        limit: 20,
        offset: 0,
      );
      if (isClosed) return;

      final entries = switch (historyResult) {
        Success(value: final page) => page.entries,
        FailureResult<BalanceHistoryPageEntity>() =>
          const <BalanceEntryEntity>[],
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
        final bootstrap = await _bootstrapProfile();
        switch (bootstrap) {
          case Success(value: final result):
            return result.profile;
          case FailureResult():
            return null;
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
