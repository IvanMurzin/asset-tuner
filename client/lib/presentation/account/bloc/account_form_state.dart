part of 'account_form_cubit.dart';

enum AccountFormStatus { loading, ready, error }

enum AccountFormDestination { signIn, paywall, backSaved }

@freezed
abstract class AccountFormNavigation with _$AccountFormNavigation {
  const factory AccountFormNavigation({
    required AccountFormDestination destination,
    String? accountId,
  }) = _AccountFormNavigation;
}

@freezed
abstract class AccountFormState with _$AccountFormState {
  const factory AccountFormState({
    @Default(AccountFormStatus.loading) AccountFormStatus status,
    String? plan,
    EntitlementsEntity? entitlements,
    @Default(0) int activeAccountCount,
    String? accountId,
    String? initialName,
    @Default('') String name,
    AccountType? type,
    String? nameError,
    String? failureCode,
    @Default(false) bool isSaving,
    AccountFormNavigation? navigation,
  }) = _AccountFormState;
}
