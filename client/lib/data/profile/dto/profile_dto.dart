import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/json_name.dart';

part 'profile_dto.freezed.dart';
part 'profile_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class ProfileDto with _$ProfileDto {
  const factory ProfileDto({
    @JsonName('user_id') required String userId,
    @JsonName('base_currency') required String baseCurrency,
    required String plan,
  }) = _ProfileDto;

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return _$ProfileDtoFromJson(json);
  }
}
