import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_out_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_plan_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'user_cubit.freezed.dart';
part 'user_state.dart';

@injectable
class UserCubit extends Cubit<UserState> {
  UserCubit(
    this._getCachedSession,
    this._getProfile,
    this._updateBaseCurrency,
    this._updatePlan,
    this._deleteAccount,
    this._signOut,
    this._revenueCatService,
  ) : super(const UserState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final UpdateBaseCurrencyUseCase _updateBaseCurrency;
  final UpdatePlanUseCase _updatePlan;
  final DeleteAccountUseCase _deleteAccount;
  final SignOutUseCase _signOut;
  final RevenueCatService _revenueCatService;
  String? _revenueCatUserId;

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
      await _syncRevenueCatLoggedOut();
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

    final profileResult = await _getProfile();
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
        var profile = data;
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
        await _syncRevenueCatLoggedIn(session.userId);
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

    try {
      final result = await _updatePlan('pro').timeout(
        const Duration(seconds: 30),
        onTimeout: () => FailureResult(
          Failure(code: 'TIMEOUT', message: 'Subscription sync timed out'),
        ),
      );
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
    } catch (error, stackTrace) {
      if (isClosed) {
        return;
      }
      logger.e('syncSubscription failed', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          isSyncingSubscription: false,
          failureCode: 'SYNC_ERROR',
          failureMessage: error.toString(),
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
    await _syncRevenueCatLoggedOut();
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
    await _syncRevenueCatLoggedOut();
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<void> _syncRevenueCatLoggedIn(String userId) async {
    if (_revenueCatUserId == userId) {
      return;
    }
    try {
      await _revenueCatService.logIn(userId);
      _revenueCatUserId = userId;
    } catch (error, stackTrace) {
      logger.e('RevenueCat logIn failed', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _syncRevenueCatLoggedOut() async {
    if (_revenueCatUserId == null) {
      return;
    }
    try {
      await _revenueCatService.logOut();
    } catch (error, stackTrace) {
      logger.e(
        'RevenueCat logOut failed',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _revenueCatUserId = null;
    }
  }
}
