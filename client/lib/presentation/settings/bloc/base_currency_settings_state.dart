part of 'base_currency_settings_cubit.dart';

enum BaseCurrencySettingsStatus { loading, ready, error }

enum BaseCurrencySettingsBannerType { saveFailure }

enum BaseCurrencySettingsDestination { back, signIn, paywall }

@freezed
abstract class BaseCurrencySettingsNavigation
    with _$BaseCurrencySettingsNavigation {
  const factory BaseCurrencySettingsNavigation({
    required BaseCurrencySettingsDestination destination,
    String? requestedCode,
  }) = _BaseCurrencySettingsNavigation;
}

@freezed
abstract class BaseCurrencySettingsState with _$BaseCurrencySettingsState {
  const factory BaseCurrencySettingsState({
    @Default(BaseCurrencySettingsStatus.loading)
    BaseCurrencySettingsStatus status,
    @Default([]) List<CurrencyEntity> currencies,
    @Default([]) List<CurrencyEntity> visibleCurrencies,
    @Default(false) bool hasMoreResults,
    @Default(false) bool showAll,
    @Default('') String query,
    String? currentCode,
    String? selectedCode,
    String? plan,
    EntitlementsEntity? entitlements,
    String? loadFailureCode,
    BaseCurrencySettingsBannerType? bannerType,
    String? bannerFailureCode,
    @Default(false) bool isSaving,
    BaseCurrencySettingsNavigation? navigation,
  }) = _BaseCurrencySettingsState;
}
