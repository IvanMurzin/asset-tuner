# Asset Tuner Supabase Backend (clean baseline)

Этот backend реализует clean-проект по модели:
- клиент не ходит в PostgREST таблицы напрямую;
- весь API через Edge Functions;
- чтения/записи из API-слоя идут через SQL RPC (security definer);
- деньги/балансы/цены хранятся как `*_atomic TEXT` + `*_decimals SMALLINT`;
- RLS включен на всех таблицах, без policy для `anon/authenticated`.

## Что включено

- `supabase/migrations/20260217200000_clean_asset_tuner_init.sql`
  - полная схема БД;
  - helper money-функции (`validate_amount_atomic`, `atomic_to_numeric`, `numeric_to_atomic`);
  - триггеры (`auth.users -> profiles`, `balance_entries -> current balance`);
  - транзакционные RPC write-операции;
  - `recompute_*` для кешей totals;
  - RLS + deny direct table access.
- `supabase/seed.sql`
  - `plan_limits` (`free`, `pro`);
  - топ-100 fiat (`fiat_rank_seed`);
  - top-100 crypto snapshot (kind=`crypto`) + первичный upsert assets/rates placeholders.
- Edge Functions:
  - `supabase/functions/api` (JWT required): `/me`, `/profile/update`, `/accounts/*`, `/subaccounts/*`, `/assets/list`, `/rates/usd`, `/delete_my_account`, `/contact_developer`, `/revenuecat/refresh`.
  - `supabase/functions/rates_sync` (no JWT): hourly sync CoinGecko + OpenExchangeRates.
  - `supabase/functions/revenuecat_webhook` (no JWT): webhook + idempotency через `webhook_events`.
- Shared слой:
  - `supabase/functions/_shared/auth.ts`
  - `supabase/functions/_shared/db.ts`
  - `supabase/functions/_shared/validation.ts`
  - `supabase/functions/_shared/money.ts`
  - `supabase/functions/_shared/responses.ts`
  - `supabase/functions/_shared/fiat_top100.ts`

## Важное про округление

`numeric_to_atomic` использует `round(..., 0)` в Postgres, то есть **half away from zero**.

## Переменные окружения

Смотри `.env` в корне репо. Если секрета не было найдено, он выставлен в `replace_me`.

Обязательные для прода:
- `SUPABASE_URL`
- `OPENEXCHANGERATES_APP_ID`
- `SCHEDULER_SECRET`
- `REVENUECAT_WEBHOOK_SECRET`

Опционально:
- `COINGECKO_API_KEY`
- `REVENUECAT_API_KEY`
- `SUPABASE_SERVICE_ROLE_KEY` (обычно автоматически доступен внутри Supabase Edge Runtime; нужен для локального запуска `functions serve`)

## Деплой через CLI (рекомендуемый скрипт)

```bash
./backend/scripts/deploy_supabase.sh
```

Скрипт делает:
1. `supabase link --project-ref ...`
2. `supabase db push`
3. remote seed через `psql` (если задан `SUPABASE_DB_URL`)
4. `supabase secrets set ...`
5. deploy функций:
   - `supabase functions deploy api`
   - `supabase functions deploy rates_sync --no-verify-jwt`
   - `supabase functions deploy revenuecat_webhook --no-verify-jwt`
6. триггерит первичный `rates_sync`, чтобы сразу обновить metadata/rates (включая crypto)

## Ручные CLI команды (если без скрипта)

```bash
# 1) (однократно) если проекта supabase/ еще нет
supabase init

# 2) линк к проекту
supabase link --project-ref <project-ref>

# 3) миграции
supabase db push

# 4) локальный полный reset
supabase db reset

# 5) секреты
supabase secrets set SUPABASE_URL=... OPENEXCHANGERATES_APP_ID=... SCHEDULER_SECRET=...

# 6) деплой функций
supabase functions deploy api
supabase functions deploy rates_sync --no-verify-jwt
supabase functions deploy revenuecat_webhook --no-verify-jwt
```

## Ручные шаги после деплоя

1. Настроить hourly cron для `rates_sync`:
   - через скрипт: `./backend/scripts/setup_rates_sync_cron.sh`
   - или вручную в Dashboard.
2. При вызове передавать header:
   - `x-scheduler-secret: <SCHEDULER_SECRET>`
3. В RevenueCat webhook URL указать:
   - `https://<project-ref>.supabase.co/functions/v1/revenuecat_webhook`
4. Для RevenueCat добавить header:
   - `Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>`
5. Убедиться, что в Auth включены нужные провайдеры (email/oauth) под клиент.

## Пример curl вызовов

JWT функции (`api`):

```bash
curl -sS \
  -H "Authorization: Bearer <USER_JWT>" \
  "https://<project-ref>.supabase.co/functions/v1/api/me"
```

```bash
curl -sS -X POST \
  -H "Authorization: Bearer <USER_JWT>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Main account","type":"wallet"}' \
  "https://<project-ref>.supabase.co/functions/v1/api/accounts/create"
```

```bash
curl -sS -X POST \
  -H "Authorization: Bearer <USER_JWT>" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"<uuid>","assetId":"<uuid>","name":"BTC spot","initialAmountAtomic":"0","initialAmountDecimals":8}' \
  "https://<project-ref>.supabase.co/functions/v1/api/subaccounts/create"
```

```bash
curl -sS -X POST \
  -H "Authorization: Bearer <USER_JWT>" \
  -H "Content-Type: application/json" \
  -d '{"subaccountId":"<uuid>","amountAtomic":"123456789","amountDecimals":8,"note":"sync"}' \
  "https://<project-ref>.supabase.co/functions/v1/api/subaccounts/set_balance"
```

```bash
curl -sS -X POST \
  -H "Authorization: Bearer <USER_JWT>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Ivan","email":"ivan@example.com","subject":"Need help","description":"Подскажите по расчету totals","meta":{"screen":"settings"}}' \
  "https://<project-ref>.supabase.co/functions/v1/api/contact_developer"
```
Эндпоинт только записывает сообщение в `support_messages` (без отправки email).

Webhook/cron функции:

```bash
curl -sS -X POST \
  -H "x-scheduler-secret: <SCHEDULER_SECRET>" \
  "https://<project-ref>.supabase.co/functions/v1/rates_sync"
```

```bash
curl -sS -X POST \
  -H "Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>" \
  -H "Content-Type: application/json" \
  -d '{"event":{"id":"evt_1","type":"RENEWAL","app_user_id":"<supabase-user-id>","entitlement_ids":["pro"]}}' \
  "https://<project-ref>.supabase.co/functions/v1/revenuecat_webhook"
```

## Мини тест-план

1. Free user: создать 6-й аккаунт -> `LIMIT_ACCOUNTS_REACHED`.
2. Free user: создать subaccount с rank 6 (fiat/crypto) -> `ASSET_NOT_ALLOWED_FOR_PLAN`.
3. Pro user: создать больше лимитов free -> проходит.
4. `rates_sync`: меняет `asset_rates_usd.as_of` и пересчитывает `accounts.cached_total_*`.
5. `delete_my_account`: удаляет `auth.users` и каскадно пользовательские данные.
6. `revenuecat_webhook`: переводит `profiles.plan` между `free/pro`.

## О выборе ranking

Top-100 fiat зафиксирован в `supabase/functions/_shared/fiat_top100.ts` и `supabase/seed.sql`.
Логика: упорядочено по практической международной ликвидности/частоте использования, для free-plan жесткий top-5.

Top-100 crypto в seed — это snapshot списка лидирующих активов (файл `/supabase/seeds/crypto_top100_snapshot.tsv`),
чтобы после `db reset` каталог содержал и fiat, и crypto.
Актуализация rank/name/provider_ref/цен происходит через `rates_sync` (CoinGecko + OpenExchangeRates).
