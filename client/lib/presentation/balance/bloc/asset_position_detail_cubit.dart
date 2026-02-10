import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
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

part 'asset_position_detail_cubit.freezed.dart';
part 'asset_position_detail_state.dart';

@injectable
class AssetPositionDetailCubit extends Cubit<AssetPositionDetailState> {
  AssetPositionDetailCubit(
    this._getCachedSession,
    this._getAccounts,
    this._getAccountAssets,
    this._getAssets,
    this._getHistory,
  ) : super(const AssetPositionDetailState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetAccountsUseCase _getAccounts;
  final GetAccountAssetsUseCase _getAccountAssets;
  final GetAssetsUseCase _getAssets;
  final GetBalanceHistoryUseCase _getHistory;

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

    final accounts = await _getAccounts(session.userId);
    final account = switch (accounts) {
      Success<List<AccountEntity>>(value: final list) =>
        list.where((a) => a.id == accountId).firstOrNull,
      FailureResult<List<AccountEntity>>() => null,
    };

    final assets = await _getAssets();
    final asset = switch (assets) {
      Success<List<AssetEntity>>(value: final list) =>
        list.where((a) => a.id == assetId).firstOrNull,
      FailureResult<List<AssetEntity>>() => null,
    };

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
      userId: session.userId,
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
      userId: session.userId,
      accountAssetId: position.id,
      limit: 50,
      offset: 0,
    );

    switch (firstPage) {
      case Success<BalanceHistoryPageEntity>(value: final page):
        final current = await _computeCurrentBalance(
          userId: session.userId,
          accountAssetId: position.id,
        );
        emit(
          state.copyWith(
            status: AssetPositionDetailStatus.ready,
            userId: session.userId,
            accountId: accountId,
            assetId: assetId,
            accountName: account.name,
            assetCode: asset.code,
            assetName: asset.name,
            accountAssetId: position.id,
            currentBalance: current,
            entries: page.entries,
            nextOffset: page.nextOffset,
          ),
        );
      case FailureResult<BalanceHistoryPageEntity>(failure: final failure):
        emit(
          state.copyWith(
            status: AssetPositionDetailStatus.error,
            failureCode: failure.code,
            userId: session.userId,
            accountId: accountId,
            assetId: assetId,
            accountName: account.name,
            assetCode: asset.code,
            assetName: asset.name,
            accountAssetId: position.id,
          ),
        );
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<void> loadMore() async {
    final userId = state.userId;
    final accountAssetId = state.accountAssetId;
    final nextOffset = state.nextOffset;
    if (userId == null || accountAssetId == null || nextOffset == null) {
      return;
    }
    if (state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, bannerFailureCode: null));
    final result = await _getHistory(
      userId: userId,
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
    required String userId,
    required String accountAssetId,
  }) async {
    var offset = 0;
    final all = <BalanceEntryEntity>[];
    while (true) {
      final page = await _getHistory(
        userId: userId,
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
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }
}
