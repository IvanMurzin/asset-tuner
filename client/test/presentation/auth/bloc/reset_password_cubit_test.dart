import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/request_password_reset_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/reset_password_usecase.dart';
import 'package:asset_tuner/presentation/auth/bloc/reset_password_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeAuthRepository repository;
  late ResetPasswordCubit cubit;

  setUp(() {
    repository = _FakeAuthRepository();
    cubit = ResetPasswordCubit(
      RequestPasswordResetUseCase(repository),
      ResetPasswordUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  Future<void> toCodeStep() async {
    cubit.updateEmail(' u@example.com ');
    await cubit.requestCode();
  }

  void fillValidForm() {
    cubit
      ..updateCode('123456')
      ..updatePassword('NewPass1')
      ..updateConfirmPassword('NewPass1');
  }

  test('an invalid email stays on the email step without a request', () async {
    cubit.updateEmail('nope');
    await cubit.requestCode();

    expect(cubit.state.emailError, ResetPasswordFieldError.invalidEmail);
    expect(cubit.state.step, ResetPasswordStep.email);
    expect(repository.requestedEmails, isEmpty);
  });

  test('a sent code moves to the code step and starts the resend cooldown', () async {
    await toCodeStep();

    expect(repository.requestedEmails, ['u@example.com']);
    expect(cubit.state.step, ResetPasswordStep.code);
    expect(cubit.state.resendCooldownUntil, isNotNull);

    await cubit.resend();
    expect(repository.requestedEmails, hasLength(1), reason: 'cooldown blocks a resend');
  });

  test('a failed request keeps the email step and shows the failure', () async {
    repository.requestFailure = const Failure(code: 'over_email_send_rate_limit', message: 'wait');
    await toCodeStep();

    expect(cubit.state.step, ResetPasswordStep.email);
    expect(cubit.state.bannerFailureCode, 'over_email_send_rate_limit');
  });

  test('submit validates code, password and confirmation together', () async {
    await toCodeStep();
    cubit
      ..updateCode('12')
      ..updatePassword('short')
      ..updateConfirmPassword('other');

    await cubit.submit();

    expect(cubit.state.codeError, ResetPasswordFieldError.invalidCode);
    expect(cubit.state.passwordError, ResetPasswordFieldError.weakPassword);
    expect(cubit.state.confirmPasswordError, ResetPasswordFieldError.mismatch);
    expect(repository.resets, isEmpty);
  });

  test('a valid form resets the password and finishes', () async {
    await toCodeStep();
    fillValidForm();

    await cubit.submit();

    expect(repository.resets, [(email: 'u@example.com', code: '123456', password: 'NewPass1')]);
    expect(cubit.state.step, ResetPasswordStep.done);
  });

  test('an expired code keeps the form so the user can resend', () async {
    repository.resetFailure = const Failure(code: 'otp_expired', message: 'expired');
    await toCodeStep();
    fillValidForm();

    await cubit.submit();

    expect(cubit.state.step, ResetPasswordStep.code);
    expect(cubit.state.status, ResetPasswordStatus.idle);
    expect(cubit.state.bannerFailureCode, 'otp_expired');
    expect(cubit.state.password, 'NewPass1');
  });

  test('change email returns to the email step and clears the code', () async {
    await toCodeStep();
    cubit.updateCode('123456');

    cubit.changeEmail();

    expect(cubit.state.step, ResetPasswordStep.email);
    expect(cubit.state.code, isEmpty);
    expect(cubit.state.email, 'u@example.com');
  });
}

class _FakeAuthRepository implements IAuthRepository {
  final requestedEmails = <String>[];
  final resets = <({String email, String code, String password})>[];
  Failure? requestFailure;
  Failure? resetFailure;

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    final failure = requestFailure;
    if (failure != null) {
      return FailureResult(failure);
    }
    requestedEmails.add(email);
    return const Success(null);
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final failure = resetFailure;
    if (failure != null) {
      return FailureResult(failure);
    }
    resets.add((email: email, code: code, password: newPassword));
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
