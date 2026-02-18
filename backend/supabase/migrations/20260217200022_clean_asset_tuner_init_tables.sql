create table if not exists public.fiat_rank_seed (
  code text primary key check (code = upper(code)),
  rank int not null unique check (rank between 1 and 100),
  name text not null,
  decimals smallint not null check (decimals between 0 and 18)
);
