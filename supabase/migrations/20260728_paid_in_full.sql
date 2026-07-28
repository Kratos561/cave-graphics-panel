alter table public.tasks
  add column if not exists paid_in_full boolean not null default false;
