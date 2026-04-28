import 'dart:async';

import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
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
import 'package:purchases_flutter/purchases_flutter.dart';

part 'profile_cubit.freezed.dart';
part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._watchSession,
    this._ensureProfileReady,
    this._updateBaseCurrency,
    this._updatePlan,
    this._revenueCatService,
    this._analytics,
  ) : super(const ProfileState());

  static const Duration _subscriptionSyncCooldown = Duration(minutes: 5);
  static const Duration _subscriptionSyncTimeout = Duration(seconds: 30);

  final WatchSessionUseCase _watchSession;
  final EnsureProfileReadyUseCase _ensureProfileReady;
  final UpdateBaseCurrencyUseCase _updateBaseCurrency;
  final UpdatePlanUseCase _updatePlan;
  final RevenueCatService _revenueCatService;
  final AppAnalytics _analytics;

  StreamSubscription<AuthSessionEntity?>? _sessionSubscription;
  AuthSessionEntity? _session;
  bool _isLoading = false;
  bool _queuedReload = false;
  bool _queuedSilent = true;
  bool _isSubscriptionSyncing = false;
  bool _queuedSubscriptionSync = false;
  bool _queuedSubscriptionForce = false;
  DateTime? _lastSubscriptionSyncAt;
  CustomerInfoUpdateListener? _customerInfoUpdateListener;

  Future<void> bootstrap() async {
    await _sessionSubscription?.cancel();
    _session = null;
    _installCustomerInfoUpdateListener();
    emit(const ProfileState());
    _sessionSubscription = _watchSession().listen(
      (session) => unawaited(_handleSessionChanged(session)),
      onError: (Object error, StackTrace stackTrace) {
        logger.e('Profile session stream failed', error: error, stackTrace: stackTrace);
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
    await syncSubscription(silent: true);
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
          state.copyWith(status: ProfileStatus.loading, failureCode: null, failureMessage: null),
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
          unawaited(_pushSubscriptionUserProperties(profile.plan));
          unawaited(
            _analytics.setUserProperty(AnalyticsUserProps.baseCurrency, profile.baseCurrency),
          );
        case FailureResult(failure: final failure):
          if (silent && state.profile != null) {
            emit(state.copyWith(failureCode: failure.code, failureMessage: failure.message));
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

    final previousCurrency = state.profile?.baseCurrency;

    emit(state.copyWith(isUpdatingBaseCurrency: true, failureCode: null, failureMessage: null));

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
        unawaited(
          _analytics.log(
            AnalyticsEventName.baseCurrencyChanged,
            parameters: {
              AnalyticsParams.fromCurrency: previousCurrency,
              AnalyticsParams.toCurrency: profile.baseCurrency,
            },
          ),
        );
        unawaited(
          _analytics.setUserProperty(AnalyticsUserProps.baseCurrency, profile.baseCurrency),
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

  Future<void> syncSubscription({
    bool silent = true,
    bool force = false,
    String placement = 'auto',
  }) async {
    if (!state.isReady) {
      return;
    }

    final now = DateTime.now();
    final lastSync = _lastSubscriptionSyncAt;
    if (!force && lastSync != null && now.difference(lastSync) < _subscriptionSyncCooldown) {
      return;
    }

    if (_isSubscriptionSyncing) {
      _queuedSubscriptionSync = true;
      _queuedSubscriptionForce = _queuedSubscriptionForce || force;
      return;
    }

    _isSubscriptionSyncing = true;
    final exposeSyncing = !silent || force;
    emit(
      state.copyWith(isSyncingSubscription: exposeSyncing, failureCode: null, failureMessage: null),
    );

    unawaited(
      _analytics.log(
        AnalyticsEventName.subscriptionSyncStarted,
        parameters: {AnalyticsParams.placement: placement},
      ),
    );

    try {
      if (force) {
        try {
          await _revenueCatService.invalidateCustomerInfoCache();
        } catch (error, stackTrace) {
          logger.e(
            'RevenueCat customer info cache invalidation failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
      final result = await _updatePlan('pro').timeout(
        _subscriptionSyncTimeout,
        onTimeout: () =>
            const FailureResult(Failure(code: 'TIMEOUT', message: 'Subscription sync timed out')),
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
          _lastSubscriptionSyncAt = DateTime.now();
          unawaited(
            _analytics.log(
              AnalyticsEventName.subscriptionSyncSucceeded,
              parameters: {
                AnalyticsParams.placement: placement,
                AnalyticsParams.plan: profile.plan,
              },
            ),
          );
          unawaited(_pushSubscriptionUserProperties(profile.plan));
        case FailureResult(failure: final failure):
          emit(
            state.copyWith(
              isSyncingSubscription: false,
              failureCode: failure.code,
              failureMessage: failure.message,
            ),
          );
          unawaited(
            _analytics.log(
              AnalyticsEventName.subscriptionSyncFailed,
              parameters: {
                AnalyticsParams.placement: placement,
                AnalyticsParams.errorCode: failure.code,
              },
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
      unawaited(
        _analytics.log(
          AnalyticsEventName.subscriptionSyncFailed,
          parameters: {
            AnalyticsParams.placement: placement,
            AnalyticsParams.errorCode: 'SYNC_ERROR',
          },
        ),
      );
    } finally {
      _isSubscriptionSyncing = false;
      if (_queuedSubscriptionSync && !isClosed) {
        final nextForce = _queuedSubscriptionForce;
        _queuedSubscriptionSync = false;
        _queuedSubscriptionForce = false;
        unawaited(syncSubscription(silent: true, force: nextForce));
      }
    }
  }

  Future<void> _pushSubscriptionUserProperties(String? plan) async {
    final isSubscriber = plan == 'pro';
    await _analytics.setUserProperty(AnalyticsUserProps.isSubscriber, isSubscriber.toString());
    await _analytics.setUserProperty(AnalyticsUserProps.subscriptionPlan, plan);
  }

  void _installCustomerInfoUpdateListener() {
    if (_customerInfoUpdateListener != null) {
      return;
    }
    _customerInfoUpdateListener = (_) {
      if (_session != null) {
        unawaited(syncSubscription(silent: true));
      }
    };
    _revenueCatService.addCustomerInfoUpdateListener(_customerInfoUpdateListener!);
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    final listener = _customerInfoUpdateListener;
    if (listener != null) {
      _revenueCatService.removeCustomerInfoUpdateListener(listener);
    }
    return super.close();
  }
}
