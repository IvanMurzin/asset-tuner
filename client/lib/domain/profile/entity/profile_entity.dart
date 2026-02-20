import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';

part 'profile_entity.freezed.dart';

@freezed
abstract class ProfileEntity with _$ProfileEntity {
  const ProfileEntity._();

  const factory ProfileEntity({
    String? userId,
    String? baseAssetId,
    AssetEntity? baseAsset,
    String? revenuecatAppUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    required String plan,
    required EntitlementsEntity entitlements,
  }) = _ProfileEntity;

  String get baseCurrency => baseAsset?.code ?? 'USD';
}
