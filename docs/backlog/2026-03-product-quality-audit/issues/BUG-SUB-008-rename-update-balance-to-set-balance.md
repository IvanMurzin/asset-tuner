# BUG-SUB-008: Переименовать `Update balance` в `Set balance` + добавить пояснение экрана

## Метаданные
- ID: `BUG-SUB-008`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-006`, `SCR-011`, `SCR-010`

## Экран/модуль/слой
- Экраны: Subaccount detail, Set balance
- Слой: `presentation/l10n`

## Проблема
### Текущее поведение
CTA `Update balance` интерпретируется неоднозначно: пользователи не всегда понимают, что задается новое текущее значение.

### Ожидаемое поведение
Единая терминология `Set balance` (и локализованный эквивалент), плюс ясный description на экране ввода.

## Root-cause hypothesis
Copy не соответствует snapshot semantics из `FTR-006`.

## Предлагаемое решение
1. Переименовать CTA и title на целевых экранах.
2. Добавить helper description “вы задаете новое текущее значение баланса”.
3. Проверить все ссылки на l10n-ключи.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given пользователь открывает форму баланса, when экран рендерится, then везде используется `Set balance`.
2. Given locale=en/ru, when экран открыт, then copy остается понятным и консистентным.

## Тест-сценарии
### Manual
1. Проверка label/title/button на двух локалях.

### Auto
1. Snapshot test ключевых текстов на экранах `SCR-010/011`.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не потерять связку с route `update-balance` (техническое имя может остаться).

## Ссылки на текущую реализацию
- [add_balance_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/page/add_balance_page.dart)
- [subaccount_detail_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/page/subaccount_detail_page.dart)
