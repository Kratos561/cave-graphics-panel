create table if not exists public.debts (
  id text primary key,
  client text not null,
  amount_due numeric(12,2) not null check (amount_due > 0),
  note text,
  created_at bigint not null,
  updated_at bigint not null
);

alter table public.debts enable row level security;
revoke all on table public.debts from anon, authenticated;
