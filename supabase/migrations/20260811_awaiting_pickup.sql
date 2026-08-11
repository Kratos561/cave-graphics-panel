alter table public.tasks
  add column if not exists awaiting_pickup boolean not null default false;
