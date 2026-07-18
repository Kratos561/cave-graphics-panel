begin;
alter table public.tasks
  add column if not exists client text,
  add column if not exists status text not null default 'todo',
  add column if not exists priority text not null default 'medium',
  add column if not exists tags text[] not null default '{}',
  add column if not exists total_amount numeric(12,2) not null default 0,
  add column if not exists completed_at bigint;
update public.tasks set status=coalesce(nullif(status,''),'todo'), priority=coalesce(nullif(priority,''),'medium'), tags=coalesce(tags,'{}'), total_amount=coalesce(total_amount,0), payment_amount=coalesce(payment_amount,0) where status is null or priority is null or tags is null or total_amount is null or payment_amount is null;
alter table public.tasks drop constraint if exists tasks_status_check, drop constraint if exists tasks_priority_check, drop constraint if exists tasks_payment_amount_nonnegative, drop constraint if exists tasks_total_amount_nonnegative;
alter table public.tasks add constraint tasks_status_check check (status in ('todo','in_progress','review','done')), add constraint tasks_priority_check check (priority in ('low','medium','high')), add constraint tasks_payment_amount_nonnegative check (payment_amount>=0), add constraint tasks_total_amount_nonnegative check (total_amount>=0);
create index if not exists tasks_active_updated_idx on public.tasks (deleted_at,status,updated_at desc);
commit;
