# BUG-PRO-001: Убрать отдельный Account Actions экран, перенести Sign out/Delete в Profile

## Метаданные
- ID: `BUG-PRO-001`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Done`
- Связанные FR/FTR/SCR: `SCR-009`

## Экран/модуль/слой
- Экран: Profile
- Слой: `presentation`

## Проблема
### Текущее поведение
Действия sign out/delete вынесены в отдельный экран `profile/account`, что увеличивает глубину навигации и усложняет UX.

### Ожидаемое поведение
На Profile внизу сразу видны ghost-кнопки `Sign out` и `Delete account` с кратким описанием.

## Root-cause hypothesis
Текущая структура роутинга хранит `AccountActionsPage` как отдельный nested route.

## Предлагаемое решение
1. Удалить entry row в Profile к account-actions.
2. Добавить две ghost-кнопки в низ `ProfilePage`.
3. Сохранить confirm-dialog для delete.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given profile page, when пользователь скроллит вниз, then видит sign out и delete действия.
2. Given delete action, when пользователь подтверждает, then работает текущий delete flow.
3. Given sign out, when нажато действие, then пользователь выходит в sign-in.

## Тест-сценарии
### Manual
1. Проверить новые действия на Profile.

### Auto
1. Widget tests наличия кнопок и callbacks.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не потерять подтверждение удаления аккаунта.

## Ссылки на текущую реализацию
- [profile_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/profile/page/profile_page.dart)
- [app_router.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/routing/app_router.dart)

## Implementation note
- В [profile_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/profile/page/profile_page.dart) удалён entry row в отдельный account-actions экран и добавлены действия `Sign out` / `Delete account` внизу Profile c кратким описанием и ghost-стилем (`DSButtonVariant.secondary`).
- Сохранён confirm-dialog удаления аккаунта на Profile через `DSDialog`; после подтверждения вызывается текущий `SessionCubit.deleteAccount()`.
- Для sign out/delete добавлен listener на `SessionCubit`: при `unauthenticated` выполняется `context.go(AppRoutes.signIn)`, ошибки операций показываются через `DSSnackBar`.
- Удалён отдельный экран [account_actions_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/profile/page/account_actions_page.dart) и убран соответствующий route из [app_router.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/routing/app_router.dart) и [app_routes.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/routing/app_routes.dart).
- Добавлен widget-тест [profile_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/profile/page/profile_page_test.dart), покрывающий:
  - наличие действий внизу Profile,
  - sign out с переходом на sign-in,
  - delete flow с confirm-dialog.
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/profile/page/profile_page_test.dart` (pass)
