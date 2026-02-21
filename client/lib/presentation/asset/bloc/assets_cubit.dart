import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'assets_cubit.freezed.dart';
part 'assets_state.dart';

class AssetsCubit extends Cubit<AssetsState> {
  AssetsCubit(this._getCachedSession, this._getAssets) : super(const AssetsState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetAssetsUseCase _getAssets;

  Future<void> load() async {
    emit(state.copyWith(status: AssetsStatus.loading, failureCode: null, failureMessage: null));
    await _fetch(silent: false);
  }

  Future<void> refresh({bool silent = false}) async {
    await _fetch(silent: silent);
  }

  Future<void> _fetch({required bool silent}) async {
    final session = await _getCachedSession();
    if (isClosed) {
      return;
    }
    if (session == null) {
      emit(
        state.copyWith(
          status: AssetsStatus.error,
          assets: const <AssetEntity>[],
          failureCode: 'unauthorized',
          failureMessage: null,
        ),
      );
      return;
    }

    final result = await _getAssets();
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<List<AssetEntity>>(value: final assets):
        final sorted = [...assets]..sort((a, b) => a.code.compareTo(b.code));
        emit(
          state.copyWith(
            status: AssetsStatus.ready,
            assets: sorted,
            failureCode: null,
            failureMessage: null,
          ),
        );
      case FailureResult<List<AssetEntity>>(failure: final failure):
        if (!silent || state.status != AssetsStatus.ready) {
          emit(
            state.copyWith(
              status: AssetsStatus.error,
              failureCode: failure.code,
              failureMessage: failure.message,
            ),
          );
        } else {
          emit(state.copyWith(failureCode: failure.code, failureMessage: failure.message));
        }
    }
  }
}
