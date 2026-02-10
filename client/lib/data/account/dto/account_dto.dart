import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/json_name.dart';

part 'account_dto.freezed.dart';
part 'account_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class AccountDto with _$AccountDto {
  const factory AccountDto({
    required String id,
    @JsonName('user_id') required String userId,
    required String name,
    required String type,
    required bool archived,
    @JsonName('created_at') required String createdAtIso,
    @JsonName('updated_at') required String updatedAtIso,
  }) = _AccountDto;

  factory AccountDto.fromJson(Map<String, dynamic> json) {
    return _$AccountDtoFromJson(json);
  }
}
