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
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/usecase/get_latest_usd_rates_usecase.dart';

part 'asset_position_detail_cubit.freezed.dart';
part 'asset_position_detail_state.dart';

@injectable
class AssetPositionDetailCubit extends Cubit<AssetPositionDetailState> {
  AssetPositionDetailCubit(
    this._getCachedSession,
    this._getProfile,
    this._bootstrapProfile,
    this._getAccounts,
    this._getAccountAssets,
    this._getAssets,
    this._getHistory,
    this._getLatestUsdRates,
  ) : super(const AssetPositionDetailState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final GetAccountsUseCase _getAccounts;
  final GetAccountAssetsUseCase _getAccountAssets;
  final GetAssetsUseCase _getAssets;
  final GetBalanceHistoryUseCase _getHistory;
  final GetLatestUsdRatesUseCase _getLatestUsdRates;

  Future<void> load({
    required String accountId,
    required String assetId,
  }) async {
    emit(
      state.copyWith(
        status: AssetPositionDetailStatus.loading,
        failureCode: null,
        bannerFailureCode: null,
        isLoadingMore: false,
        entries: const [],
        nextOffset: null,
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(
        state.copyWith(
          status: AssetPositionDetailStatus.error,
          failureCode: 'unauthorized',
          navigation: const AssetPositionDetailNavigation(
            destination: AssetPositionDetailDestination.signIn,
          ),
        ),
      );
      return;
    }

    final profile = await _loadProfile();
    if (profile == null) {
      emit(
        state.copyWith(
          status: AssetPositionDetailStatus.error,
          failureCode: 'unknown',
        ),
      );
      return;
    }

    final rates = await _getLatestUsdRates();
    final ratesSnapshot = switch (rates) {
      Success<RatesSnapshotEntity?>(value: final snapshot) => snapshot,
      FailureResult<RatesSnapshotEntity?>() => null,
    };

    final accounts = await _getAccounts();
    final account = switch (accounts) {
      Success<List<AccountEntity>>(value: final list) =>
        list.where((a) => a.id == accountId).firstOrNull,
      FailureResult<List<AccountEntity>>() => null,
    };

    final assetsResult = await _getAssets();
    final assets = switch (assetsResult) {
      Success<List<AssetEntity>>(value: final list) => list,
      FailureResult<List<AssetEntity>>() => null,
    };
    final asset = assets?.firstWhereOrNull((a) => a.id == assetId);
    final baseAsset = assets?.firstWhereOrNull(
      (a) => a.code == profile.baseCurrency,
    );

    final baseUsdPrice = _baseUsdPrice(
      baseCurrencyCode: profile.baseCurrency,
      baseAssetId: baseAsset?.id,
      snapshot: ratesSnapshot,
    );

    if (account == null || asset == null) {
      emit(
        state.copyWith(
          status: AssetPositionDetailStatus.error,
          failureCode: 'not_found',
        ),
      );
      return;
    }

    final positions = await _getAccountAssets(
      accountId: accountId,
    );
    final position = switch (positions) {
      Success<List<AccountAssetEntity>>(value: final list) =>
        list.where((p) => p.assetId == assetId).firstOrNull,
      FailureResult<List<AccountAssetEntity>>() => null,
    };
    if (position == null) {
      emit(
        state.copyWith(
          status: AssetPositionDetailStatus.error,
          failureCode: 'not_found',
        ),
      );
      return;
    }

    final firstPage = await _getHistory(
      accountAssetId: position.id,
      limit: 50,
      offset: 0,
    );

    switch (firstPage) {
      case Success<BalanceHistoryPageEntity>(value: final page):
        final current = await _computeCurrentBalance(
          accountAssetId: position.id,
        );
        final converted = _toConvertedValue(
          originalAmount: current,
          assetId: assetId,
          baseUsdPrice: baseUsdPrice,
          ratesSnapshot: ratesSnapshot,
        );
        final isUnpriced = current != Decimal.zero && converted == null;
        emit(
          state.copyWith(
            status: AssetPositionDetailStatus.ready,
            accountId: accountId,
            assetId: assetId,
            accountName: account.name,
            assetCode: asset.code,
            assetName: asset.name,
            baseCurrency: profile.baseCurrency,
            ratesAsOf: ratesSnapshot?.asOf,
            accountAssetId: position.id,
            currentBalance: current,
            convertedValue: converted,
            isUnpriced: isUnpriced,
            entries: page.entries,
            nextOffset: page.nextOffset,
          ),
        );
      case FailureResult<BalanceHistoryPageEntity>(failure: final failure):
        emit(
          state.copyWith(
            status: AssetPositionDetailStatus.error,
            failureCode: failure.code,
            accountId: accountId,
            assetId: assetId,
            accountName: account.name,
            assetCode: asset.code,
            assetName: asset.name,
            baseCurrency: profile.baseCurrency,
            ratesAsOf: ratesSnapshot?.asOf,
            accountAssetId: position.id,
          ),
        );
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<void> loadMore() async {
    final accountAssetId = state.accountAssetId;
    final nextOffset = state.nextOffset;
    if (accountAssetId == null || nextOffset == null) {
      return;
    }
    if (state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, bannerFailureCode: null));
    final result = await _getHistory(
      accountAssetId: accountAssetId,
      limit: 50,
      offset: nextOffset,
    );

    switch (result) {
      case Success<BalanceHistoryPageEntity>(value: final page):
        emit(
          state.copyWith(
            isLoadingMore: false,
            entries: [...state.entries, ...page.entries],
            nextOffset: page.nextOffset,
          ),
        );
      case FailureResult<BalanceHistoryPageEntity>(failure: final failure):
        emit(
          state.copyWith(isLoadingMore: false, bannerFailureCode: failure.code),
        );
    }
  }

  Future<Decimal> _computeCurrentBalance({
    required String accountAssetId,
  }) async {
    var offset = 0;
    final all = <BalanceEntryEntity>[];
    while (true) {
      final page = await _getHistory(
        accountAssetId: accountAssetId,
        limit: 200,
        offset: offset,
      );
      final value = switch (page) {
        Success<BalanceHistoryPageEntity>(value: final v) => v,
        FailureResult<BalanceHistoryPageEntity>() => null,
      };
      if (value == null) {
        break;
      }
      all.addAll(value.entries);
      if (value.nextOffset == null) {
        break;
      }
      offset = value.nextOffset!;
      if (offset > 5000) {
        break;
      }
    }

    final asc = [...all]..sort(_sortAsc);
    var balance = Decimal.zero;
    for (final entry in asc) {
      switch (entry.entryType) {
        case BalanceEntryType.snapshot:
          if (entry.snapshotAmount != null) {
            balance = entry.snapshotAmount!;
          }
        case BalanceEntryType.delta:
          if (entry.deltaAmount != null) {
            balance += entry.deltaAmount!;
          }
      }
    }
    return balance;
  }

  int _sortAsc(BalanceEntryEntity a, BalanceEntryEntity b) {
    final dateCmp = a.entryDate.compareTo(b.entryDate);
    if (dateCmp != 0) {
      return dateCmp;
    }
    return a.createdAt.compareTo(b.createdAt);
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

Decimal? _toConvertedValue({
  required Decimal originalAmount,
  required String assetId,
  required Decimal? baseUsdPrice,
  required RatesSnapshotEntity? ratesSnapshot,
}) {
  if (originalAmount == Decimal.zero) {
    return Decimal.zero;
  }
  if (baseUsdPrice == null || ratesSnapshot == null) {
    return null;
  }
  final assetUsd = ratesSnapshot.usdPriceByAssetId[assetId];
  if (assetUsd == null) {
    return null;
  }
  return divideToDecimal(originalAmount * assetUsd, baseUsdPrice);
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }

  T? firstWhereOrNull(bool Function(T item) predicate) {
    for (final item in this) {
      if (predicate(item)) {
        return item;
      }
    }
    return null;
  }
}
