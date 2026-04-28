import 'dart:async';

import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/firebase/firebase_initializer.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

enum AnalyticsEventName {
  appOpened,
  onboardingStarted,
  onboardingSlideViewed,
  onboardingCompleted,
  authStarted,
  authCompleted,
  authFailed,
  signOutCompleted,
  paywallViewed,
  paywallDismissed,
  planSelected,
  purchaseStarted,
  purchaseSucceeded,
  purchaseFailed,
  restoreStarted,
  restoreSucceeded,
  restoreFailed,
  subscriptionSyncStarted,
  subscriptionSyncSucceeded,
  subscriptionSyncFailed,
  accountCreated,
  subaccountCreated,
  balanceUpdated,
  baseCurrencyChanged,
  limitHit,
  lockedFeatureTapped,
  manageSubscriptionOpened,
  customerCenterOpened,
  customerCenterClosed,
}

abstract final class AnalyticsParams {
  static const placement = 'placement';
  static const provider = 'provider';
  static const mode = 'mode';
  static const feature = 'feature';
  static const reason = 'reason';
  static const plan = 'plan';
  static const packageId = 'package_id';
  static const errorCode = 'failure_code';
  static const accountType = 'account_type';
  static const subaccountKind = 'subaccount_kind';
  static const currency = 'currency';
  static const fromCurrency = 'from_currency';
  static const toCurrency = 'to_currency';
  static const flavor = 'flavor';
  static const screen = 'screen';
}

abstract final class AnalyticsUserProps {
  static const isSubscriber = 'is_subscriber';
  static const subscriptionPlan = 'subscription_plan';
  static const baseCurrency = 'base_currency';
}

bool _isAnalyticsActive() {
  try {
    return AppConfig.instance.analyticsActive;
  } on StateError {
    return false;
  }
}

@lazySingleton
class AppAnalytics {
  Future<void> log(AnalyticsEventName event, {Map<String, Object?> parameters = const {}}) async {
    final safeParameters = <String, Object>{
      for (final entry in parameters.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
    if (!_isAnalyticsActive()) {
      logger.i('analytics_event ${event.name} $safeParameters');
      return;
    }
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: event.name,
        parameters: safeParameters.isEmpty ? null : safeParameters,
      );
    } catch (error, stack) {
      logger.w('Analytics log failed for ${event.name}', error: error, stackTrace: stack);
    }
  }

  Future<void> setUserId(String? userId) async {
    if (!FirebaseInitializer.isInitialized) return;
    try {
      if (_isAnalyticsActive()) {
        await FirebaseAnalytics.instance.setUserId(id: userId);
      }
      if (kReleaseMode) {
        await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
      }
    } catch (error, stack) {
      logger.w('Analytics setUserId failed', error: error, stackTrace: stack);
    }
  }

  Future<void> setUserProperty(String name, String? value) async {
    if (!_isAnalyticsActive()) {
      logger.i('analytics_user_property $name=$value');
      return;
    }
    try {
      await FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
    } catch (error, stack) {
      logger.w('Analytics setUserProperty failed for $name', error: error, stackTrace: stack);
    }
  }

  Future<void> logScreenView(String screenName) async {
    if (!_isAnalyticsActive()) {
      logger.i('analytics_screen_view $screenName');
      return;
    }
    try {
      await FirebaseAnalytics.instance.logScreenView(screenName: screenName);
    } catch (error, stack) {
      logger.w('Analytics logScreenView failed for $screenName', error: error, stackTrace: stack);
    }
  }
}

class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final AppAnalytics _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _track(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _track(previousRoute);
  }

  void _track(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    unawaited(_analytics.logScreenView(name));
  }
}
