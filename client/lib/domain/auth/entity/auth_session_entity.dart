import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session_entity.freezed.dart';

@freezed
abstract class AuthSessionEntity with _$AuthSessionEntity {
  const factory AuthSessionEntity({
    required String userId,
    required String email,
  }) = _AuthSessionEntity;
}
