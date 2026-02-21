import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_out_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_plan_usecase.dart';

part 'user_cubit.freezed.dart';
part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(
    this._getCachedSession,
    this._bootstrapProfile,
    this._updateBaseCurrency,
    this._updatePlan,
    this._deleteAccount,
    this._signOut,
  ) : super(const UserState());

  final GetCachedSessionUseCase _getCachedSession;
  final BootstrapProfileUseCase _bootstrapProfile;
  final UpdateBaseCurrencyUseCase _updateBaseCurrency;
  final UpdatePlanUseCase _updatePlan;
  final DeleteAccountUseCase _deleteAccount;
  final SignOutUseCase _signOut;

  Future<void> bootstrap() async {
    emit(
      state.copyWith(
        status: UserStatus.loading,
        failureCode: null,
        failureMessage: null,
      ),
    );
    await _loadAuthenticatedState(silent: false);
  }

  Future<void> refresh({bool silent = false}) async {
    await _loadAuthenticatedState(silent: silent);
  }

  Future<void> _loadAuthenticatedState({required bool silent}) async {
    final session = await _getCachedSession();
    if (isClosed) {
      return;
    }

    if (session == null) {
      final next = state.copyWith(
        status: UserStatus.unauthenticated,
        session: null,
        profile: null,
        failureCode: null,
        failureMessage: null,
      );
      if (!silent || next != state) {
        emit(next);
      }
      return;
    }

    final profileResult = await _bootstrapProfile();
    if (isClosed) {
      return;
    }

    switch (profileResult) {
      case FailureResult(failure: final failure):
        final next = state.copyWith(
          status: UserStatus.error,
          session: session,
          failureCode: failure.code,
          failureMessage: failure.message,
        );
        if (!silent || next != state) {
          emit(next);
        }
      case Success(value: final data):
        var profile = data.profile;
        if (profile.baseAssetId == null) {
          final fixResult = await _updateBaseCurrency('USD');
          if (isClosed) {
            return;
          }
          switch (fixResult) {
            case Success(value: final fixed):
              profile = fixed;
            case FailureResult():
              break;
          }
        }

        final next = state.copyWith(
          status: UserStatus.authenticated,
          session: session,
          profile: profile,
          failureCode: null,
          failureMessage: null,
        );
        if (!silent || next != state) {
          emit(next);
        }
    }
  }

  Future<void> updateBaseCurrency(String code) async {
    if (!state.isAuthenticated || state.isUpdatingBaseCurrency) {
      return;
    }

    emit(
      state.copyWith(
        isUpdatingBaseCurrency: true,
        failureCode: null,
        failureMessage: null,
      ),
    );

    final result = await _updateBaseCurrency(code);
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success(value: final profile):
        emit(state.copyWith(isUpdatingBaseCurrency: false, profile: profile));
      case FailureResult(failure: final failure):
        emit(
          state.copyWith(
            isUpdatingBaseCurrency: false,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  Future<void> syncSubscription() async {
    if (!state.isAuthenticated || state.isSyncingSubscription) {
      return;
    }

    emit(
      state.copyWith(
        isSyncingSubscription: true,
        failureCode: null,
        failureMessage: null,
      ),
    );

    final result = await _updatePlan('pro');
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success(value: final profile):
        emit(state.copyWith(isSyncingSubscription: false, profile: profile));
      case FailureResult(failure: final failure):
        emit(
          state.copyWith(
            isSyncingSubscription: false,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  Future<void> logoutOptimistic() async {
    if (state.status == UserStatus.unauthenticated) {
      return;
    }

    emit(
      state.copyWith(
        status: UserStatus.unauthenticated,
        session: null,
        profile: null,
        navigation: const UserNavigation(UserDestination.signIn),
      ),
    );

    await _signOut();
  }

  Future<void> deleteAccountOptimistic() async {
    emit(
      state.copyWith(
        status: UserStatus.unauthenticated,
        session: null,
        profile: null,
        navigation: const UserNavigation(UserDestination.signIn),
      ),
    );
    await _deleteAccount();
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }
}
