import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_dto.freezed.dart';
part 'asset_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class AssetDto with _$AssetDto {
  const factory AssetDto({
    required String id,
    required String kind,
    required String code,
    required String name,
    int? decimals,
  }) = _AssetDto;

  factory AssetDto.fromJson(Map<String, dynamic> json) {
    return _$AssetDtoFromJson(json);
  }
}
