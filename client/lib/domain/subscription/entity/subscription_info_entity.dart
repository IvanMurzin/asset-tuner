import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_info_entity.freezed.dart';

@freezed
abstract class SubscriptionInfoEntity with _$SubscriptionInfoEntity {
  const factory SubscriptionInfoEntity({
    required bool isPro,
    @Default([]) List<String> activeProductIds,
  }) = _SubscriptionInfoEntity;
}
