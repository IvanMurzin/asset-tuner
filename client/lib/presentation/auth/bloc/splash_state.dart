part of 'splash_cubit.dart';

enum SplashStage { restoring, preparingProfile }

@freezed
sealed class SplashState with _$SplashState {
  const factory SplashState.loading({required SplashStage stage}) =
      SplashLoading;
  const factory SplashState.error({
    required String failureCode,
    String? failureMessage,
  }) = SplashError;
  const factory SplashState.route({required SplashDestination destination}) =
      SplashRoute;
}
