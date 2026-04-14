# IMP-AUTH-005: Добавить one-time guided tour после onboarding

## Метаданные
- ID: `IMP-AUTH-005`
- Тип: `Improvement`
- Приоритет: `P2`
- Статус: `Done`
- Связанные FR/FTR/SCR: `SCR-004`, `SCR-006`, `SCR-003`

## Экран/модуль/слой
- Экран: Main и первые CTA
- Слой: `presentation`

## Проблема
### Текущее поведение
После завершения онбординга пользователь сразу попадает в приложение без контекстных подсказок по ключевым действиям.

### Ожидаемое поведение
Один раз при первом входе показывается легкий guided tour с подсветкой ключевых CTA (например “Добавить счет”).

## Root-cause hypothesis
Есть только carousel onboarding; in-app guidance слой отсутствует.

## Предлагаемое решение
1. Ввести флаг “guided tour completed” в local storage.
2. Реализовать 2-3 шага с tooltip/callout без перегруза.
3. Обеспечить пропуск и завершение тура.

## Изменения API/контрактов/конфига
- Нет, локальное состояние.

## Acceptance Criteria
1. Given первый запуск после onboarding, when пользователь попадает на Main, then показывается guided tour.
2. Given тур завершен, when app relaunch, then тур не показывается повторно.
3. Given пользователь пропустил тур, when app relaunch, then тур не навязывается снова.

## Тест-сценарии
### Manual
1. Первый запуск -> проверить последовательность шагов.
2. Пропуск тура -> перезапуск приложения.

### Auto
1. Unit тест хранения флага completed.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не блокировать основные действия пользователя модальными слоями.

## Ссылки на текущую реализацию
- [home_gate_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/widget/home_gate_page.dart)
- [overview_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/overview/page/overview_page.dart)

## Implementation note
- Что сделано: реализован one-time guided tour на экране Main (`Overview`) в 3 шага с подсветкой ключевых CTA-блоков (итоговая карточка, блок/кнопка добавления аккаунта), добавлены действия `Skip` и `Finish`; при `skip` и при завершении тура состояние фиксируется локально и повторно тур не показывается.
- Локальное состояние: добавлен `GuidedTourStorage` на `SharedPreferences` с флагом `guided_tour_overview_completed`.
- Локализация: добавлены RU/EN строки для прогресса и текстов 3 шагов guided tour.
- Измененные файлы: `client/lib/presentation/overview/page/overview_page.dart`, `client/lib/presentation/overview/widget/overview_guided_tour_card.dart`, `client/lib/presentation/overview/widget/tour_target_highlight.dart`, `client/lib/core/local_storage/guided_tour_storage.dart`, `client/lib/l10n/app_en.arb`, `client/lib/l10n/app_ru.arb`, `client/lib/l10n/app_localizations.dart`, `client/lib/l10n/app_localizations_en.dart`, `client/lib/l10n/app_localizations_ru.dart`, `client/test/core/local_storage/guided_tour_storage_test.dart`, `docs/backlog/2026-03-product-quality-audit/issues/IMP-AUTH-005-post-onboarding-guided-tour.md`, `docs/backlog/2026-03-product-quality-audit/INDEX.md`.
- Проверки: `cd client && flutter gen-l10n` (pass), `cd client && flutter analyze` (pass), `cd client && flutter test test/core/local_storage/guided_tour_storage_test.dart` (pass).
