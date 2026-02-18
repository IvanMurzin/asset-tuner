import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';

class ProfileEntity {
  const ProfileEntity({
    this.baseAssetId,
    String? baseCurrencyCode,
    String? baseCurrency,
    required this.plan,
    required this.entitlements,
  }) : baseCurrencyCode = baseCurrencyCode ?? baseCurrency ?? 'USD';

  final String? baseAssetId;
  final String baseCurrencyCode;
  final String plan;
  final EntitlementsEntity entitlements;

  // Backward-compatible alias for existing presentation logic.
  String get baseCurrency => baseCurrencyCode;

  ProfileEntity copyWith({
    String? baseAssetId,
    String? baseCurrencyCode,
    String? baseCurrency,
    String? plan,
    EntitlementsEntity? entitlements,
  }) {
    return ProfileEntity(
      baseAssetId: baseAssetId ?? this.baseAssetId,
      baseCurrencyCode:
          baseCurrencyCode ?? baseCurrency ?? this.baseCurrencyCode,
      plan: plan ?? this.plan,
      entitlements: entitlements ?? this.entitlements,
    );
  }
}
