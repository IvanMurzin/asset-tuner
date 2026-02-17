part of 'profile_cubit.dart';

enum ProfileStatus { loading, ready, error }

enum ProfileDestination { signIn }

@freezed
abstract class ProfileNavigation with _$ProfileNavigation {
  const factory ProfileNavigation({required ProfileDestination destination}) = _ProfileNavigation;
}

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(ProfileStatus.loading) ProfileStatus status,
    String? email,
    String? baseCurrency,
    String? plan,
    String? failureCode,
    String? failureMessage,
    @Default(false) bool isSigningOut,
    @Default(false) bool isDeletingAccount,
    ProfileNavigation? navigation,
  }) = _ProfileState;
}
