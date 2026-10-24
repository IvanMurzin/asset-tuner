import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_result_entity.freezed.dart';

/// What a successful email sign-up leads to.
@freezed
sealed class SignUpResultEntity with _$SignUpResultEntity {
  /// The account needs the emailed code before it can sign in.
  const factory SignUpResultEntity.otpRequired({required String email}) = SignUpOtpRequired;

  /// The user is already signed in (OTP is off).
  const factory SignUpResultEntity.signedIn() = SignUpSignedIn;
}
