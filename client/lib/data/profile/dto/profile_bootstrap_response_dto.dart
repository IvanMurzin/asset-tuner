import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/json_name.dart';
import 'package:asset_tuner/data/profile/dto/profile_dto.dart';

part 'profile_bootstrap_response_dto.freezed.dart';
part 'profile_bootstrap_response_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class ProfileBootstrapResponseDto with _$ProfileBootstrapResponseDto {
  const factory ProfileBootstrapResponseDto({
    required ProfileDto profile,
    @JsonName('is_new') required bool isNew,
    @JsonName('was_base_currency_defaulted') required bool wasBaseCurrencyDefaulted,
  }) = _ProfileBootstrapResponseDto;

  factory ProfileBootstrapResponseDto.fromJson(Map<String, dynamic> json) {
    return _$ProfileBootstrapResponseDtoFromJson(json);
  }
}
