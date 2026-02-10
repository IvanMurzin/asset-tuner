import 'package:asset_tuner/data/auth/dto/auth_session_dto.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';

abstract final class AuthSessionMapper {
  static AuthSessionEntity toEntity(AuthSessionDto dto) {
    return AuthSessionEntity(userId: dto.userId, email: dto.email);
  }

  static AuthSessionDto toDto(AuthSessionEntity entity) {
    return AuthSessionDto(userId: entity.userId, email: entity.email);
  }
}
