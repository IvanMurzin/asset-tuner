import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/subscription/entity/subscription_info_entity.dart';

abstract interface class ISubscriptionRepository {
  Future<Result<SubscriptionInfoEntity>> getCustomerInfo();

  Future<bool> hasProEntitlement();

  Future<Result<SubscriptionInfoEntity>> restorePurchases();
}
