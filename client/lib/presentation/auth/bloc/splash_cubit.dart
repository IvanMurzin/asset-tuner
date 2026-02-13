import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/restore_session_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_out_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';

part 'splash_state.dart';
part 'splash_cubit.freezed.dart';

enum SplashDestination { signIn, onboardingBaseCurrency, main }

@injectable
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._restoreSessionUseCase,
    this._bootstrapProfileUseCase,
    this._signOutUseCase,
  ) : super(const SplashState.loading(stage: SplashStage.restoring)) {
    restore();
  }

  final RestoreSessionUseCase _restoreSessionUseCase;
  final BootstrapProfileUseCase _bootstrapProfileUseCase;
  final SignOutUseCase _signOutUseCase;

  Future<void> restore() async {
    emit(const SplashState.loading(stage: SplashStage.restoring));
    final sessionResult = await _restoreSessionUseCase();
    if (isClosed) return;
    switch (sessionResult) {
      case FailureResult(:final failure):
        if (failure.code == 'unauthorized') {
          await _signOutUseCase();
          if (isClosed) return;
          emit(const SplashState.route(destination: SplashDestination.signIn));
        } else {
          emit(SplashState.error(failureCode: failure.code));
        }
      case Success(:final value):
        if (value == null) {
          emit(const SplashState.route(destination: SplashDestination.signIn));
          return;
        }
        emit(const SplashState.loading(stage: SplashStage.preparingProfile));
        final profileResult = await _bootstrapProfileUseCase();
        if (isClosed) return;
        switch (profileResult) {
          case FailureResult(:final failure):
            if (failure.code == 'unauthorized') {
              await _signOutUseCase();
              if (isClosed) return;
              emit(
                const SplashState.route(destination: SplashDestination.signIn),
              );
            } else {
              emit(SplashState.error(failureCode: failure.code));
            }
          case Success(:final value):
            if (value.wasBaseCurrencyDefaulted) {
              emit(
                const SplashState.route(
                  destination: SplashDestination.onboardingBaseCurrency,
                ),
              );
            } else {
              emit(
                const SplashState.route(destination: SplashDestination.main),
              );
            }
        }
    }
  }
}
