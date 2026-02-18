create unique index if not exists uq_profiles_revenuecat_app_user_id
  on public.profiles(revenuecat_app_user_id)
  where revenuecat_app_user_id is not null;
