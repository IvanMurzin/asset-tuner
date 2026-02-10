import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/usecase/get_latest_usd_rates_usecase.dart';

part 'overview_cubit.freezed.dart';
part 'overview_state.dart';

enum OverviewDestination { signIn }

@injectable
class OverviewCubit extends Cubit<OverviewState> {
  OverviewCubit(
    this._getCachedSession,
    this._getProfile,
    this._bootstrapProfile,
    this._getLatestUsdRates,
  ) : super(const OverviewState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final GetLatestUsdRatesUseCase _getLatestUsdRates;

  Future<void> load() async {
    emit(state.copyWith(status: OverviewStatus.loading, failureCode: null));

    final session = await _getCachedSession();
    if (session == null) {
      emit(
        state.copyWith(
          status: OverviewStatus.error,
          failureCode: 'unauthorized',
          navigation: const OverviewNavigation(
            destination: OverviewDestination.signIn,
          ),
        ),
      );
      return;
    }

    final profile = await _loadProfile(session.userId);
    if (profile == null) {
      emit(
        state.copyWith(status: OverviewStatus.error, failureCode: 'unknown'),
      );
      return;
    }

    final rates = await _getLatestUsdRates();
    final asOf = switch (rates) {
      Success<RatesSnapshotEntity?>(value: final snapshot) => snapshot?.asOf,
      FailureResult<RatesSnapshotEntity?>() => null,
    };
    final ratesFailure = switch (rates) {
      Success<RatesSnapshotEntity?>() => null,
      FailureResult<RatesSnapshotEntity?>(failure: final failure) =>
        failure.code,
    };

    emit(
      state.copyWith(
        status: OverviewStatus.ready,
        userId: session.userId,
        baseCurrency: profile.baseCurrency,
        plan: profile.plan,
        ratesAsOf: asOf,
        ratesFailureCode: ratesFailure,
      ),
    );
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
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
}
