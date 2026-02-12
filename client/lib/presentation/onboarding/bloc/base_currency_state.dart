part of 'base_currency_cubit.dart';

enum BaseCurrencyStatus { loading, ready, error }

enum BaseCurrencyBannerType { selectCurrency, saveFailure }

enum BaseCurrencyDestination { main, signIn, paywall }

@freezed
abstract class BaseCurrencyNavigation with _$BaseCurrencyNavigation {
  const factory BaseCurrencyNavigation({
    required BaseCurrencyDestination destination,
  }) = _BaseCurrencyNavigation;
}

@freezed
abstract class BaseCurrencyState with _$BaseCurrencyState {
  const factory BaseCurrencyState({
    @Default(BaseCurrencyStatus.loading) BaseCurrencyStatus status,
    @Default([]) List<CurrencyEntity> currencies,
    @Default('') String query,
    String? selectedCode,
    String? loadFailureCode,
    BaseCurrencyBannerType? bannerType,
    String? bannerFailureCode,
    @Default(false) bool isSaving,
    String? plan,
    EntitlementsEntity? entitlements,
    BaseCurrencyNavigation? navigation,
  }) = _BaseCurrencyState;
}
