import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/request_password_reset_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/reset_password_usecase.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_form_validators.dart';

part 'reset_password_state.dart';
part 'reset_password_cubit.freezed.dart';

/// Password reset by an emailed 6-digit code: request the code, then send the code together with
/// the new password. Success signs the user in.
@injectable
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit(this._requestPasswordReset, this._resetPassword)
    : super(const ResetPasswordState());

  final RequestPasswordResetUseCase _requestPasswordReset;
  final ResetPasswordUseCase _resetPassword;

  /// Supabase sends at most one email per address per minute.
  static const resendCooldown = Duration(seconds: 60);

  void setInitialEmail(String email) {
    emit(state.copyWith(email: email.trim()));
  }

  void updateEmail(String value) {
    emit(state.copyWith(email: value, emailError: null, bannerFailureCode: null));
  }

  void updateCode(String value) {
    emit(state.copyWith(code: value, codeError: null, bannerFailureCode: null));
  }

  void updatePassword(String value) {
    emit(state.copyWith(password: value, passwordError: null, bannerFailureCode: null));
  }

  void updateConfirmPassword(String value) {
    emit(
      state.copyWith(confirmPassword: value, confirmPasswordError: null, bannerFailureCode: null),
    );
  }

  Future<void> requestCode() async {
    final email = state.email.trim();
    if (!AuthFormValidators.isValidEmail(email)) {
      emit(state.copyWith(emailError: ResetPasswordFieldError.invalidEmail));
      return;
    }
    emit(
      state.copyWith(email: email, status: ResetPasswordStatus.loading, bannerFailureCode: null),
    );
    final result = await _requestPasswordReset(email);
    if (isClosed) return;
    switch (result) {
      case FailureResult(:final failure):
        emit(
          state.copyWith(
            status: ResetPasswordStatus.idle,
            bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
          ),
        );
      case Success():
        emit(state.copyWith(status: ResetPasswordStatus.idle, step: ResetPasswordStep.code));
        _startCooldown();
    }
  }

  Future<void> resend() async {
    if (state.isResendInProgress || state.resendCooldownUntil != null) {
      return;
    }
    emit(state.copyWith(isResendInProgress: true, bannerFailureCode: null));
    final result = await _requestPasswordReset(state.email);
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
        emit(state.copyWith(isResendInProgress: false, resendSuccess: true));
        _startCooldown();
    }
  }

  void clearResendSuccess() {
    emit(state.copyWith(resendSuccess: false));
  }

  /// Back to the email step, e.g. after a typo in the address.
  void changeEmail() {
    emit(
      state.copyWith(
        step: ResetPasswordStep.email,
        code: '',
        codeError: null,
        bannerFailureCode: null,
      ),
    );
  }

  Future<void> submit() async {
    final code = state.code.trim();
    final codeError = AuthFormValidators.isValidOtpCode(code)
        ? null
        : ResetPasswordFieldError.invalidCode;
    final passwordError = AuthFormValidators.isValidPassword(state.password)
        ? null
        : ResetPasswordFieldError.weakPassword;
    final confirmPasswordError = state.confirmPassword.isEmpty
        ? ResetPasswordFieldError.confirmRequired
        : (state.confirmPassword == state.password ? null : ResetPasswordFieldError.mismatch);
    if (codeError != null || passwordError != null || confirmPasswordError != null) {
      emit(
        state.copyWith(
          codeError: codeError,
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ResetPasswordStatus.loading, bannerFailureCode: null));
    final result = await _resetPassword(
      email: state.email,
      code: code,
      newPassword: state.password,
    );
    if (isClosed) return;
    switch (result) {
      case FailureResult(:final failure):
        emit(
          state.copyWith(
            status: ResetPasswordStatus.idle,
            bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
          ),
        );
      case Success():
        emit(state.copyWith(status: ResetPasswordStatus.idle, step: ResetPasswordStep.done));
    }
  }

  void _startCooldown() {
    final until = DateTime.now().add(resendCooldown);
    emit(state.copyWith(resendCooldownUntil: until));
    Future<void>.delayed(resendCooldown, () {
      if (!isClosed && state.resendCooldownUntil == until) {
        emit(state.copyWith(resendCooldownUntil: null));
      }
    });
  }
}
