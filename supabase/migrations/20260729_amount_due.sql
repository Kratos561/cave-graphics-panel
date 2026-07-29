alter table public.tasks
  add column if not exists amount_due numeric(12,2) not null default 0;
