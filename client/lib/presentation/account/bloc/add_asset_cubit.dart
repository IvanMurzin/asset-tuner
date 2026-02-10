import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/usecase/add_asset_to_account_usecase.dart';
import 'package:asset_tuner/domain/account_asset/usecase/count_asset_positions_usecase.dart';
import 'package:asset_tuner/domain/account_asset/usecase/get_account_assets_usecase.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/entitlement/usecase/get_entitlements_for_plan_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';

part 'add_asset_cubit.freezed.dart';
part 'add_asset_state.dart';

@injectable
class AddAssetCubit extends Cubit<AddAssetState> {
  AddAssetCubit(
    this._getCachedSession,
    this._getProfile,
    this._bootstrapProfile,
    this._getEntitlementsForPlan,
    this._getAssets,
    this._getAccountAssets,
    this._countPositions,
    this._addAssetToAccount,
  ) : super(const AddAssetState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final GetEntitlementsForPlanUseCase _getEntitlementsForPlan;
  final GetAssetsUseCase _getAssets;
  final GetAccountAssetsUseCase _getAccountAssets;
  final CountAssetPositionsUseCase _countPositions;
  final AddAssetToAccountUseCase _addAssetToAccount;

  Future<void> load(String accountId) async {
    emit(
      state.copyWith(
        status: AddAssetStatus.loading,
        failureCode: null,
        duplicateError: false,
        navigation: null,
        selectedAssetId: null,
        query: '',
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(
        state.copyWith(
          status: AddAssetStatus.error,
          failureCode: 'unauthorized',
          navigation: const AddAssetNavigation(
            destination: AddAssetDestination.signIn,
          ),
        ),
      );
      return;
    }

    final profile = await _loadProfile(session.userId);
    if (profile == null) {
      emit(
        state.copyWith(status: AddAssetStatus.error, failureCode: 'unknown'),
      );
      return;
    }

    final assets = await _getAssets();
    final existing = await _getAccountAssets(
      userId: session.userId,
      accountId: accountId,
    );
    final positionCount = await _countPositions(session.userId);

    final assetList = switch (assets) {
      Success<List<AssetEntity>>(value: final list) => list,
      FailureResult<List<AssetEntity>>() => const <AssetEntity>[],
    };
    final existingAssetIds = switch (existing) {
      Success(value: final list) => list.map((p) => p.assetId).toSet(),
      FailureResult() => <String>{},
    };
    final count = switch (positionCount) {
      Success<int>(value: final v) => v,
      FailureResult<int>() => 0,
    };

    if (assetList.isEmpty) {
      emit(
        state.copyWith(
          status: AddAssetStatus.error,
          failureCode: 'unknown',
          userId: session.userId,
        ),
      );
      return;
    }

    final sortedAssets = [...assetList]..sort(_assetSort);

    emit(
      state.copyWith(
        status: AddAssetStatus.ready,
        userId: session.userId,
        accountId: accountId,
        plan: profile.plan,
        assets: sortedAssets,
        visibleAssets: sortedAssets,
        existingAssetIds: existingAssetIds,
        totalPositionsCount: count,
      ),
    );
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  void updateQuery(String query) {
    final normalized = query.trim();
    final assets = state.assets;
    if (normalized.isEmpty) {
      emit(state.copyWith(query: query, visibleAssets: assets));
      return;
    }
    final q = normalized.toLowerCase();
    final filtered = assets.where((a) {
      return a.code.toLowerCase().contains(q) ||
          a.name.toLowerCase().contains(q);
    }).toList();
    emit(state.copyWith(query: query, visibleAssets: filtered));
  }

  void selectAsset(String assetId) {
    final isDuplicate = state.existingAssetIds.contains(assetId);
    emit(state.copyWith(selectedAssetId: assetId, duplicateError: isDuplicate));
  }

  Future<void> addSelected() async {
    final userId = state.userId;
    final accountId = state.accountId;
    final assetId = state.selectedAssetId;
    if (userId == null || accountId == null || assetId == null) {
      return;
    }

    if (state.existingAssetIds.contains(assetId)) {
      emit(state.copyWith(duplicateError: true));
      return;
    }

    final entitlements = _getEntitlementsForPlan(state.plan);
    if (state.totalPositionsCount >= entitlements.maxPositions) {
      emit(
        state.copyWith(
          navigation: const AddAssetNavigation(
            destination: AddAssetDestination.paywall,
          ),
        ),
      );
      return;
    }

    emit(state.copyWith(isSaving: true, failureCode: null));
    final result = await _addAssetToAccount(
      userId: userId,
      accountId: accountId,
      assetId: assetId,
    );

    switch (result) {
      case Success():
        emit(
          state.copyWith(
            isSaving: false,
            navigation: const AddAssetNavigation(
              destination: AddAssetDestination.backAdded,
            ),
          ),
        );
      case FailureResult(failure: final failure):
        emit(state.copyWith(isSaving: false, failureCode: failure.code));
    }
  }

  Future<ProfileEntity?> _loadProfile(String userId) async {
    final result = await _getProfile(userId);
    switch (result) {
      case Success<ProfileEntity>(value: final profile):
        return profile;
      case FailureResult<ProfileEntity>():
        final bootstrap = await _bootstrapProfile(userId);
        switch (bootstrap) {
          case Success(value: final data):
            return data.profile;
          case FailureResult():
            return null;
        }
    }
  }

  int _assetSort(AssetEntity a, AssetEntity b) {
    final kindOrder = a.kind.index.compareTo(b.kind.index);
    if (kindOrder != 0) {
      return kindOrder;
    }
    return a.code.compareTo(b.code);
  }
}
