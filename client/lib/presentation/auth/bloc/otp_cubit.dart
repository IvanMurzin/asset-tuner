import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/request_email_otp_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/verify_sign_up_otp_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';

part 'otp_state.dart';
part 'otp_cubit.freezed.dart';

@injectable
class OtpCubit extends Cubit<OtpState> {
  OtpCubit(
    this._verifySignUpOtpUseCase,
    this._bootstrapProfileUseCase,
    this._requestEmailOtpUseCase,
  ) : super(const OtpState());

  final VerifySignUpOtpUseCase _verifySignUpOtpUseCase;
  final BootstrapProfileUseCase _bootstrapProfileUseCase;
  final RequestEmailOtpUseCase _requestEmailOtpUseCase;

  static const _resendCooldown = Duration(seconds: 60);

  void setEmail(String email) {
    emit(state.copyWith(email: email));
  }

  void updateCode(String value) {
    emit(state.copyWith(code: value, codeError: null, bannerFailureCode: null));
  }

  Future<void> verify() async {
    final code = state.code.trim();
    if (code.length != 6) {
      emit(state.copyWith(codeError: OtpFieldError.invalidLength));
      return;
    }

    emit(state.copyWith(status: OtpStatus.loading, bannerFailureCode: null));
    final result = await _verifySignUpOtpUseCase(state.email, code);
    if (isClosed) return;
    switch (result) {
      case FailureResult(:final failure):
        emit(
          state.copyWith(
            status: OtpStatus.idle,
            bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
          ),
        );
      case Success():
        final profileResult = await _bootstrapProfileUseCase();
        if (isClosed) return;
        switch (profileResult) {
          case FailureResult(:final failure):
            emit(
              state.copyWith(
                status: OtpStatus.idle,
                bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
              ),
            );
          case Success(:final value):
            emit(
              state.copyWith(
                status: OtpStatus.idle,
                navigation: OtpNavigation(
                  destination: value.wasBaseCurrencyDefaulted
                      ? OtpDestination.onboardingBaseCurrency
                      : OtpDestination.overview,
                ),
              ),
            );
        }
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<void> resend() async {
    final email = state.email;
    if (email.isEmpty || state.isResendInProgress || state.resendCooldownUntil != null) {
      return;
    }
    emit(state.copyWith(isResendInProgress: true, bannerFailureCode: null));
    final result = await _requestEmailOtpUseCase(email);
    if (isClosed) return;
    switch (result) {
      case FailureResult(:final failure):
        emit(
          state.copyWith(
            isResendInProgress: false,
            bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
          ),
        );
      case Success():
        final until = DateTime.now().add(_resendCooldown);
        emit(
          state.copyWith(
            isResendInProgress: false,
            resendCooldownUntil: until,
            resendSuccess: true,
          ),
        );
        Future<void>.delayed(_resendCooldown, () {
          if (!isClosed && state.resendCooldownUntil == until) {
            emit(state.copyWith(resendCooldownUntil: null));
          }
        });
    }
  }

  void clearResendSuccess() {
    emit(state.copyWith(resendSuccess: false));
  }
}
