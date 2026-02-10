import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_asset_entity.freezed.dart';

@freezed
abstract class AccountAssetEntity with _$AccountAssetEntity {
  const factory AccountAssetEntity({
    required String id,
    required String accountId,
    required String assetId,
    required DateTime createdAt,
    int? sortOrder,
  }) = _AccountAssetEntity;
}
