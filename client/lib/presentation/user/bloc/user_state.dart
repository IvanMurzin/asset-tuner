part of 'user_cubit.dart';

enum UserStatus { initial, loading, authenticated, unauthenticated, error }

enum UserDestination { signIn, main }

@freezed
abstract class UserNavigation with _$UserNavigation {
  const factory UserNavigation(UserDestination destination) = _UserNavigation;
}

@freezed
abstract class UserState with _$UserState {
  const UserState._();

  const factory UserState({
    @Default(UserStatus.initial) UserStatus status,
    AuthSessionEntity? session,
    ProfileEntity? profile,
    String? failureCode,
    String? failureMessage,
    UserNavigation? navigation,
    @Default(false) bool isUpdatingBaseCurrency,
    @Default(false) bool isSyncingSubscription,
  }) = _UserState;

  bool get isAuthenticated =>
      status == UserStatus.authenticated && session != null && profile != null;
}
