# BUG-AUTH-001: Упростить анимацию onboarding carousel (убрать лаги)

## Метаданные
- ID: `BUG-AUTH-001`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `SCR-003`, `SCR-001`, `FTR-001`

## Экран/модуль/слой
- Экран: onboarding carousel (`/onboarding/carousel`)
- Модуль: `presentation/onboarding`
- Слой: `presentation`

## Проблема
### Текущее поведение
На первом запуске экраны онбординга используют тяжелый carousel-эффект (комбинация `PageView` + `AnimatedSwitcher` + `AnimatedScale` + `AnimatedSlide` + opacity), что на части устройств дает заметные подлагивания.

### Ожидаемое поведение
Переходы между слайдами визуально плавные, но без “карусельного” эффекта и без просадок FPS.

## Root-cause hypothesis
В [onboarding_carousel_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/onboarding/page/onboarding_carousel_page.dart) одновременно отрабатывают несколько анимационных слоев и сложные hero-блоки, создавая лишнюю нагрузку на кадр.

## Предлагаемое решение
1. Упростить анимационный стек до одного легкого transition (fade/slide, без switcher-комбинации).
2. Оставить `PageView`, но убрать конкурирующие анимации из `_OnboardingHero`.
3. Проверить производительность на low/mid devices и закрепить критерий плавности в QA.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given пользователь листает onboarding, when меняется экран, then переход происходит без лагов и без carousel-эффекта.
2. Given слабое устройство, when пользователь быстро свайпает 3 слайда, then UI не теряет интерактивность.
3. Given завершение onboarding, when пользователь нажимает CTA, then навигация в `home` остается прежней.

## Тест-сценарии
### Manual
1. Первый запуск -> пройти все слайды с обычной и быстрой прокруткой.
2. Проверить iOS/Android с включенным performance overlay.

### Auto
1. Widget test для базовой навигации между страницами onboarding.
2. Golden/snapshot на ключевые состояния слайдов.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не сломать логику `OnboardingCarouselStorage` (`completed` флаг).

## Ссылки на текущую реализацию
- [onboarding_carousel_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/onboarding/page/onboarding_carousel_page.dart)
- [home_gate_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/widget/home_gate_page.dart)
