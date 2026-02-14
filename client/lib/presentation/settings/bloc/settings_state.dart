part of 'settings_cubit.dart';

enum SettingsStatus { loading, ready, error }

enum SettingsDestination { signIn }

@freezed
abstract class SettingsNavigation with _$SettingsNavigation {
  const factory SettingsNavigation({required SettingsDestination destination}) =
      _SettingsNavigation;
}

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(SettingsStatus.loading) SettingsStatus status,
    String? email,
    String? baseCurrency,
    String? plan,
    String? failureCode,
    String? failureMessage,
    @Default(false) bool isSigningOut,
    SettingsNavigation? navigation,
  }) = _SettingsState;
}
