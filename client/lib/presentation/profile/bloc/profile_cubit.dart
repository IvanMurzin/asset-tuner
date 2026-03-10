import 'dart:async';

import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/usecase/watch_session_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/ensure_profile_ready_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_plan_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'profile_cubit.freezed.dart';
part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._watchSession,
    this._ensureProfileReady,
    this._updateBaseCurrency,
    this._updatePlan,
  ) : super(const ProfileState());

  final WatchSessionUseCase _watchSession;
  final EnsureProfileReadyUseCase _ensureProfileReady;
  final UpdateBaseCurrencyUseCase _updateBaseCurrency;
  final UpdatePlanUseCase _updatePlan;

  StreamSubscription<AuthSessionEntity?>? _sessionSubscription;
  AuthSessionEntity? _session;
  bool _isLoading = false;
  bool _queuedReload = false;
  bool _queuedSilent = true;

  Future<void> bootstrap() async {
    await _sessionSubscription?.cancel();
    _session = null;
    emit(const ProfileState());
    _sessionSubscription = _watchSession().listen(
      (session) => unawaited(_handleSessionChanged(session)),
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Profile session stream failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (isClosed) {
          return;
        }
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            profile: null,
            failureCode: 'profile_session_stream_error',
            failureMessage: 'Unable to bootstrap profile',
          ),
        );
      },
    );
  }

  Future<void> _handleSessionChanged(AuthSessionEntity? session) async {
    _session = session;
    if (session == null) {
      emit(const ProfileState());
      return;
    }
    await _loadProfile(silent: false);
  }

  Future<void> refresh({bool silent = false}) async {
    if (_session == null) {
      return;
    }
    await _loadProfile(silent: silent);
  }

  Future<void> _loadProfile({required bool silent}) async {
    if (_session == null) {
      return;
    }
    if (_isLoading) {
      _queuedReload = true;
      _queuedSilent = _queuedSilent && silent;
      return;
    }

    _isLoading = true;
    try {
      if (!silent || state.status != ProfileStatus.ready) {
        emit(
          state.copyWith(
            status: ProfileStatus.loading,
            failureCode: null,
            failureMessage: null,
          ),
        );
      }

      final result = await _ensureProfileReady();
      if (isClosed) {
        return;
      }

      switch (result) {
        case Success(value: final profile):
          emit(
            state.copyWith(
              status: ProfileStatus.ready,
              profile: profile,
              failureCode: null,
              failureMessage: null,
            ),
          );
        case FailureResult(failure: final failure):
          if (silent && state.profile != null) {
            emit(
              state.copyWith(
                failureCode: failure.code,
                failureMessage: failure.message,
              ),
            );
          } else {
            emit(
              state.copyWith(
                status: ProfileStatus.error,
                failureCode: failure.code,
                failureMessage: failure.message,
              ),
            );
          }
      }
    } finally {
      _isLoading = false;
      if (_queuedReload) {
        final nextSilent = _queuedSilent;
        _queuedReload = false;
        _queuedSilent = true;
        unawaited(_loadProfile(silent: nextSilent));
      }
    }
  }

  Future<void> updateBaseCurrency(String code) async {
    if (!state.isReady || state.isUpdatingBaseCurrency) {
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
        emit(
          state.copyWith(
            status: ProfileStatus.ready,
            profile: profile,
            isUpdatingBaseCurrency: false,
            failureCode: null,
            failureMessage: null,
          ),
        );
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
    if (!state.isReady || state.isSyncingSubscription) {
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
        onTimeout: () => const FailureResult(
          Failure(code: 'TIMEOUT', message: 'Subscription sync timed out'),
        ),
      );
      if (isClosed) {
        return;
      }

      switch (result) {
        case Success(value: final profile):
          emit(
            state.copyWith(
              status: ProfileStatus.ready,
              profile: profile,
              isSyncingSubscription: false,
              failureCode: null,
              failureMessage: null,
            ),
          );
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
      logger.e('syncSubscription failed', error: error, stackTrace: stackTrace);
      if (!isClosed) {
        emit(
          state.copyWith(
            isSyncingSubscription: false,
            failureCode: 'SYNC_ERROR',
            failureMessage: error.toString(),
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    return super.close();
  }
}
