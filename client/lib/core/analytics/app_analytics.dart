import 'package:asset_tuner/core/logger/logger.dart';
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
  void log(AnalyticsEventName event, {Map<String, Object?> parameters = const {}}) {
    final safeParameters = Map<String, Object?>.fromEntries(
      parameters.entries.where((entry) => entry.value != null),
    );
    logger.i('analytics_event ${event.name} $safeParameters');
  }
}
