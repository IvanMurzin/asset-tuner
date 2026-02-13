import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_out_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';

part 'settings_cubit.freezed.dart';
part 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
    this._getCachedSession,
    this._getProfile,
    this._bootstrapProfile,
    this._signOut,
  ) : super(const SettingsState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final SignOutUseCase _signOut;

  Future<void> load() async {
    emit(state.copyWith(status: SettingsStatus.loading, failureCode: null));

    final session = await _getCachedSession();
    if (isClosed) return;
    if (session == null) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          failureCode: 'unauthorized',
          navigation: const SettingsNavigation(
            destination: SettingsDestination.signIn,
          ),
        ),
      );
      return;
    }

    final profile = await _loadProfile();
    if (isClosed) return;
    if (profile == null) {
      emit(
        state.copyWith(status: SettingsStatus.error, failureCode: 'unknown'),
      );
      return;
    }

    emit(
      state.copyWith(
        status: SettingsStatus.ready,
        email: session.email,
        baseCurrency: profile.baseCurrency,
        plan: profile.plan,
      ),
    );
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<void> signOut() async {
    emit(state.copyWith(isSigningOut: true));
    final result = await _signOut();
    if (isClosed) return;
    switch (result) {
      case Success<void>():
        emit(
          state.copyWith(
            isSigningOut: false,
            navigation: const SettingsNavigation(
              destination: SettingsDestination.signIn,
            ),
          ),
        );
      case FailureResult<void>(failure: final failure):
        emit(
          state.copyWith(
            isSigningOut: false,
            status: SettingsStatus.ready,
            failureCode: failure.code,
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
}
