part of 'otp_cubit.dart';

enum OtpStatus { idle, loading }

enum OtpFieldError { invalidLength }

enum OtpDestination { onboardingBaseCurrency, overview, signIn }

@freezed
abstract class OtpNavigation with _$OtpNavigation {
  const factory OtpNavigation({required OtpDestination destination}) =
      _OtpNavigation;
}

@freezed
abstract class OtpState with _$OtpState {
  const factory OtpState({
    @Default('') String email,
    @Default('') String code,
    OtpFieldError? codeError,
    String? bannerFailureCode,
    String? bannerFailureMessage,
    @Default(OtpStatus.idle) OtpStatus status,
    OtpNavigation? navigation,
    @Default(false) bool isResendInProgress,
    DateTime? resendCooldownUntil,
    @Default(false) bool resendSuccess,
  }) = _OtpState;
}
