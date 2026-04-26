part of 'session_cubit.dart';

enum SessionStatus { initial, authenticated, unauthenticated, error }

enum RevenueCatIdentityStatus { idle, syncing, synced, error }

@freezed
abstract class SessionState with _$SessionState {
  const SessionState._();

  const factory SessionState({
    @Default(SessionStatus.initial) SessionStatus status,
    AuthSessionEntity? session,
    @Default(false) bool isSigningOut,
    @Default(false) bool isDeletingAccount,
    @Default(RevenueCatIdentityStatus.idle) RevenueCatIdentityStatus revenueCatStatus,
    String? revenueCatUserId,
    String? revenueCatFailureCode,
    String? revenueCatFailureMessage,
    String? failureCode,
    String? failureMessage,
  }) = _SessionState;

  bool get isAuthenticated => status == SessionStatus.authenticated && session != null;

  bool get isRevenueCatReady =>
      isAuthenticated &&
      revenueCatStatus == RevenueCatIdentityStatus.synced &&
      revenueCatUserId == session?.userId;

  bool get isBusy => isSigningOut || isDeletingAccount;
}
