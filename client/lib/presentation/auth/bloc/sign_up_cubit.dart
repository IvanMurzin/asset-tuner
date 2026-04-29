import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/usecase/get_auth_providers_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/oauth_sign_in_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_up_with_password_usecase.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_form_validators.dart';

part 'sign_up_state.dart';
part 'sign_up_cubit.freezed.dart';

@injectable
class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(
    this._signUpWithPasswordUseCase,
    this._oAuthSignInUseCase,
    this._getAuthProvidersUseCase,
    this._analytics,
  ) : _isOtpEnabledOverride = null,
      super(const SignUpState()) {
    _loadProviders();
  }

  SignUpCubit.testing(
    this._signUpWithPasswordUseCase,
    this._oAuthSignInUseCase,
    this._getAuthProvidersUseCase,
    this._analytics, {
    required bool isOtpEnabled,
  }) : _isOtpEnabledOverride = isOtpEnabled,
       super(const SignUpState()) {
    _loadProviders();
  }

  final SignUpWithPasswordUseCase _signUpWithPasswordUseCase;
  final OAuthSignInUseCase _oAuthSignInUseCase;
  final GetAuthProvidersUseCase _getAuthProvidersUseCase;
  final AppAnalytics _analytics;
  final bool? _isOtpEnabledOverride;

  bool get _isOtpEnabled => _isOtpEnabledOverride ?? AppConfig.instance.isOtpEnabled;

  void updateEmail(String value) {
    emit(state.copyWith(email: value, emailError: null, bannerFailureCode: null, bannerType: null));
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

    emit(state.copyWith(status: SignUpStatus.loading, bannerFailureCode: null, bannerType: null));
    _analytics.log(
      AnalyticsEventName.authStarted,
      parameters: {AnalyticsParams.provider: 'email', AnalyticsParams.mode: 'signup'},
    );
    final result = await _signUpWithPasswordUseCase(state.email.trim(), state.password);
    if (isClosed) return;
    switch (result) {
      case FailureResult(:final failure):
        _analytics.log(
          AnalyticsEventName.authFailed,
          parameters: {
            AnalyticsParams.provider: 'email',
            AnalyticsParams.mode: 'signup',
            AnalyticsParams.errorCode: failure.code,
          },
        );
        emit(
          state.copyWith(
            status: SignUpStatus.idle,
            bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
            bannerType: SignUpBannerType.failure,
          ),
        );
      case Success(:final value):
        _analytics.log(
          AnalyticsEventName.authCompleted,
          parameters: {
            AnalyticsParams.provider: 'email',
            AnalyticsParams.mode: 'signup',
            'otp_required': _isOtpEnabled,
          },
        );
        if (_isOtpEnabled) {
          emit(
            state.copyWith(
              status: SignUpStatus.otpSent,
              otpEmail: value.email,
              bannerEmail: value.email,
              bannerType: SignUpBannerType.success,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            status: SignUpStatus.idle,
            otpEmail: null,
            bannerEmail: null,
            bannerType: null,
          ),
        );
    }
  }

  Future<void> signUpWithProvider(AuthProvider provider) async {
    if (state.status == SignUpStatus.loading) {
      return;
    }
    emit(state.copyWith(status: SignUpStatus.loading, bannerFailureCode: null, bannerType: null));
    _analytics.log(
      AnalyticsEventName.authStarted,
      parameters: {AnalyticsParams.provider: provider.name, AnalyticsParams.mode: 'signup'},
    );
    final result = await _oAuthSignInUseCase(provider);
    if (isClosed) return;
    switch (result) {
      case FailureResult(:final failure):
        _analytics.log(
          AnalyticsEventName.authFailed,
          parameters: {
            AnalyticsParams.provider: provider.name,
            AnalyticsParams.mode: 'signup',
            AnalyticsParams.errorCode: failure.code,
          },
        );
        emit(
          state.copyWith(
            status: SignUpStatus.idle,
            bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
            bannerType: SignUpBannerType.failure,
          ),
        );
      case Success():
        _analytics.log(
          AnalyticsEventName.authCompleted,
          parameters: {AnalyticsParams.provider: provider.name, AnalyticsParams.mode: 'signup'},
        );
        emit(state.copyWith(status: SignUpStatus.idle));
    }
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

  Future<void> _loadProviders() async {
    final providers = await _getAuthProvidersUseCase();
    if (isClosed) return;
    emit(
      state.copyWith(
        availableProviders: providers.where((provider) => provider != AuthProvider.email).toList(),
      ),
    );
  }
}
