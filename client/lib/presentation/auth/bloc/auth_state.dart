part of 'auth_cubit.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

enum RevenueCatIdentityStatus { idle, syncing, synced, error }

@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus status,
    AuthSessionEntity? session,
    @Default(false) bool isSigningOut,
    @Default(false) bool isDeletingAccount,
    @Default(RevenueCatIdentityStatus.idle) RevenueCatIdentityStatus revenueCatStatus,
    String? revenueCatUserId,
    String? revenueCatFailureCode,
    String? revenueCatFailureMessage,
    String? failureCode,
    String? failureMessage,
  }) = _AuthState;

  bool get isAuthenticated => status == AuthStatus.authenticated && session != null;

  bool get isResolved => status != AuthStatus.initial;

  bool get isRevenueCatReady =>
      isAuthenticated &&
      revenueCatStatus == RevenueCatIdentityStatus.synced &&
      revenueCatUserId == session?.userId;

  bool get isBusy => isSigningOut || isDeletingAccount;
}
