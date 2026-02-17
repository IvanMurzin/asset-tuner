import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/subscription/entity/subscription_info_entity.dart';
import 'package:asset_tuner/domain/subscription/repository/i_subscription_repository.dart';

const _proEntitlementId = 'Asset Tuner Pro';

@LazySingleton(as: ISubscriptionRepository)
class SubscriptionRepository implements ISubscriptionRepository {
  @override
  Future<Result<SubscriptionInfoEntity>> getCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return Success(_mapCustomerInfo(customerInfo));
    } catch (e, st) {
      logger.e('SubscriptionRepository.getCustomerInfo failed', error: e, stackTrace: st);
      return FailureResult(_toFailure(e));
    }
  }

  @override
  Future<bool> hasProEntitlement() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final pro = customerInfo.entitlements.all[_proEntitlementId];
      return pro?.isActive ?? false;
    } catch (e, st) {
      logger.e('SubscriptionRepository.hasProEntitlement failed', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<Result<SubscriptionInfoEntity>> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return Success(_mapCustomerInfo(customerInfo));
    } catch (e, st) {
      logger.e('SubscriptionRepository.restorePurchases failed', error: e, stackTrace: st);
      return FailureResult(_toFailure(e));
    }
  }

  SubscriptionInfoEntity _mapCustomerInfo(CustomerInfo customerInfo) {
    final pro = customerInfo.entitlements.all[_proEntitlementId];
    final isPro = pro?.isActive ?? false;
    final activeProductIds = customerInfo.activeSubscriptions;
    return SubscriptionInfoEntity(isPro: isPro, activeProductIds: activeProductIds);
  }

  Failure _toFailure(Object error) {
    if (error is PlatformException) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      return Failure(code: code.name, message: error.message ?? code.name);
    }
    return Failure(code: 'subscription_error', message: error.toString());
  }
}
