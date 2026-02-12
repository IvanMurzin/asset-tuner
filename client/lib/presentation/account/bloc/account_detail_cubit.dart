import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/core/utils/decimal_math.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/set_account_archived_usecase.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/usecase/get_account_assets_usecase.dart';
import 'package:asset_tuner/domain/account_asset/usecase/remove_asset_from_account_usecase.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/balance/usecase/get_current_balances_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/usecase/get_latest_usd_rates_usecase.dart';

part 'account_detail_cubit.freezed.dart';
part 'account_detail_state.dart';

@injectable
class AccountDetailCubit extends Cubit<AccountDetailState> {
  AccountDetailCubit(
    this._getCachedSession,
    this._getProfile,
    this._bootstrapProfile,
    this._getAccounts,
    this._getAssets,
    this._getAccountAssets,
    this._getCurrentBalances,
    this._getLatestUsdRates,
    this._removeAssetFromAccount,
    this._setArchived,
    this._deleteAccount,
  ) : super(const AccountDetailState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final GetAccountsUseCase _getAccounts;
  final GetAssetsUseCase _getAssets;
  final GetAccountAssetsUseCase _getAccountAssets;
  final GetCurrentBalancesUseCase _getCurrentBalances;
  final GetLatestUsdRatesUseCase _getLatestUsdRates;
  final RemoveAssetFromAccountUseCase _removeAssetFromAccount;
  final SetAccountArchivedUseCase _setArchived;
  final DeleteAccountUseCase _deleteAccount;

  Future<void> load(String accountId) async {
    emit(
      state.copyWith(
        status: AccountDetailStatus.loading,
        failureCode: null,
        bannerFailureCode: null,
        busyAssetIds: const {},
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(
        state.copyWith(
          status: AccountDetailStatus.error,
          failureCode: 'unauthorized',
          navigation: const AccountDetailNavigation(
            destination: AccountDetailDestination.signIn,
          ),
        ),
      );
      return;
    }

    final profile = await _loadProfile();
    if (profile == null) {
      emit(
        state.copyWith(
          status: AccountDetailStatus.error,
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
    if (account == null) {
      emit(
        state.copyWith(
          status: AccountDetailStatus.error,
          failureCode: 'not_found',
        ),
      );
      return;
    }

    final assetsResult = await _getAssets();
    final assets = switch (assetsResult) {
      Success<List<AssetEntity>>(value: final list) => list,
      FailureResult<List<AssetEntity>>() => const <AssetEntity>[],
    };
    final assetsById = {for (final a in assets) a.id: a};
    final baseAsset = assets
        .where((a) => a.code == profile.baseCurrency)
        .firstOrNull;

    final positions = await _getAccountAssets(accountId: accountId);

    switch (positions) {
      case Success<List<AccountAssetEntity>>(value: final list):
        final positionIds = list.map((p) => p.id).toSet();
        final balances = await _getCurrentBalances(subaccountIds: positionIds);
        final currentByPosition = switch (balances) {
          Success<Map<String, Decimal>>(value: final map) => map,
          FailureResult<Map<String, Decimal>>() => const <String, Decimal>{},
        };

        final baseUsdPrice = _baseUsdPrice(
          baseCurrencyCode: profile.baseCurrency,
          baseAssetId: baseAsset?.id,
          snapshot: ratesSnapshot,
        );

        var hasUnpriced = false;
        var pricedTotal = Decimal.zero;

        final viewItems =
            list
                .map(
                  (p) => _toViewItem(
                    position: p,
                    asset: assetsById[p.assetId],
                    originalAmount: currentByPosition[p.id] ?? Decimal.zero,
                    baseUsdPrice: baseUsdPrice,
                    ratesSnapshot: ratesSnapshot,
                  ),
                )
                .whereType<AccountAssetViewItem>()
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));

        for (final item in viewItems) {
          if (item.originalAmount == Decimal.zero) {
            continue;
          }
          if (item.isPriced) {
            pricedTotal += item.convertedAmount ?? Decimal.zero;
          } else {
            hasUnpriced = true;
          }
        }

        emit(
          state.copyWith(
            status: AccountDetailStatus.ready,
            account: account,
            baseCurrency: profile.baseCurrency,
            total: hasUnpriced ? null : pricedTotal,
            pricedTotal: hasUnpriced ? pricedTotal : null,
            hasUnpricedHoldings: hasUnpriced,
            ratesAsOf: ratesSnapshot?.asOf,
            items: viewItems,
            isAccountArchived: account.archived,
          ),
        );
      case FailureResult<List<AccountAssetEntity>>(failure: final failure):
        emit(
          state.copyWith(
            status: AccountDetailStatus.error,
            failureCode: failure.code,
            account: account,
            baseCurrency: profile.baseCurrency,
            ratesAsOf: ratesSnapshot?.asOf,
            isAccountArchived: account.archived,
          ),
        );
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<void> removeAsset({required String subaccountId}) async {
    if (state.status != AccountDetailStatus.ready) {
      return;
    }

    emit(
      state.copyWith(
        busyAssetIds: {...state.busyAssetIds, subaccountId},
        bannerFailureCode: null,
      ),
    );

    final result = await _removeAssetFromAccount(subaccountId: subaccountId);

    switch (result) {
      case Success<void>():
        emit(
          state.copyWith(
            busyAssetIds: {...state.busyAssetIds}..remove(subaccountId),
            items: state.items
                .where((i) => i.subaccountId != subaccountId)
                .toList(),
          ),
        );
      case FailureResult<void>(failure: final failure):
        emit(
          state.copyWith(
            busyAssetIds: {...state.busyAssetIds}..remove(subaccountId),
            bannerFailureCode: failure.code,
          ),
        );
    }
  }

  Future<void> setArchived({
    required String accountId,
    required bool archived,
  }) async {
    if (state.status != AccountDetailStatus.ready) {
      return;
    }

    emit(state.copyWith(isAccountActionBusy: true, bannerFailureCode: null));
    final result = await _setArchived(accountId: accountId, archived: archived);

    switch (result) {
      case Success<AccountEntity>(value: final updated):
        emit(
          state.copyWith(
            isAccountActionBusy: false,
            account: updated,
            isAccountArchived: updated.archived,
          ),
        );
      case FailureResult<AccountEntity>(failure: final failure):
        emit(
          state.copyWith(
            isAccountActionBusy: false,
            bannerFailureCode: failure.code,
          ),
        );
    }
  }

  Future<void> deleteAccount(String accountId) async {
    if (state.status != AccountDetailStatus.ready) {
      return;
    }

    emit(state.copyWith(isAccountActionBusy: true, bannerFailureCode: null));
    final result = await _deleteAccount(accountId: accountId);
    switch (result) {
      case Success<void>():
        emit(
          state.copyWith(
            isAccountActionBusy: false,
            navigation: const AccountDetailNavigation(
              destination: AccountDetailDestination.backDeleted,
            ),
          ),
        );
      case FailureResult<void>(failure: final failure):
        emit(
          state.copyWith(
            isAccountActionBusy: false,
            bannerFailureCode: failure.code,
          ),
        );
    }
  }

  AccountAssetViewItem? _toViewItem({
    required AccountAssetEntity position,
    required AssetEntity? asset,
    required Decimal originalAmount,
    required Decimal? baseUsdPrice,
    required RatesSnapshotEntity? ratesSnapshot,
  }) {
    if (asset == null) {
      return null;
    }

    final hasAmount = originalAmount != Decimal.zero;
    final assetUsd = ratesSnapshot?.usdPriceByAssetId[position.assetId];
    final canConvert =
        baseUsdPrice != null &&
        ratesSnapshot != null &&
        assetUsd != null &&
        hasAmount;
    final converted = canConvert
        ? divideToDecimal(originalAmount * assetUsd, baseUsdPrice)
        : null;

    return AccountAssetViewItem(
      subaccountId: position.id,
      assetId: position.assetId,
      name: position.name,
      assetCode: asset.code,
      assetName: asset.name,
      assetKind: asset.kind,
      originalAmount: originalAmount,
      convertedAmount: converted,
    );
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

class AccountAssetViewItem {
  const AccountAssetViewItem({
    required this.subaccountId,
    required this.assetId,
    required this.name,
    required this.assetCode,
    required this.assetName,
    required this.assetKind,
    required this.originalAmount,
    required this.convertedAmount,
  });

  final String subaccountId;
  final String assetId;
  final String name;
  final String assetCode;
  final String assetName;
  final AssetKind assetKind;
  final Decimal originalAmount;
  final Decimal? convertedAmount;

  bool get isPriced => convertedAmount != null;
}

extension on Iterable<AccountEntity> {
  AccountEntity? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
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
