# BUG-PRO-001: Убрать отдельный Account Actions экран, перенести Sign out/Delete в Profile

## Метаданные
- ID: `BUG-PRO-001`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Draft`
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
- [account_actions_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/profile/page/account_actions_page.dart)
