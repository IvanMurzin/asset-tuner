import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'paywall_cubit.freezed.dart';
part 'paywall_state.dart';

@injectable
class PaywallCubit extends Cubit<PaywallState> {
  PaywallCubit(this._revenueCat, this._analytics, @factoryParam this._args)
    : super(const PaywallState());

  final RevenueCatService _revenueCat;
  final AppAnalytics _analytics;
  final PaywallArgs _args;
  bool _didLogView = false;

  String get _reasonName => switch (_args.reason) {
    PaywallReason.onboarding => 'onboarding',
    PaywallReason.accountsLimit => 'accounts_limit',
    PaywallReason.subaccountsLimit => 'subaccounts_limit',
    PaywallReason.baseCurrency => 'base_currency',
    PaywallReason.manageSubscription => 'manage_subscription',
  };

  String get _placement => switch (_args.reason) {
    PaywallReason.onboarding => 'onboarding',
    PaywallReason.manageSubscription => 'manage_subscription',
    _ => 'feature_gate',
  };

  Future<void> loadOfferings() async {
    try {
      final offerings = await _revenueCat.getOfferings();
      if (isClosed) {
        return;
      }
      final offering = offerings.current;
      final available = offering?.availablePackages ?? const <Package>[];

      var annual = offering?.annual ?? _findByType(available, PackageType.annual);
      var monthly = offering?.monthly ?? _findByType(available, PackageType.monthly);
      annual ??= _findByPeriod(available, 'P1Y');
      monthly ??= _findByPeriod(available, 'P1M');
      annual ??= _firstDifferent(available, monthly);
      monthly ??= _firstDifferent(available, annual);
      if (annual == null && monthly == null && available.isNotEmpty) {
        annual = available.first;
      }

      emit(
        state.copyWith(
          offeringsLoaded: true,
          annualPackage: annual,
          monthlyPackage: monthly,
          selectedOption: annual != null ? PaywallPlanOption.annual : PaywallPlanOption.monthly,
        ),
      );
      _logViewIfNeeded();
    } catch (e, stackTrace) {
      if (isClosed) {
        return;
      }
      logger.e('Paywall error: paywall_load_offerings', error: e, stackTrace: stackTrace);
      emit(state.copyWith(offeringsLoaded: true, failureCode: 'paywall_load_offerings'));
      _logViewIfNeeded();
    }
  }

  void selectPlan(PaywallPlanOption option) {
    emit(state.copyWith(selectedOption: option));
    _analytics.log(
      AnalyticsEventName.planSelected,
      parameters: {
        'placement': _placement,
        'plan': option.name,
        'package_id': state.selectedPackage?.identifier,
      },
    );
  }

  Future<void> purchase() async {
    final package = state.selectedPackage;
    if (!state.canContinue || package == null) {
      return;
    }
    final planParams = {
      'placement': _placement,
      'reason': _reasonName,
      'plan': state.selectedOption.name,
      'package_id': package.identifier,
    };
    emit(state.copyWith(status: PaywallStatus.processing, failureCode: null, failureMessage: null));
    _analytics.log(AnalyticsEventName.purchaseStarted, parameters: planParams);

    try {
      await _revenueCat.purchasePackage(package);
      _analytics.log(AnalyticsEventName.purchaseSucceeded, parameters: planParams);
      _emitIfActive(state.copyWith(status: PaywallStatus.verifying));
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      final cancelled = code == PurchasesErrorCode.purchaseCancelledError;
      _analytics.log(
        AnalyticsEventName.purchaseFailed,
        parameters: {...planParams, 'failure_code': code.name, 'cancelled': cancelled},
      );
      _emitIfActive(
        state.copyWith(
          status: PaywallStatus.ready,
          failureCode: cancelled ? null : 'paywall_purchase',
          failureMessage: cancelled ? null : error.message,
        ),
      );
    } catch (_) {
      _analytics.log(
        AnalyticsEventName.purchaseFailed,
        parameters: {...planParams, 'failure_code': 'unknown', 'cancelled': false},
      );
      _emitIfActive(state.copyWith(status: PaywallStatus.ready, failureCode: 'paywall_purchase'));
    }
  }

  Future<void> restore() async {
    if (state.isBusy) {
      return;
    }
    emit(state.copyWith(status: PaywallStatus.processing, failureCode: null, failureMessage: null));
    _analytics.log(AnalyticsEventName.restoreStarted, parameters: {'placement': _placement});

    try {
      await _revenueCat.restorePurchases();
      _analytics.log(AnalyticsEventName.restoreSucceeded, parameters: {'placement': _placement});
      _emitIfActive(state.copyWith(status: PaywallStatus.verifying));
    } catch (_) {
      _analytics.log(
        AnalyticsEventName.restoreFailed,
        parameters: {'placement': _placement, 'failure_code': 'unknown'},
      );
      _emitIfActive(state.copyWith(status: PaywallStatus.ready, failureCode: 'paywall_restore'));
    }
  }

  /// Result of the profile sync that follows a store success.
  void onVerified({required bool isPro}) {
    if (state.status != PaywallStatus.verifying) {
      return;
    }
    emit(
      isPro
          ? state.copyWith(status: PaywallStatus.done)
          : state.copyWith(status: PaywallStatus.ready, failureCode: 'paywall_sync_not_pro'),
    );
  }

  /// Closes the paywall for a user who is already Pro when no purchase is in flight.
  void onProfileChanged({required bool isPro}) {
    if (isPro && !state.isBusy) {
      emit(state.copyWith(status: PaywallStatus.done));
    }
  }

  void dismiss({bool logAnalytics = true}) {
    if (state.status == PaywallStatus.done) {
      return;
    }
    if (logAnalytics) {
      _analytics.log(
        AnalyticsEventName.paywallDismissed,
        parameters: {'placement': _placement, 'reason': _reasonName, 'variant': 'subscription_v1'},
      );
    }
    emit(state.copyWith(status: PaywallStatus.done));
  }

  void _emitIfActive(PaywallState next) {
    if (!isClosed && state.status != PaywallStatus.done) {
      emit(next);
    }
  }

  void _logViewIfNeeded() {
    if (_didLogView || state.status == PaywallStatus.done) {
      return;
    }
    _didLogView = true;
    _analytics.log(
      AnalyticsEventName.paywallViewed,
      parameters: {
        'placement': _placement,
        'reason': _reasonName,
        'variant': 'subscription_v1',
        'selected_plan': state.selectedOption.name,
      },
    );
  }

  Package? _findByType(List<Package> packages, PackageType type) {
    for (final package in packages) {
      if (package.packageType == type) {
        return package;
      }
    }
    return null;
  }

  Package? _findByPeriod(List<Package> packages, String periodCode) {
    for (final package in packages) {
      if (package.storeProduct.subscriptionPeriod == periodCode) {
        return package;
      }
    }
    return null;
  }

  Package? _firstDifferent(List<Package> packages, Package? excluded) {
    for (final package in packages) {
      if (excluded == null || package.identifier != excluded.identifier) {
        return package;
      }
    }
    return null;
  }
}
