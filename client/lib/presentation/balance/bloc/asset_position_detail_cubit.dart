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
import 'package:asset_tuner/domain/account_asset/usecase/remove_asset_from_account_usecase.dart';
import 'package:asset_tuner/domain/account_asset/usecase/rename_subaccount_usecase.dart';
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
    this._removeSubaccount,
    this._renameSubaccount,
  ) : super(const AssetPositionDetailState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final GetAccountsUseCase _getAccounts;
  final GetAccountAssetsUseCase _getAccountAssets;
  final GetAssetsUseCase _getAssets;
  final GetBalanceHistoryUseCase _getHistory;
  final GetLatestUsdRatesUseCase _getLatestUsdRates;
  final RemoveAssetFromAccountUseCase _removeSubaccount;
  final RenameSubaccountUseCase _renameSubaccount;

  Future<void> load({required String subaccountId}) async {
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

    final accountsResult = await _getAccounts();
    final accounts = switch (accountsResult) {
      Success<List<AccountEntity>>(value: final list) => list,
      FailureResult<List<AccountEntity>>() => const <AccountEntity>[],
    };

    final tuple = await _findSubaccount(accounts, subaccountId);
    final account = tuple?.account;
    final subaccount = tuple?.subaccount;

    final assetsResult = await _getAssets();
    final assets = switch (assetsResult) {
      Success<List<AssetEntity>>(value: final list) => list,
      FailureResult<List<AssetEntity>>() => null,
    };

    if (account == null || subaccount == null || assets == null) {
      emit(
        state.copyWith(
          status: AssetPositionDetailStatus.error,
          failureCode: 'not_found',
        ),
      );
      return;
    }

    final asset = assets.firstWhereOrNull((a) => a.id == subaccount.assetId);
    final baseAsset = assets.firstWhereOrNull(
      (a) => a.code == profile.baseCurrency,
    );

    if (asset == null) {
      emit(
        state.copyWith(
          status: AssetPositionDetailStatus.error,
          failureCode: 'not_found',
        ),
      );
      return;
    }

    final firstPage = await _getHistory(
      subaccountId: subaccount.id,
      limit: 50,
      offset: 0,
    );

    switch (firstPage) {
      case Success<BalanceHistoryPageEntity>(value: final page):
        final current = page.entries.isEmpty
            ? Decimal.zero
            : page.entries.first.snapshotAmount;

        final baseUsdPrice = _baseUsdPrice(
          baseCurrencyCode: profile.baseCurrency,
          baseAssetId: baseAsset?.id,
          snapshot: ratesSnapshot,
        );

        final converted = _toConvertedValue(
          originalAmount: current,
          assetId: asset.id,
          baseUsdPrice: baseUsdPrice,
          ratesSnapshot: ratesSnapshot,
        );
        final isUnpriced = current != Decimal.zero && converted == null;

        emit(
          state.copyWith(
            status: AssetPositionDetailStatus.ready,
            accountId: account.id,
            accountName: account.name,
            subaccountId: subaccount.id,
            subaccountName: subaccount.name,
            assetId: asset.id,
            assetCode: asset.code,
            assetName: asset.name,
            baseCurrency: profile.baseCurrency,
            ratesAsOf: ratesSnapshot?.asOf,
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
          ),
        );
    }
  }

  Future<void> loadMore() async {
    final subaccountId = state.subaccountId;
    final nextOffset = state.nextOffset;
    if (subaccountId == null || nextOffset == null) {
      return;
    }
    if (state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, bannerFailureCode: null));
    final result = await _getHistory(
      subaccountId: subaccountId,
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

  Future<void> rename(String name) async {
    final subaccountId = state.subaccountId;
    final normalized = name.trim();
    if (subaccountId == null || normalized.isEmpty) {
      return;
    }

    emit(state.copyWith(isMutating: true, bannerFailureCode: null));
    final result = await _renameSubaccount(
      subaccountId: subaccountId,
      name: normalized,
    );

    switch (result) {
      case Success<AccountAssetEntity>(value: final updated):
        emit(state.copyWith(isMutating: false, subaccountName: updated.name));
      case FailureResult<AccountAssetEntity>(failure: final failure):
        emit(
          state.copyWith(isMutating: false, bannerFailureCode: failure.code),
        );
    }
  }

  Future<void> deleteSubaccount() async {
    final subaccountId = state.subaccountId;
    if (subaccountId == null) {
      return;
    }

    emit(state.copyWith(isMutating: true, bannerFailureCode: null));
    final result = await _removeSubaccount(subaccountId: subaccountId);
    switch (result) {
      case Success<void>():
        emit(
          state.copyWith(
            isMutating: false,
            navigation: const AssetPositionDetailNavigation(
              destination: AssetPositionDetailDestination.backDeleted,
            ),
          ),
        );
      case FailureResult<void>(failure: final failure):
        emit(
          state.copyWith(isMutating: false, bannerFailureCode: failure.code),
        );
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<({AccountEntity account, AccountAssetEntity subaccount})?>
  _findSubaccount(List<AccountEntity> accounts, String subaccountId) async {
    for (final account in accounts) {
      final result = await _getAccountAssets(accountId: account.id);
      switch (result) {
        case Success<List<AccountAssetEntity>>(value: final items):
          final found = items.firstWhereOrNull(
            (item) => item.id == subaccountId,
          );
          if (found != null) {
            return (account: account, subaccount: found);
          }
        case FailureResult<List<AccountAssetEntity>>():
          continue;
      }
    }
    return null;
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
  T? firstWhereOrNull(bool Function(T item) test) {
    for (final item in this) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }
}
