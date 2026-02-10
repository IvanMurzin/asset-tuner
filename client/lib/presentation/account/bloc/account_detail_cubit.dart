import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
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

part 'account_detail_cubit.freezed.dart';
part 'account_detail_state.dart';

@injectable
class AccountDetailCubit extends Cubit<AccountDetailState> {
  AccountDetailCubit(
    this._getCachedSession,
    this._getAccounts,
    this._getAssets,
    this._getAccountAssets,
    this._removeAssetFromAccount,
    this._setArchived,
    this._deleteAccount,
  ) : super(const AccountDetailState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetAccountsUseCase _getAccounts;
  final GetAssetsUseCase _getAssets;
  final GetAccountAssetsUseCase _getAccountAssets;
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

    final accounts = await _getAccounts(session.userId);
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

    final positions = await _getAccountAssets(
      userId: session.userId,
      accountId: accountId,
    );

    switch (positions) {
      case Success<List<AccountAssetEntity>>(value: final list):
        final viewItems =
            list
                .map((p) => _toViewItem(p, assetsById[p.assetId]))
                .whereType<AccountAssetViewItem>()
                .toList()
              ..sort((a, b) => a.assetCode.compareTo(b.assetCode));
        emit(
          state.copyWith(
            status: AccountDetailStatus.ready,
            userId: session.userId,
            account: account,
            items: viewItems,
            isAccountArchived: account.archived,
          ),
        );
      case FailureResult<List<AccountAssetEntity>>(failure: final failure):
        emit(
          state.copyWith(
            status: AccountDetailStatus.error,
            failureCode: failure.code,
            userId: session.userId,
            account: account,
            isAccountArchived: account.archived,
          ),
        );
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<void> removeAsset({
    required String accountId,
    required String assetId,
  }) async {
    final userId = state.userId;
    if (userId == null) {
      return;
    }

    emit(
      state.copyWith(
        busyAssetIds: {...state.busyAssetIds, assetId},
        bannerFailureCode: null,
      ),
    );

    final result = await _removeAssetFromAccount(
      userId: userId,
      accountId: accountId,
      assetId: assetId,
    );

    switch (result) {
      case Success<void>():
        emit(
          state.copyWith(
            busyAssetIds: {...state.busyAssetIds}..remove(assetId),
            items: state.items.where((i) => i.assetId != assetId).toList(),
          ),
        );
      case FailureResult<void>(failure: final failure):
        emit(
          state.copyWith(
            busyAssetIds: {...state.busyAssetIds}..remove(assetId),
            bannerFailureCode: failure.code,
          ),
        );
    }
  }

  Future<void> setArchived({
    required String accountId,
    required bool archived,
  }) async {
    final userId = state.userId;
    if (userId == null) {
      return;
    }

    emit(state.copyWith(isAccountActionBusy: true, bannerFailureCode: null));
    final result = await _setArchived(
      userId: userId,
      accountId: accountId,
      archived: archived,
    );

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
    final userId = state.userId;
    if (userId == null) {
      return;
    }

    emit(state.copyWith(isAccountActionBusy: true, bannerFailureCode: null));
    final result = await _deleteAccount(userId: userId, accountId: accountId);
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

  AccountAssetViewItem? _toViewItem(
    AccountAssetEntity position,
    AssetEntity? asset,
  ) {
    if (asset == null) {
      return null;
    }
    return AccountAssetViewItem(
      assetId: position.assetId,
      assetCode: asset.code,
      assetName: asset.name,
      assetKind: asset.kind,
    );
  }
}

class AccountAssetViewItem {
  const AccountAssetViewItem({
    required this.assetId,
    required this.assetCode,
    required this.assetName,
    required this.assetKind,
  });

  final String assetId;
  final String assetCode;
  final String assetName;
  final AssetKind assetKind;
}

extension on Iterable<AccountEntity> {
  AccountEntity? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }
}
