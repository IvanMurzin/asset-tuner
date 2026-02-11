import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';

part 'profile_entity.freezed.dart';

@freezed
abstract class ProfileEntity with _$ProfileEntity {
  const factory ProfileEntity({
    required String baseCurrency,
    required String plan,
    required EntitlementsEntity entitlements,
  }) = _ProfileEntity;
}
