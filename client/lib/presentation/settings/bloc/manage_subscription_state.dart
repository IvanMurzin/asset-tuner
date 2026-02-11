part of 'manage_subscription_cubit.dart';

enum ManageSubscriptionStatus { loading, ready, error }

enum ManageSubscriptionBanner {
  manageSuccess,
  restoreSuccess,
  cancelSuccess,
  updateFailure,
}

@freezed
abstract class ManageSubscriptionState with _$ManageSubscriptionState {
  const factory ManageSubscriptionState({
    @Default(ManageSubscriptionStatus.loading) ManageSubscriptionStatus status,
    String? plan,
    String? failureCode,
    @Default(false) bool isUpdating,
    ManageSubscriptionBanner? banner,
  }) = _ManageSubscriptionState;
}
