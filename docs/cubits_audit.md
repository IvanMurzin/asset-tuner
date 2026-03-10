# Аудит Cubit в проекте `client`

## Что именно проверено
- Все `Cubit`, найденные по `extends Cubit` (21 шт.).
- Где каждый кубит создается (`BlocProvider` / `MultiBlocProvider`).
- Где вызываются его публичные методы (инициализация, кнопки, pull-to-refresh, listeners).
- Какие сетевые вызовы уходят по цепочке `Cubit -> UseCase -> Repository -> DataSource`.

## Общие правила жизненного цикла
- Для кубитов, созданных через `BlocProvider(create: ...)`, закрытие происходит автоматически при dispose соответствующего виджета/роута.
- Глобальные кубиты из `App` живут весь жизненный цикл приложения.
- `UsdRatesCubit` дополнительно переопределяет `close()` и останавливает таймер.

## Справочник серверных маршрутов (Supabase Edge Functions)
- `GET api/me`
- `POST api/profile/update`
- `POST api/delete_my_account`
- `GET api/assets/list`
- `GET api/rates/usd`
- `GET api/accounts/list`
- `POST api/accounts/create`
- `POST api/accounts/update`
- `POST api/accounts/delete`
- `GET api/subaccounts/list`
- `POST api/subaccounts/create`
- `POST api/subaccounts/update`
- `POST api/subaccounts/delete`
- `POST api/subaccounts/set_balance`
- `GET api/subaccounts/history`
- `POST api/revenuecat/refresh`

Также используются сетевые методы Supabase Auth SDK (`signInWithPassword`, `signUp`, `verifyOTP`, `signInWithOtp`, `signInWithOAuth`, `signOut`) и RevenueCat SDK (`Purchases.getCustomerInfo`, `Purchases.restorePurchases`, `RevenueCatUI.presentPaywall`, `RevenueCatUI.presentCustomerCenter`).

---

## 1) `LocaleCubit`
- Где живет: `client/lib/core/localization/locale_cubit.dart`
- Где создается: `client/lib/app.dart:20`
- Где удаляется: при dispose корневого `MultiBlocProvider` в `App`
- Когда вызывается:
  - `load()` сразу при создании: `client/lib/app.dart:20`
  - `setLocale(...)` из селектора языка: `client/lib/presentation/profile/widget/profile_language_selector.dart:58`, `:61`
- Запросы к серверу: нет (только локальное хранилище + локализация ошибок)

## 2) `ThemeModeCubit`
- Где живет: `client/lib/core_ui/theme/theme_mode_cubit.dart`
- Где создается: `client/lib/app.dart:19`
- Где удаляется: при dispose корневого `MultiBlocProvider` в `App`
- Когда вызывается:
  - `_load()` автоматически в конструкторе
  - `set(...)` из UI темы: `client/lib/presentation/profile/widget/profile_theme_selector.dart:38`
  - также в DS preview: `client/lib/core_ui/preview/ds_preview_page.dart:345`
- Запросы к серверу: нет (только локальное хранилище)

## 3) `UsdRatesCubit`
- Где живет: `client/lib/presentation/rate/bloc/usd_rates_cubit.dart`
- Где создается: `client/lib/app.dart:21`
- Где удаляется: при dispose корневого `MultiBlocProvider`; в `close()` отменяет timer
- Когда вызывается:
  - `start()` автоматически в конструкторе
  - `refresh()` при старте и далее по таймеру раз в минуту
- Запросы к серверу:
  - `GET api/assets/list?kind=fiat&limit=100`
  - `GET api/assets/list?kind=crypto&limit=100`
  - `GET api/rates/usd?assetIds=...`
  - Примечание: при наличии кэша может отдавать локальные данные и обновлять в фоне

## 4) `SplashCubit`
- Где живет: `client/lib/presentation/auth/bloc/splash_cubit.dart`
- Где создается: `client/lib/presentation/auth/page/splash_page.dart:21`
- Где удаляется: при выходе со `SplashPage`
- Когда вызывается:
  - `restore()` автоматически в конструкторе
  - повторно по Retry: `client/lib/presentation/auth/page/splash_page.dart:62`
- Запросы к серверу:
  - `GET api/me` (через `BootstrapProfileUseCase`)
  - `auth.signOut()` при невалидной сессии
  - восстановление session теперь идёт через `watchSession()` в auth-репозитории, с immediate emission cached/current session без отдельного `restoreSession()` контракта

## 5) `SignInCubit`
- Где живет: `client/lib/presentation/auth/bloc/sign_in_cubit.dart`
- Где создается: `client/lib/presentation/auth/page/sign_in_page.dart:25`
- Где удаляется: при выходе со `SignInPage`
- Когда вызывается:
  - `_loadProviders()` автоматически в конструкторе
  - `updateEmail` / `updatePassword` из полей: `sign_in_email_field.dart:59`, `sign_in_password_field.dart:58`
  - `signIn()` по кнопке: `sign_in_page.dart:115`
  - `signInWithProvider(...)` из OAuth секции: `oauth_section.dart:36`
- Запросы к серверу:
  - `auth.signInWithPassword(email, password)`
  - `auth.signInWithOAuth(google|apple)`
  - после входа: `GET api/me` (bootstrap profile)

## 6) `SignUpCubit`
- Где живет: `client/lib/presentation/auth/bloc/sign_up_cubit.dart`
- Где создается: `client/lib/presentation/auth/page/sign_up_page.dart:25`
- Где удаляется: при выходе со `SignUpPage`
- Когда вызывается:
  - `updateEmail` / `updatePassword` / `updateConfirmPassword` из полей
  - `submit()` по кнопке: `sign_up_page.dart:115`
- Запросы к серверу:
  - `auth.signUp(email, password)`

## 7) `OtpCubit`
- Где живет: `client/lib/presentation/auth/bloc/otp_cubit.dart`
- Где создается: `client/lib/presentation/auth/page/otp_page.dart:43`
- Где удаляется: при выходе со `OtpPage`
- Когда вызывается:
  - `setEmail(...)` при создании
  - `updateCode(...)` из OTP input: `otp_page.dart:114`
  - `verify()` по кнопке: `otp_page.dart:143`
  - `resend()` по кнопке resend: `otp_page.dart:123`
- Запросы к серверу:
  - `auth.verifyOTP(type: signup)`
  - `GET api/me` (bootstrap profile после успешного verify)
  - `auth.signInWithOtp(email)` (resend)

## 8) `BaseCurrencyCubit`
- Где живет: `client/lib/presentation/onboarding/bloc/base_currency_cubit.dart`
- Где создается: `client/lib/presentation/onboarding/page/base_currency_page.dart:28`
- Где удаляется: при выходе со страницы onboarding base currency
- Когда вызывается:
  - `load()` автоматически в конструкторе
  - `load()` по retry/paywall-return: `base_currency_page.dart:49`, `:68`, `:109`
  - `selectCurrency(...)` из picker: `base_currency_page.dart:125`
  - `continueNext()` по кнопке Continue: `base_currency_page.dart:134`
  - `useUsdForNow()` по кнопке Use USD: `base_currency_page.dart:143`
- Запросы к серверу:
  - `GET api/me`
  - `GET api/assets/list?kind=fiat&limit=100`
  - при сохранении:
    - `GET api/assets/list?kind=fiat&limit=100` (резолв кода в `assetId`, если передан код)
    - `POST api/profile/update`
    - `GET api/me`

## 9) `OverviewCubit`
- Где живет: `client/lib/presentation/overview/bloc/overview_cubit.dart`
- Где создается: `client/lib/presentation/home/page/main_shell_page.dart:22`
- Где удаляется: при dispose `MainShellPage` (выход из main shell)
- Когда вызывается:
  - `load()` при создании
  - `refresh()`:
    - pull-to-refresh: `overview_page.dart:66`
    - после возврата из base currency settings: `overview_page.dart:56`
    - retry в ошибках: `overview_body.dart:76`
    - после изменений из account/subaccount flow (разные страницы)
- Запросы к серверу:
  - `GET api/me`
  - блок курсов: `GET api/assets/list` (fiat+crypto), `GET api/rates/usd`
  - `GET api/accounts/list`
  - `GET api/assets/list` (fiat+crypto)
  - для каждого активного аккаунта: `GET api/subaccounts/list?accountId=...`
  - для каждого subaccount при расчете текущих балансов: `GET api/subaccounts/history?limit=1`

## 10) `AnalyticsCubit`
- Где живет: `client/lib/presentation/analytics/bloc/analytics_cubit.dart`
- Где создается: `client/lib/presentation/home/page/main_shell_page.dart:23`
- Где удаляется: при dispose `MainShellPage`
- Когда вызывается:
  - `load()` при создании
  - `refresh()` вручную (pull-to-refresh) и автоматически при изменении `OverviewCubit`: `main_shell_page.dart:39`
  - `load()` по retry в ошибке: `analytics_page.dart:82`
- Запросы к серверу:
  - `GET api/me`
  - блок курсов: `GET api/assets/list` (fiat+crypto), `GET api/rates/usd`
  - `GET api/accounts/list`
  - `GET api/assets/list` (fiat+crypto)
  - для каждого активного аккаунта: `GET api/subaccounts/list?accountId=...`
  - для текущих балансов: `GET api/subaccounts/history?limit=1` по каждому subaccount
  - для ленты обновлений: `GET api/subaccounts/history?limit=20` по каждому subaccount

## 11) `AccountFormCubit`
- Где живет: `client/lib/presentation/account/bloc/account_form_cubit.dart`
- Где создается: `client/lib/presentation/account/page/account_form_page.dart:52`
- Где удаляется: при выходе со страницы account form
- Когда вызывается:
  - `load(accountId?)` при создании и по retry/paywall-return
  - `updateName(...)` из поля имени
  - `selectType(...)` по выбору типа
  - `save()` по кнопке Save
- Запросы к серверу:
  - `GET api/me`
  - `GET api/accounts/list`
  - `POST api/accounts/create` (режим create)
  - `POST api/accounts/update` (режим edit)

## 12) `AccountDetailCubit`
- Где живет: `client/lib/presentation/account/bloc/account_detail_cubit.dart`
- Где создается: `client/lib/presentation/account/page/account_detail_page.dart:39`
- Где удаляется: при выходе со страницы account detail
- Когда вызывается:
  - `load(accountId)` при создании и по retry
  - `refresh()` pull-to-refresh и после возврата из edit/add/open subaccount
  - `setArchived(...)` по action Archive/Unarchive
  - `deleteAccount(...)` по action Delete
  - `removeAsset(...)` метод есть, но прямых вызовов из UI в текущем коде не найдено
- Запросы к серверу:
  - `GET api/me`
  - блок курсов: `GET api/assets/list` (fiat+crypto), `GET api/rates/usd`
  - `GET api/accounts/list`
  - `GET api/assets/list` (fiat+crypto)
  - `GET api/subaccounts/list?accountId=...`
  - для текущих балансов: `GET api/subaccounts/history?limit=1` по subaccount
  - `POST api/accounts/update` (архивация/разархивация)
  - `POST api/accounts/delete` (удаление аккаунта)
  - `POST api/subaccounts/delete` (удаление позиции через `removeAsset`, если будет вызван)

## 13) `AddAssetCubit`
- Где живет: `client/lib/presentation/account/bloc/add_asset_cubit.dart`
- Где создается: `client/lib/presentation/account/page/add_asset_page.dart:58`
- Где удаляется: при выходе со страницы add asset
- Когда вызывается:
  - `load(accountId)` при создании и по retry/paywall-return
  - `selectKind(...)` по radio fiat/crypto
  - `selectAsset(...)` из picker
  - `updateName(...)`, `updateBalance(...)` из полей
  - `addSelected()` по кнопке создания позиции
- Запросы к серверу:
  - `GET api/me`
  - `GET api/accounts/list` (count positions)
  - `GET api/assets/list?kind=fiat|crypto&limit=100` (каталог для picker)
  - при `addSelected()`:
    - `GET api/assets/list?kind=fiat&limit=100` и при необходимости `...kind=crypto...` (резолв decimals)
    - `POST api/subaccounts/create`

## 14) `AssetPositionDetailCubit`
- Где живет: `client/lib/presentation/balance/bloc/asset_position_detail_cubit.dart`
- Где создается: в роутере `client/lib/core/routing/app_router.dart:126-128`
- Где удаляется: при выходе со страницы subaccount detail
- Когда вызывается:
  - `load(subaccountId)` при создании и по retry
  - `refresh()` после update balance/rename
  - `loadMore()` по пагинации истории
  - `rename(name)` из диалога rename
  - `deleteSubaccount()` из action delete
- Запросы к серверу:
  - `GET api/me`
  - блок курсов: `GET api/assets/list` (fiat+crypto), `GET api/rates/usd`
  - `GET api/accounts/list`
  - поиск subaccount: для каждого account `GET api/subaccounts/list?accountId=...`
  - `GET api/assets/list` (fiat+crypto)
  - `GET api/subaccounts/history?limit=50` (первая страница/refresh)
  - `GET api/subaccounts/history?limit=50&cursor=...` (loadMore)
  - `POST api/subaccounts/update` (rename)
  - `POST api/subaccounts/delete` (delete)

## 15) `AddBalanceCubit`
- Где живет: `client/lib/presentation/balance/bloc/add_balance_cubit.dart`
- Где создается: `client/lib/presentation/balance/page/add_balance_page.dart:49-50`
- Где удаляется: при выходе со страницы add balance
- Когда вызывается:
  - `load(...)` при создании и по retry
  - `selectDate(...)`, `updateAmount(...)` из полей
  - `save()` по кнопке Save
- Запросы к серверу:
  - при `save()`:
    - `GET api/subaccounts/history?subaccountId=...&limit=1` (определение decimals)
    - `POST api/subaccounts/set_balance`

## 16) `PaywallCubit`
- Где живет: `client/lib/presentation/paywall/bloc/paywall_cubit.dart`
- Где создается: `client/lib/presentation/paywall/page/paywall_page.dart:23`
- Где удаляется: при закрытии paywall страницы
- Когда вызывается:
  - `load(reason)` при создании и по retry
  - `syncPlanAfterPurchase()` после `onPurchaseCompleted` и `onRestoreCompleted`
- Запросы к серверу:
  - `Purchases.getCustomerInfo()` (RevenueCat SDK) для `getIsPro`
  - `GET api/me` (get/bootstrap profile)
  - при синке плана:
    - `POST api/revenuecat/refresh`
    - `GET api/me`

## 17) `SettingsCubit`
- Где живет: `client/lib/presentation/settings/bloc/settings_cubit.dart`
- Где создается: `client/lib/presentation/settings/page/settings_page.dart:28`
- Где удаляется: при выходе со Settings page
- Когда вызывается:
  - `load()` при создании и по retry
  - `signOut()` по кнопке Sign Out
- Запросы к серверу:
  - `GET api/me`
  - `auth.signOut()`

## 18) `BaseCurrencySettingsCubit`
- Где живет: `client/lib/presentation/settings/bloc/base_currency_settings_cubit.dart`
- Где создается: `client/lib/presentation/settings/page/base_currency_settings_page.dart:28`
- Где удаляется: при выходе со страницы настроек базовой валюты
- Когда вызывается:
  - `load()` при создании и по retry/paywall-return
  - `selectCurrency(...)` из picker
  - `save()` по кнопке Save
- Запросы к серверу:
  - `GET api/me` (bootstrap profile)
  - `GET api/assets/list?kind=fiat&limit=100`
  - при `save()`:
    - `GET api/assets/list?kind=fiat&limit=100` (резолв кода)
    - `POST api/profile/update`
    - `GET api/me`

## 19) `ManageSubscriptionCubit`
- Где живет: `client/lib/presentation/settings/bloc/manage_subscription_cubit.dart`
- Где создается: `client/lib/presentation/settings/page/manage_subscription_page.dart:24`
- Где удаляется: при выходе со страницы Manage Subscription
- Когда вызывается:
  - `load()` при создании, по retry и после закрытия paywall в `ManageSubscriptionPage`
  - `restore()` по кнопке Restore
  - `onCustomerCenterClosed()` после закрытия customer center
- Запросы к серверу:
  - `Purchases.getCustomerInfo()`
  - `Purchases.restorePurchases()`
  - если после restore получен Pro:
    - `POST api/revenuecat/refresh`
    - `GET api/me`

## 20) `ProfileCubit`
- Где живет: `client/lib/presentation/profile/bloc/profile_cubit.dart`
- Где создается:
  - `client/lib/presentation/profile/page/profile_page.dart:29`
  - `client/lib/presentation/profile/page/account_actions_page.dart:24`
- Где удаляется: при выходе с соответствующей страницы (это два независимых инстанса)
- Когда вызывается:
  - `load()` при создании и по retry
  - `refresh()` pull-to-refresh
  - `setPlan(...)` и `setBaseCurrency(...)` после возврата из дочерних экранов
  - `signOut()` по кнопке
  - `confirmDelete(...)` -> `deleteAccount()` через диалог
- Запросы к серверу:
  - `GET api/me`
  - `auth.signOut()`
  - `POST api/delete_my_account` + затем `auth.signOut()`

## 21) `ArchivedAccountsCubit`
- Где живет: `client/lib/presentation/profile/bloc/archived_accounts_cubit.dart`
- Где создается: `client/lib/presentation/profile/page/archived_accounts_page.dart:26`
- Где удаляется: при выходе с Archived Accounts page
- Когда вызывается:
  - `load()` при создании и по retry
- Запросы к серверу:
  - `GET api/accounts/list`

---

## Важные наблюдения
- Самые тяжелые по количеству запросов: `OverviewCubit`, `AnalyticsCubit`, `AssetPositionDetailCubit` (из-за циклов по аккаунтам/позициям и множественных запросов истории).
- `AccountDetailCubit.removeAsset(...)` реализован, но в текущем UI не вызывается напрямую.
- `ProfileCubit` создается в двух разных экранах отдельно (`ProfilePage` и `AccountActionsPage`), состояние между ними не общее.
