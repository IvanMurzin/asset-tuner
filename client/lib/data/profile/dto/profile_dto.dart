import 'package:asset_tuner/data/profile/dto/entitlements_dto.dart';

class ProfileDto {
  const ProfileDto({
    required this.baseAssetId,
    required this.baseCurrencyCode,
    required this.plan,
    required this.entitlements,
  });

  final String? baseAssetId;
  final String baseCurrencyCode;
  final String plan;
  final EntitlementsDto entitlements;

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      baseAssetId: json['base_asset_id'] as String?,
      baseCurrencyCode: (json['base_currency_code'] as String?) ?? 'USD',
      plan: ((json['plan'] as String?) ?? 'free').toLowerCase(),
      entitlements: EntitlementsDto.fromJson(
        (json['entitlements'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
      ),
    );
  }

  factory ProfileDto.fromMeJson(Map<String, dynamic> json) {
    final profile =
        (json['profile'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final limits =
        (json['limits'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final baseAsset = json['baseAsset'] as Map<String, dynamic>?;

    return ProfileDto(
      baseAssetId: profile['base_asset_id'] as String?,
      baseCurrencyCode: (baseAsset?['code'] as String?) ?? 'USD',
      plan: ((profile['plan'] as String?) ?? 'free').toLowerCase(),
      entitlements: EntitlementsDto.fromJson(limits),
    );
  }
}
