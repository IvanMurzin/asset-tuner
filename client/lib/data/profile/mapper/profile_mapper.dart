import 'package:asset_tuner/data/profile/dto/profile_dto.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';

abstract final class ProfileMapper {
  static ProfileEntity toEntity(ProfileDto dto) {
    return ProfileEntity(
      userId: dto.userId,
      baseCurrency: dto.baseCurrency,
      plan: dto.plan,
    );
  }

  static ProfileDto toDto(ProfileEntity entity) {
    return ProfileDto(
      userId: entity.userId,
      baseCurrency: entity.baseCurrency,
      plan: entity.plan,
    );
  }
}
