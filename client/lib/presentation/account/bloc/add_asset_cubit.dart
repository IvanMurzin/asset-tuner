import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/usecase/add_asset_to_account_usecase.dart';
import 'package:asset_tuner/domain/account_asset/usecase/count_asset_positions_usecase.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_picker_item_entity.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_for_subaccount_picker_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';
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
    this._getAssetsForSubaccountPicker,
    this._countPositions,
    this._addAssetToAccount,
  ) : super(const AddAssetState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final GetAssetsForSubaccountPickerUseCase _getAssetsForSubaccountPicker;
  final CountAssetPositionsUseCase _countPositions;
  final AddAssetToAccountUseCase _addAssetToAccount;
  final Map<AssetKind, List<AssetPickerItemEntity>> _pickerCache = {};

  Future<void> load(String accountId) async {
    emit(
      state.copyWith(
        status: AddAssetStatus.loading,
        failureCode: null,
        failureMessage: null,
        navigation: null,
        selectedKind: null,
        selectedAssetId: null,
        query: '',
        assets: const [],
        visibleAssets: const [],
        name: '',
        balanceText: '',
        nameError: null,
        balanceError: null,
        isCatalogLoading: false,
      ),
    );

    final session = await _getCachedSession();
    if (isClosed) return;
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

    final profile = await _loadProfile();
    if (isClosed) return;
    if (profile == null) {
      emit(
        state.copyWith(status: AddAssetStatus.error, failureCode: 'unknown'),
      );
      return;
    }

    final positionCount = await _countPositions();
    if (isClosed) return;

    final count = switch (positionCount) {
      Success<int>(value: final v) => v,
      FailureResult<int>() => 0,
    };

    _pickerCache.clear();

    emit(
      state.copyWith(
        status: AddAssetStatus.ready,
        accountId: accountId,
        plan: profile.plan,
        entitlements: profile.entitlements,
        assets: const [],
        visibleAssets: const [],
        totalPositionsCount: count,
      ),
    );
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  void updateQuery(String query) {
    final normalized = query.trim();
    final source = state.assets;
    if (source.isEmpty) {
      emit(state.copyWith(query: query, visibleAssets: const []));
      return;
    }
    if (normalized.isEmpty) {
      emit(state.copyWith(query: query, visibleAssets: source));
      return;
    }
    final q = normalized.toLowerCase();
    final filtered = source.where((a) {
      return a.code.toLowerCase().contains(q) ||
          a.name.toLowerCase().contains(q);
    }).toList();
    emit(state.copyWith(query: query, visibleAssets: filtered));
  }

  Future<void> selectKind(AssetKind kind) async {
    if (state.status != AddAssetStatus.ready) {
      return;
    }

    final cached = _pickerCache[kind];
    if (cached != null) {
      final selectedAssetId = cached.any((a) => a.id == state.selectedAssetId)
          ? state.selectedAssetId
          : null;
      emit(
        state.copyWith(
          selectedKind: kind,
          selectedAssetId: selectedAssetId,
          query: '',
          assets: cached,
          visibleAssets: cached,
          failureCode: null,
          failureMessage: null,
          isCatalogLoading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedKind: kind,
        selectedAssetId: null,
        query: '',
        assets: const [],
        visibleAssets: const [],
        failureCode: null,
        failureMessage: null,
        isCatalogLoading: true,
      ),
    );

    final result = await _getAssetsForSubaccountPicker(kind: kind);
    if (isClosed) return;
    switch (result) {
      case Success<List<AssetPickerItemEntity>>(value: final items):
        final sorted = [...items]..sort(_assetSort);
        _pickerCache[kind] = sorted;
        emit(
          state.copyWith(
            assets: sorted,
            visibleAssets: sorted,
            isCatalogLoading: false,
            failureCode: null,
            failureMessage: null,
          ),
        );
      case FailureResult<List<AssetPickerItemEntity>>(failure: final failure):
        emit(
          state.copyWith(
            assets: const [],
            visibleAssets: const [],
            isCatalogLoading: false,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void selectAsset(String assetId) {
    final selected = _findAssetById(assetId);
    if (selected == null) {
      return;
    }
    if (!selected.isUnlocked) {
      emit(
        state.copyWith(
          navigation: const AddAssetNavigation(
            destination: AddAssetDestination.paywall,
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(selectedAssetId: assetId));
  }

  void updateName(String name) {
    emit(state.copyWith(name: name, nameError: null));
  }

  void updateBalance(String value) {
    emit(state.copyWith(balanceText: value, balanceError: null));
  }

  Future<void> addSelected() async {
    final accountId = state.accountId;
    final assetId = state.selectedAssetId;
    if (state.status != AddAssetStatus.ready ||
        accountId == null ||
        assetId == null) {
      return;
    }

    final selectedAsset = _findAssetById(assetId);
    if (selectedAsset == null) {
      emit(state.copyWith(failureCode: 'validation'));
      return;
    }
    if (!selectedAsset.isUnlocked) {
      emit(
        state.copyWith(
          navigation: const AddAssetNavigation(
            destination: AddAssetDestination.paywall,
          ),
        ),
      );
      return;
    }

    final name = state.name.trim();
    if (name.isEmpty) {
      emit(state.copyWith(nameError: 'required'));
      return;
    }

    final amountRaw = state.balanceText.trim().replaceAll(',', '.');
    if (amountRaw.isEmpty) {
      emit(state.copyWith(balanceError: 'required'));
      return;
    }

    final snapshotAmount = _parseDecimal(amountRaw);
    if (snapshotAmount == null) {
      emit(state.copyWith(balanceError: 'invalid'));
      return;
    }

    final entitlements = state.entitlements;
    if (entitlements != null &&
        state.totalPositionsCount >= entitlements.maxSubaccounts) {
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
      accountId: accountId,
      name: name,
      assetId: assetId,
      snapshotAmount: snapshotAmount,
      entryDate: DateTime.now(),
    );
    if (isClosed) return;
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
        emit(
          state.copyWith(
            isSaving: false,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
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

  Decimal? _parseDecimal(String value) {
    try {
      return Decimal.parse(value);
    } catch (_) {
      return null;
    }
  }

  int _assetSort(AssetPickerItemEntity a, AssetPickerItemEntity b) {
    if (a.rank != b.rank) {
      return a.rank.compareTo(b.rank);
    }
    return a.code.compareTo(b.code);
  }

  AssetPickerItemEntity? _findAssetById(String assetId) {
    for (final asset in state.assets) {
      if (asset.id == assetId) {
        return asset;
      }
    }
    return null;
  }
}
