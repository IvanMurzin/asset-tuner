import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/firebase/firebase_initializer.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

enum AnalyticsEventName {
  onboardingStarted,
  onboardingSlideViewed,
  onboardingCompleted,
  authStarted,
  authCompleted,
  authFailed,
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

@lazySingleton
class AppAnalytics {
  Future<void> log(AnalyticsEventName event, {Map<String, Object?> parameters = const {}}) async {
    final safeParameters = <String, Object>{
      for (final entry in parameters.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
    if (!AppConfig.instance.analyticsActive) {
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
      if (AppConfig.instance.analyticsActive) {
        await FirebaseAnalytics.instance.setUserId(id: userId);
      }
      if (kReleaseMode) {
        await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
      }
    } catch (error, stack) {
      logger.w('Analytics setUserId failed', error: error, stackTrace: stack);
    }
  }
}
