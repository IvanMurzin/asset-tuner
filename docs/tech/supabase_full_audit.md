# Supabase Full Audit (asset_tuner)

Дата аудита: 2026-02-17  
Проект: `backend/supabase` + `client/lib/**/supabase*`

## 1. Что входит в Supabase-слой проекта

### 1.1. База данных (Postgres + миграции)
Источник истины: `backend/supabase/migrations/*.sql`.

Сущности:
- Пользовательские таблицы: `profiles`, `accounts`, `subaccounts`, `balance_entries`.
- Публичный каталог/курсы: `assets`, `asset_rates_usd`.
- Внутренний provider-layer: `fx_rates_usd`, `crypto_rates_usd`, `cg_coins_cache`, `cg_top_coins`.
- Плановые лимиты/ранжирование: `plan_limits`, `fiat_priority`, `asset_rankings` (view).
- Storage: bucket `asset_icons` + policy на `storage.objects`.

### 1.2. Edge Functions
Фактически реализованы (`index.ts` присутствует):
- `bootstrap_profile`
- `create_account`
- `account` (DELETE)
- `create_subaccount`
- `rename_subaccount`
- `subaccount` (DELETE)
- `update_subaccount_balance`
- `update_base_currency`
- `update_plan`
- `get_assets_for_picker`
- `rates_sync`
- `coingecko_refresh_metadata`

Каталоги есть, но кода нет (пусто):
- `add_asset_to_account`
- `remove_asset_from_account`
- `update_balance`

### 1.3. Flutter-клиент (как интегрирован)
- Инициализация: `client/lib/core/supabase/supabase_initializer.dart`.
- DI-клиент: `client/lib/core/di/supabase_module.dart`.
- Вызовы Edge Functions: `client/lib/core/supabase/supabase_edge_functions.dart`.
- Таблицы/имена функций: `client/lib/core/supabase/supabase_constants.dart`.
- Data sources: `client/lib/data/**/data_source/supabase_*_data_source.dart`.

## 2. Финальное состояние схемы БД (по цепочке миграций)

## 2.1. Таблицы и их назначение

### `profiles`
Назначение: профиль пользователя, план, entitlements, базовая валюта.

Ключевые поля:
- `user_id uuid PK` -> `auth.users(id)`
- `base_currency text`
- `plan text` (`free|paid`)
- `entitlements jsonb`
- `created_at`, `updated_at`

Триггер:
- `trg_profiles_set_updated_at` -> `public.set_updated_at()`

### `accounts`
Назначение: верхнеуровневые аккаунты (bank/wallet/exchange/cash/other).

Ключевые поля:
- `id uuid PK`
- `user_id uuid` -> `profiles(user_id)`
- `name text`
- `type text` (check enum)
- `archived bool`
- `created_at`, `updated_at`

Индексы:
- `idx_accounts_user_updated_at(user_id, updated_at desc)`

Триггер:
- `trg_accounts_set_updated_at`

### `assets`
Назначение: каталог fiat/crypto.

Ключевые поля:
- `id uuid PK`
- `kind text` (`fiat|crypto`)
- `code text` (uppercase)
- `name text`
- `decimals int`
- `provider_ref text`

Ограничения/индексы:
- unique `(kind, code)`
- index `idx_assets_provider_ref`
- partial unique `uq_assets_provider_ref_crypto` для `kind='crypto'`
- check `chk_assets_crypto_provider_ref_required` (NOT VALID): для crypto `provider_ref` должен быть не null (старые данные могли не провалидироваться ретроспективно)

### `subaccounts`
Назначение: позиции внутри `accounts` (привязка к `asset_id` + пользовательское имя).

Ключевые поля:
- `id uuid PK`
- `user_id uuid` -> `profiles(user_id)`
- `account_id uuid` -> `accounts(id)`
- `asset_id uuid` -> `assets(id)`
- `name`, `archived`, `sort_order`, `created_at`, `updated_at`

Индексы:
- `idx_subaccounts_account_id`
- `idx_subaccounts_user_id`

Триггер:
- `trg_subaccounts_set_updated_at`

### `balance_entries`
Назначение: снимки баланса и diff по subaccount.

Ключевые поля:
- `id uuid PK`
- `user_id uuid`
- `subaccount_id uuid` -> `subaccounts(id)`
- `entry_date date`
- `snapshot_amount text` (decimal string)
- `diff_amount text|null` (decimal string)
- `created_at`

Индексы:
- `idx_balance_entries_subaccount_desc(subaccount_id, entry_date desc, created_at desc)`
- `idx_balance_entries_subaccount_asc(subaccount_id, entry_date asc, created_at asc)`

### `asset_rates_usd`
Назначение: финальная проекция курсов USD по `asset_id`.

Ключевые поля:
- `asset_id uuid PK` -> `assets(id)`
- `usd_price text` (positive decimal string)
- `as_of timestamptz`

Индекс:
- `idx_asset_rates_usd_as_of(as_of desc)`

### `fx_rates_usd`
Назначение: provider-кэш FX (OpenExchangeRates).

Поля:
- `code text PK`
- `usd_price text` (после migration hardening)
- `as_of`
- `source` (default `openexchangerates`)

### `cg_coins_cache`
Назначение: кэш `/coins/list` от CoinGecko.

Поля:
- `coingecko_id text PK`
- `symbol`, `symbol_upper`, `name`, `updated_at`

Индекс:
- `idx_cg_coins_cache_symbol_upper`

### `cg_top_coins`
Назначение: топ монет CoinGecko (`rank`, `market_cap`).

Поля:
- `coingecko_id text PK`
- `symbol_upper`, `name`, `rank`, `market_cap text|null`, `updated_at`

Индекс:
- `idx_cg_top_coins_rank`

### `crypto_rates_usd`
Назначение: provider-кэш crypto цен (CoinGecko).

Поля:
- `coingecko_id text PK`
- `usd_price text` (после migration hardening)
- `as_of`
- `source` (default `coingecko`)

Индекс:
- `idx_crypto_rates_usd_as_of`

### `plan_limits`
Назначение: лимиты видимости каталога по планам.

Поля:
- `plan text PK` (`free|paid`)
- `fiat_limit int`
- `crypto_limit int`
- `allow_all bool`

Фактическое текущее seed-значение в миграциях:
- `free`: `fiat_limit=5`, `crypto_limit=5`, `allow_all=false`
- `paid`: `fiat_limit=100`, `crypto_limit=100`, `allow_all=false`

### `fiat_priority`
Назначение: приоритеты fiat-кодов для ранжирования.

Поля:
- `code text PK`
- `rank int`

### `asset_rankings` (VIEW)
Назначение: единый ранк для RLS и pickers.

Фактическая логика (последняя версия):
- Fiat:
  - сначала ранги из `fiat_priority`,
  - затем fallback: остальные fiat по алфавиту после `max(fiat_priority.rank)`.
- Crypto:
  - приоритет `cg_top_coins.rank`,
  - fallback на hardcoded top-токены (`BTC`, `ETH`, `USDT`, `BNB`, `SOL`, `XRP`, `USDC`, `ADA`, `DOGE`, `TRX`),
  - иначе `999999`.

## 2.2. SQL-функции (в базе)

Активные:
- `set_updated_at()` (trigger function)
- `current_request_plan()`
- `current_plan_allow_all()`
- `current_plan_limit(p_kind text)`
- `asset_visible_for_current_user(p_kind, p_code, p_provider_ref)`
- `asset_visible_by_id_for_current_user(p_asset_id uuid)`
- `asset_selectable_by_current_user(p_asset_id uuid)`

Удаленные миграциями:
- `list_fiat_currencies_for_picker()`
- `list_assets_for_subaccount_picker(text)`
- `list_assets_for_picker(text)`

RPC-слой как отдельный продуктовый API сейчас не используется клиентом (в коде Flutter нет `client.rpc(...)`).

## 2.3. Seed
Файл: `backend/supabase/seed.sql`

- Добавляет базовый минимальный каталог (USD, EUR, RUB, GBP, CHF, BTC, ETH, USDT, SOL).
- Добавляет плейсхолдеры в `asset_rates_usd` до первого `rates_sync`.

Отдельная миграция дополняет fiat из `fiat_priority`:
- `20260214230000_seed_fiat_from_priority.sql`

## 3. RLS (подробно)

## 3.1. Где RLS включен
RLS включен на:
- `profiles`, `accounts`, `assets`, `subaccounts`, `balance_entries`, `asset_rates_usd`
- `fx_rates_usd`, `cg_coins_cache`, `cg_top_coins`, `crypto_rates_usd`
- `plan_limits`, `fiat_priority`

## 3.2. Политики и фактический доступ

### `profiles`
- Policy: `profiles_select_own` (`select`, `to authenticated`, `user_id = auth.uid()`).
- Гранты: `select` для `authenticated`.
- Нет policy на `update/insert/delete` для `authenticated`.
- Следствие: клиент читает свой профиль напрямую, а изменение профиля делается через Edge Functions (service role).

### `accounts`
- Policies:
  - `accounts_select_own` (`select own`)
  - `accounts_update_own` (`update own`, `with check own`)
- Гранты: `select, update` для `authenticated`.
- Нет policy/grant на insert/delete для `authenticated`.
- Следствие:
  - direct update из клиента работает,
  - create/delete идут через Edge Functions.

### `subaccounts`
- Policy: `subaccounts_select_own` (только select own).
- Грант: `select` для `authenticated`.
- Нет insert/update/delete для `authenticated`.
- Следствие: create/rename/delete только через Edge Functions.

### `balance_entries`
- Policy: `balance_entries_select_own`.
- Грант: `select` для `authenticated`.
- Нет insert/update/delete для `authenticated`.
- Следствие: запись snapshot делается через Edge Function `update_subaccount_balance`.

### `assets`
Финальная policy после последней миграции:
- `assets_select_public` (`to anon, authenticated`)
- `using (public.asset_selectable_by_current_user(id))`

`asset_selectable_by_current_user(id)`:
- true, если актив видим по плану (`asset_visible_by_id_for_current_user`),
- или если у пользователя уже есть subaccount с этим asset (`exists subaccounts where user_id=auth.uid() and asset_id=...`).

Важно:
- anon и user без profile трактуются как `free` (через `current_request_plan()`).
- Благодаря second branch (owned-subaccount) пользователь продолжает видеть актив, который уже использует, даже если текущий плановый лимит его скрывал бы.

### `asset_rates_usd`
Финальная policy:
- `asset_rates_usd_select_public` (`to anon, authenticated`)
- `using (public.asset_selectable_by_current_user(asset_id))`

Следствие:
- видимость курсов строго синхронизирована с видимостью активов.

### Внутренние таблицы provider/limits
- Для `fx_rates_usd`, `cg_coins_cache`, `cg_top_coins`, `crypto_rates_usd`, `plan_limits`, `fiat_priority`:
  - RLS enabled,
  - `revoke all from anon, authenticated`,
  - нет публичных policy.
- Следствие: клиент их не читает напрямую.

### Storage
- Bucket: `asset_icons` создан как public.
- Policy на `storage.objects`:
  - select для `anon, authenticated` только при `bucket_id = 'asset_icons'`.

## 3.3. Роли и права (упрощенная матрица)

### `anon`
- Может читать `assets`, `asset_rates_usd` только в рамках plan-aware RLS (как `free`).
- Может читать `asset_icons` объекты.
- Не может читать user-owned таблицы.

### `authenticated`
- Чтение своих: `profiles`, `accounts`, `subaccounts`, `balance_entries`.
- Обновление своих: только `accounts` (name/type/archived).
- Чтение `assets`/`asset_rates_usd` по RLS-правилам выбора.
- Вставка/удаление user-owned сущностей напрямую запрещена.

### `service_role`
- Выдан `all` на основные и provider-таблицы.
- Используется Edge Functions для write/workflow и обхода ограничений client-role.

## 4. Edge Functions: что делает каждая

### `bootstrap_profile`
- Auth: требует Bearer JWT (внутри `requireAuthUser`).
- Поведение:
  - ищет `profiles.user_id`;
  - если нет, создает профиль (`USD`, `plan=free`, entitlements от плана);
  - если есть, при рассинхроне пересчитывает `entitlements`.

### `create_account`
- Проверяет вход (`name`, `type`) и лимит `max_accounts` из entitlements.
- При необходимости автосоздает профиль.
- Создает строку в `accounts`.

### `account` (DELETE)
- Удаляет `accounts` по `user_id + account_id`.
- Каскад удаления subaccounts/balance_entries обеспечен FK.

### `create_subaccount`
- Валидирует `account_id`, `asset_id`, `name`, `snapshot_amount`, `entry_date`.
- Проверяет лимит `max_subaccounts`.
- Проверяет доступность asset по плану (через `asset_rankings + plan_limits`).
- Создает `subaccounts` + первый `balance_entries` snapshot.
- При ошибке второй вставки откатывает subaccount вручную.

### `rename_subaccount`
- Обновляет имя subaccount (`user_id + id`).

### `subaccount` (DELETE)
- Удаляет subaccount (`user_id + id`), history удаляется каскадом.

### `update_subaccount_balance`
- Проверяет `subaccount_id`, `entry_date` (не future), `snapshot_amount`.
- Находит предыдущий snapshot и считает `diff_amount` через `big.js`.
- Добавляет новый `balance_entries`.

### `update_base_currency`
- Проверяет код валюты.
- Проверяет rank fiat в `asset_rankings`.
- Для free-подобного entitlements применяет `plan_limits.fiat_limit`.
- Обновляет `profiles.base_currency`.

### `update_plan`
- Включается флагом `UPDATE_PLAN_ENABLED`.
- Опционально ограничивается `UPDATE_PLAN_ALLOWLIST_EMAILS`.
- Обновляет `profiles.plan` и `profiles.entitlements`.

### `get_assets_for_picker`
- Принимает `kind` (`fiat|crypto`).
- Определяет текущий план пользователя.
- Загружает `assets` + `asset_rankings`, считает `is_unlocked` по `plan_limits`.
- Возвращает весь список выбранного `kind`, включая locked элементы.

### `rates_sync` (server-job)
- Секрет: `RATES_SYNC_SECRET` (header `x-rates-sync-secret` или body `secret`).
- Обновляет:
  - `fx_rates_usd` из OpenExchangeRates,
  - `crypto_rates_usd` из CoinGecko,
  - `asset_rates_usd` как проекцию по `assets`.
- Поддерживает auto-retry на CoinGecko Pro домен по hint в ошибке.

### `coingecko_refresh_metadata` (server-job)
- Тоже защищен `RATES_SYNC_SECRET`.
- Обновляет:
  - `cg_coins_cache` (`/coins/list`),
  - `cg_top_coins` (`/coins/markets`),
  - автодобавляет/обновляет `assets` (fiat + crypto provider_ref mapping).

## 5. Клиентские вызовы: что куда ходит

## 5.1. Прямые PostgREST reads/writes

- `SupabaseAccountDataSource.fetchAccounts` -> `accounts select order updated_at desc`
- `SupabaseAccountDataSource.updateAccount` -> `accounts update`
- `SupabaseAccountDataSource.setArchived` -> `accounts update`

- `SupabaseAccountAssetDataSource.fetchAccountAssets` -> `subaccounts select where account_id,archived=false`
- `SupabaseAccountAssetDataSource.countAssetPositions` -> `subaccounts count`

- `SupabaseAssetDataSource.fetchAssets` -> `assets select`

- `SupabaseBalanceDataSource.fetchHistory` -> `balance_entries select (paged)`
- `SupabaseBalanceDataSource.fetchEntriesForPositions` -> `balance_entries select by inFilter`

- `SupabaseProfileDataSource.fetchProfile` -> `profiles maybeSingle`

- `SupabaseRateDataSource.fetchLatestUsdRates` -> `asset_rates_usd select`

## 5.2. Edge Function вызовы из клиента

- `bootstrap_profile`
- `create_account`
- `account` (DELETE)
- `create_subaccount`
- `rename_subaccount`
- `subaccount` (DELETE)
- `update_subaccount_balance`
- `update_base_currency`
- `update_plan`
- `get_assets_for_picker`

## 5.3. Auth API
`SupabaseAuthDataSource` использует Supabase Auth SDK:
- OTP sign-in,
- password sign-in/sign-up,
- OAuth (Google/Apple),
- verify OTP,
- signOut,
- restore current session.

## 6. RPC и SQL-функции в контексте клиента

- Прямых `rpc(...)` вызовов в Flutter-коде нет.
- Ранее существовавшие RPC-функции для picker удалены миграциями.
- Сейчас picker-каталог отдается Edge Function `get_assets_for_picker`.
- SQL-функции RLS (`current_*`, `asset_visible_*`, `asset_selectable_*`) используются внутри политик, а не как продуктовый публичный RPC API.

## 7. Operational/infra конфигурация

## 7.1. `backend/supabase/config.toml`
- `project_id = "asset_tuner"`
- API schemas: `public`, `storage`, `graphql_public`
- `max_rows = 1000`
- DB `major_version = 17`

## 7.2. Secrets/ENV (по `.env.example`)
Ключевые секреты:
- `OPENEXCHANGE_APP_ID`
- `COINGECKO_API_KEY` (и legacy alias `COINGEKO_API_KEY`)
- `RATES_SYNC_SECRET`
- `RATES_SYNC_MAX_CRYPTO`, `RATES_SYNC_MAX_FIAT`
- `UPDATE_PLAN_ENABLED`, `UPDATE_PLAN_ALLOWLIST_EMAILS`

## 7.3. Скрипты
- `supabase_link.sh`, `supabase_push_db.sh`, `supabase_set_secrets.sh`
- `supabase_deploy_functions.sh`
- `supabase_start_local.sh`, `supabase_reset_local.sh`, `supabase_reset_remote.sh`
- `supabase_seed_remote.sh`

## 8. Обнаруженные рассинхроны и риски

1. `config.toml` и реальный код функций рассинхронизированы.
- В `config.toml` перечислены `add_asset_to_account`, `remove_asset_from_account`, `update_balance`, но соответствующие директории пустые.
- В `config.toml` отсутствуют реально используемые функции: `create_subaccount`, `rename_subaccount`, `subaccount`, `update_subaccount_balance`, `get_assets_for_picker`.

2. Скрипт деплоя принудительно ставит `--no-verify-jwt` для всех функций.
- Это расходится с `config.toml`, где часть функций отмечена как `verify_jwt = true`.
- Сейчас безопасность держится на ручной проверке `requireAuthUser` внутри функций.
- Для строгой модели стоит унифицировать стратегию (либо опираться на verify_jwt, либо явно фиксировать что auth только в коде).

3. Контрактные docs описывают `assets`/`asset_rates_usd` как “plan-aware”, но в текущем коде это уже “plan-aware OR owned-subaccount”.
- Это важно для аналитики/объяснения пользователю, почему он видит часть активов сверх лимита.

4. `plan_limits` эволюционировал до `free=5/5`, хотя в ранних миграциях и части документации фигурируют `10/10`.
- Фактический источник истины на текущий момент: последняя применимая миграция (`20260214210000`).

## 9. Итоговая картина “как это работает целиком”

- Клиент читает данные напрямую из PostgREST там, где RLS безопасно разрешает только нужные строки.
- Все ключевые write-операции и бизнес-валидации вынесены в Edge Functions (через service role).
- Видимость каталога и курсов регулируется RLS-функциями + `plan_limits` + `asset_rankings`.
- Дополнительно реализована защита от “пропажи уже выбранного актива” через `asset_selectable_by_current_user`.
- Актуализация каталога и курсов обеспечивается двумя server-only job-функциями (`coingecko_refresh_metadata`, `rates_sync`) с секретом.

---

## Приложение A: миграции в порядке применения

1. `20260211170000_init.sql`
2. `20260211193000_asset_rates_usd_usd_price_text.sql`
3. `20260212173000_money_columns_text.sql`
4. `20260214110000_rates_provider_layer.sql`
5. `20260214113000_plan_limited_assets_rls.sql`
6. `20260214170000_catalog_text_top_rls_hardening.sql`
7. `20260214173000_catalog_prune_top_limits.sql`
8. `20260214174000_prune_nonstandard_crypto_symbols.sql`
9. `20260214182000_paid_100x100_ranking_rls_enforce.sql`
10. `20260214190000_fiat_picker_ranked_rpc.sql`
11. `20260214200000_subaccount_picker_catalog_rpc.sql`
12. `20260214210000_picker_assets_rpc.sql`
13. `20260214220000_drop_picker_rpc_rls_owned_assets.sql`
14. `20260214230000_seed_fiat_from_priority.sql`
