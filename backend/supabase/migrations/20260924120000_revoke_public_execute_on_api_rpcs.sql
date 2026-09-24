-- QA-001 / SPEC-0006: functions re-created by 20260221120000-120003 lost their revoke/grant.
revoke all on function public.api_create_account(uuid, text, text)
  from public, anon, authenticated;
revoke all on function public.api_update_account(uuid, uuid, text, text, boolean)
  from public, anon, authenticated;
revoke all on function public.api_create_subaccount(uuid, uuid, uuid, text, text, smallint)
  from public, anon, authenticated;
revoke all on function public.api_update_subaccount(uuid, uuid, text, boolean)
  from public, anon, authenticated;
revoke all on function public.handle_auth_user_created() from public, anon, authenticated;
revoke all on function public.handle_balance_entry_insert() from public, anon, authenticated;

grant execute on function public.api_create_account(uuid, text, text) to service_role;
grant execute on function public.api_update_account(uuid, uuid, text, text, boolean) to service_role;
grant execute on function public.api_create_subaccount(uuid, uuid, uuid, text, text, smallint)
  to service_role;
grant execute on function public.api_update_subaccount(uuid, uuid, text, boolean) to service_role;
grant execute on function public.handle_auth_user_created() to service_role;
grant execute on function public.handle_balance_entry_insert() to service_role;

-- New functions must not be executable by clients unless explicitly granted.
-- The global PUBLIC default cannot be revoked with IN SCHEMA, hence two statements.
alter default privileges for role postgres revoke execute on functions from public;
alter default privileges for role postgres in schema public
  revoke execute on functions from anon, authenticated;
