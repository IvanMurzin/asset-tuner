import 'dart:async';

import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_out_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/watch_session_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'session_cubit.freezed.dart';
part 'session_state.dart';

@injectable
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._watchSession, this._signOut, this._deleteAccount, this._revenueCatService)
    : super(const SessionState());

  final WatchSessionUseCase _watchSession;
  final SignOutUseCase _signOut;
  final DeleteAccountUseCase _deleteAccount;
  final RevenueCatService _revenueCatService;

  StreamSubscription<AuthSessionEntity?>? _sessionSubscription;
  String? _revenueCatUserId;

  Future<void> bootstrap() async {
    await _sessionSubscription?.cancel();
    emit(
      state.copyWith(
        status: SessionStatus.initial,
        session: null,
        isSigningOut: false,
        isDeletingAccount: false,
        failureCode: null,
        failureMessage: null,
      ),
    );
    _sessionSubscription = _watchSession().listen(
      (session) => unawaited(_handleSessionChanged(session)),
      onError: (Object error, StackTrace stackTrace) {
        logger.e('Session stream failed', error: error, stackTrace: stackTrace);
        if (isClosed) {
          return;
        }
        emit(
          state.copyWith(
            status: SessionStatus.error,
            session: null,
            failureCode: 'session_stream_error',
            failureMessage: 'Unable to observe auth session',
          ),
        );
      },
    );
  }

  Future<void> _handleSessionChanged(AuthSessionEntity? session) async {
    if (isClosed) {
      return;
    }

    if (session == null) {
      emit(
        state.copyWith(
          status: SessionStatus.unauthenticated,
          session: null,
          isSigningOut: false,
          isDeletingAccount: false,
          failureCode: null,
          failureMessage: null,
        ),
      );
      await _syncRevenueCatLoggedOut();
      return;
    }

    emit(
      state.copyWith(
        status: SessionStatus.authenticated,
        session: session,
        isSigningOut: false,
        isDeletingAccount: false,
        failureCode: null,
        failureMessage: null,
      ),
    );
    await _syncRevenueCatLoggedIn(session.userId);
  }

  Future<void> signOut() async {
    if (state.status == SessionStatus.unauthenticated || state.isBusy) {
      return;
    }

    emit(state.copyWith(isSigningOut: true, failureCode: null, failureMessage: null));

    final result = await _signOut();
    if (result case FailureResult<void>(failure: final failure)) {
      logger.e('SessionCubit.signOut failed: ${failure.code}');
      if (!isClosed) {
        emit(
          state.copyWith(
            isSigningOut: false,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
      }
      return;
    }
  }

  Future<void> deleteAccount() async {
    if (state.status == SessionStatus.unauthenticated || state.isBusy) {
      return;
    }

    emit(state.copyWith(isDeletingAccount: true, failureCode: null, failureMessage: null));

    final result = await _deleteAccount();
    if (result case FailureResult<void>(failure: final failure)) {
      logger.e('SessionCubit.deleteAccount failed: ${failure.code}');
      if (!isClosed) {
        emit(
          state.copyWith(
            isDeletingAccount: false,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
      }
      return;
    }
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
      logger.e('RevenueCat logOut failed', error: error, stackTrace: stackTrace);
    } finally {
      _revenueCatUserId = null;
    }
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    return super.close();
  }
}
