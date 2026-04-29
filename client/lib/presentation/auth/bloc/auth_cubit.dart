import 'dart:async';

import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_out_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/watch_session_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._watchSession,
    this._signOut,
    this._deleteAccount,
    this._revenueCatService,
    this._analytics,
  ) : super(const AuthState());

  final WatchSessionUseCase _watchSession;
  final SignOutUseCase _signOut;
  final DeleteAccountUseCase _deleteAccount;
  final RevenueCatService _revenueCatService;
  final AppAnalytics _analytics;

  StreamSubscription<AuthSessionEntity?>? _sessionSubscription;
  String? _revenueCatUserId;
  String? _lastUserId;
  bool _nativeSplashRemoved = false;

  Future<void> bootstrap() async {
    await _sessionSubscription?.cancel();
    emit(const AuthState());
    _sessionSubscription = _watchSession().listen(
      (session) => unawaited(_handleSessionChanged(session)),
      onError: (Object error, StackTrace stackTrace) {
        logger.e('Session stream failed', error: error, stackTrace: stackTrace);
        if (isClosed) {
          return;
        }
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            session: null,
            failureCode: 'session_stream_error',
            failureMessage: 'Unable to observe auth session',
          ),
        );
        _removeNativeSplashOnce();
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
          status: AuthStatus.unauthenticated,
          session: null,
          isSigningOut: false,
          isDeletingAccount: false,
          revenueCatStatus: RevenueCatIdentityStatus.idle,
          revenueCatUserId: null,
          revenueCatFailureCode: null,
          revenueCatFailureMessage: null,
          failureCode: null,
          failureMessage: null,
        ),
      );
      _removeNativeSplashOnce();
      await _syncRevenueCatLoggedOut();
      if (_lastUserId != null) {
        await _analytics.log(AnalyticsEventName.signOutCompleted);
      }
      await _analytics.setUserId(null);
      await _analytics.setUserProperty(AnalyticsUserProps.isSubscriber, null);
      await _analytics.setUserProperty(AnalyticsUserProps.subscriptionPlan, null);
      _lastUserId = null;
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        isSigningOut: false,
        isDeletingAccount: false,
        revenueCatStatus: RevenueCatIdentityStatus.syncing,
        revenueCatUserId: _revenueCatUserId,
        revenueCatFailureCode: null,
        revenueCatFailureMessage: null,
        failureCode: null,
        failureMessage: null,
      ),
    );
    _removeNativeSplashOnce();
    await _syncRevenueCatLoggedIn(session.userId);
    if (_lastUserId != session.userId) {
      await _analytics.setUserId(session.userId);
      _lastUserId = session.userId;
    }
  }

  Future<void> signOut() async {
    if (state.status == AuthStatus.unauthenticated || state.isBusy) {
      return;
    }

    emit(state.copyWith(isSigningOut: true, failureCode: null, failureMessage: null));

    final result = await _signOut();
    if (result case FailureResult<void>(failure: final failure)) {
      logger.e('AuthCubit.signOut failed: ${failure.code}');
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

  Future<void> syncRevenueCat() async {
    final session = state.session;
    if (session == null || state.revenueCatStatus == RevenueCatIdentityStatus.syncing) {
      return;
    }
    emit(
      state.copyWith(
        revenueCatStatus: RevenueCatIdentityStatus.syncing,
        revenueCatFailureCode: null,
        revenueCatFailureMessage: null,
      ),
    );
    await _syncRevenueCatLoggedIn(session.userId);
  }

  Future<void> deleteAccount() async {
    if (state.status == AuthStatus.unauthenticated || state.isBusy) {
      return;
    }

    emit(state.copyWith(isDeletingAccount: true, failureCode: null, failureMessage: null));

    final result = await _deleteAccount();
    if (result case FailureResult<void>(failure: final failure)) {
      logger.e('AuthCubit.deleteAccount failed: ${failure.code}');
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
      if (!isClosed) {
        emit(
          state.copyWith(
            revenueCatStatus: RevenueCatIdentityStatus.synced,
            revenueCatUserId: userId,
            revenueCatFailureCode: null,
            revenueCatFailureMessage: null,
          ),
        );
      }
      return;
    }
    try {
      await _revenueCatService.logIn(userId);
      if (isClosed || state.session?.userId != userId) {
        return;
      }
      _revenueCatUserId = userId;
      emit(
        state.copyWith(
          revenueCatStatus: RevenueCatIdentityStatus.synced,
          revenueCatUserId: userId,
          revenueCatFailureCode: null,
          revenueCatFailureMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      logger.e('RevenueCat logIn failed', error: error, stackTrace: stackTrace);
      if (!isClosed && state.session?.userId == userId) {
        emit(
          state.copyWith(
            revenueCatStatus: RevenueCatIdentityStatus.error,
            revenueCatUserId: null,
            revenueCatFailureCode: 'revenuecat_login_failed',
            revenueCatFailureMessage: 'Unable to prepare subscription purchases',
          ),
        );
      }
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

  void _removeNativeSplashOnce() {
    if (_nativeSplashRemoved) {
      return;
    }
    _nativeSplashRemoved = true;
    try {
      FlutterNativeSplash.remove();
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    return super.close();
  }
}
