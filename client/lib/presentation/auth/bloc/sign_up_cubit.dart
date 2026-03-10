import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_up_with_password_usecase.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_form_validators.dart';

part 'sign_up_state.dart';
part 'sign_up_cubit.freezed.dart';

@injectable
class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._signUpWithPasswordUseCase, {bool? isOtpEnabled})
    : _isOtpEnabled = isOtpEnabled ?? AppConfig.instance.isOtpEnabled,
      super(const SignUpState());

  final SignUpWithPasswordUseCase _signUpWithPasswordUseCase;
  final bool _isOtpEnabled;

  void updateEmail(String value) {
    emit(
      state.copyWith(
        email: value,
        emailError: null,
        bannerFailureCode: null,
        bannerType: null,
      ),
    );
  }

  void updatePassword(String value) {
    emit(
      state.copyWith(
        password: value,
        passwordError: null,
        bannerFailureCode: null,
        bannerType: null,
      ),
    );
  }

  void updateConfirmPassword(String value) {
    emit(
      state.copyWith(
        confirmPassword: value,
        confirmPasswordError: null,
        bannerFailureCode: null,
        bannerType: null,
      ),
    );
  }

  Future<void> submit() async {
    if (state.status == SignUpStatus.loading) {
      return;
    }
    final validation = _validate();
    if (!validation) {
      return;
    }

    emit(
      state.copyWith(
        status: SignUpStatus.loading,
        bannerFailureCode: null,
        bannerType: null,
      ),
    );
    final result = await _signUpWithPasswordUseCase(
      state.email.trim(),
      state.password,
    );
    if (isClosed) return;
    switch (result) {
      case FailureResult(:final failure):
        emit(
          state.copyWith(
            status: SignUpStatus.idle,
            bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
            bannerType: SignUpBannerType.failure,
          ),
        );
      case Success(:final value):
        if (_isOtpEnabled) {
          emit(
            state.copyWith(
              status: SignUpStatus.otpSent,
              navigation: SignUpNavigation(email: value.email),
              bannerEmail: value.email,
              bannerType: SignUpBannerType.success,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            status: SignUpStatus.idle,
            navigation: SignUpNavigation(email: value.email),
            bannerEmail: null,
            bannerType: null,
          ),
        );
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  bool _validate() {
    final email = state.email.trim();
    final emailValid = AuthFormValidators.isValidEmail(email);
    final passwordValid = AuthFormValidators.isValidPassword(state.password);
    final confirmValid = state.password == state.confirmPassword;

    if (!emailValid || !passwordValid || !confirmValid) {
      emit(
        state.copyWith(
          emailError: emailValid ? null : SignUpFieldError.invalidEmail,
          passwordError: passwordValid ? null : SignUpFieldError.weakPassword,
          confirmPasswordError: confirmValid ? null : SignUpFieldError.mismatch,
        ),
      );
      return false;
    }
    return true;
  }
}
