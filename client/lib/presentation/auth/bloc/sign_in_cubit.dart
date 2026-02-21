import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/usecase/get_auth_providers_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/oauth_sign_in_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_in_with_password_usecase.dart';

part 'sign_in_state.dart';
part 'sign_in_cubit.freezed.dart';

@injectable
class SignInCubit extends Cubit<SignInState> {
  SignInCubit(
    this._signInWithPasswordUseCase,
    this._oAuthSignInUseCase,
    this._getAuthProvidersUseCase,
  ) : super(const SignInState()) {
    _loadProviders();
  }

  final SignInWithPasswordUseCase _signInWithPasswordUseCase;
  final OAuthSignInUseCase _oAuthSignInUseCase;
  final GetAuthProvidersUseCase _getAuthProvidersUseCase;

  void updateEmail(String value) {
    emit(
      state.copyWith(email: value, emailError: null, bannerFailureCode: null),
    );
  }

  void updatePassword(String value) {
    emit(
      state.copyWith(
        password: value,
        passwordError: null,
        bannerFailureCode: null,
      ),
    );
  }

  Future<void> signIn() async {
    if (!_isValidEmail(state.email)) {
      emit(state.copyWith(emailError: SignInFieldError.invalidEmail));
      return;
    }
    if (!_isValidPassword(state.password)) {
      emit(state.copyWith(passwordError: SignInFieldError.weakPassword));
      return;
    }

    emit(state.copyWith(status: SignInStatus.loading, bannerFailureCode: null));
    final result = await _signInWithPasswordUseCase(
      state.email.trim(),
      state.password,
    );
    if (isClosed) return;
    switch (result) {
      case FailureResult(:final failure):
        emit(
          state.copyWith(
            status: SignInStatus.idle,
            bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
          ),
        );
      case Success():
        _emitSuccessNavigation();
    }
  }

  Future<void> signInWithProvider(AuthProvider provider) async {
    emit(state.copyWith(status: SignInStatus.loading, bannerFailureCode: null));
    final result = await _oAuthSignInUseCase(provider);
    if (isClosed) return;
    switch (result) {
      case FailureResult(:final failure):
        emit(
          state.copyWith(
            status: SignInStatus.idle,
            bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
          ),
        );
      case Success():
        _emitSuccessNavigation();
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  void _emitSuccessNavigation() {
    emit(
      state.copyWith(
        status: SignInStatus.idle,
        navigation: const SignInNavigation(
          destination: SignInDestination.overview,
        ),
      ),
    );
  }

  Future<void> _loadProviders() async {
    final providers = await _getAuthProvidersUseCase();
    if (isClosed) return;
    emit(
      state.copyWith(
        availableProviders: providers
            .where((provider) => provider != AuthProvider.email)
            .toList(),
      ),
    );
  }

  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(trimmed);
  }

  bool _isValidPassword(String password) {
    final hasLetters = password.contains(RegExp(r'[A-Za-z]'));
    final hasNumbers = password.contains(RegExp(r'\d'));
    return password.length >= 6 && hasLetters && hasNumbers;
  }
}
