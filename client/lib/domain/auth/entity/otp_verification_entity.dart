import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_verification_entity.freezed.dart';

@freezed
abstract class OtpVerificationEntity with _$OtpVerificationEntity {
  const factory OtpVerificationEntity({
    required String userId,
    required String email,
  }) = _OtpVerificationEntity;
}
