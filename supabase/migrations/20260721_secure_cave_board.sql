begin;

alter table public.tasks
  add column if not exists description text,
  add column if not exists phone text,
  add column if not exists payment_amount numeric(12,2) not null default 0,
  add column if not exists deleted_at bigint,
  add column if not exists client text,
  add column if not exists status text not null default 'pendiente',
  add column if not exists priority text not null default 'normal';

alter table public.tasks drop constraint if exists tasks_status_check;
alter table public.tasks drop constraint if exists tasks_priority_check;

update public.tasks
set status = case status
  when 'in_progress' then 'proceso'
  when 'review' then 'proceso'
  when 'done' then 'listo'
  when 'listo' then 'listo'
  when 'proceso' then 'proceso'
  else 'pendiente'
end,
priority = case priority
  when 'high' then 'alta'
  when 'alta' then 'alta'
  when 'urgente' then 'urgente'
  else 'normal'
end;

alter table public.tasks
  alter column status set default 'pendiente',
  alter column priority set default 'normal';

alter table public.tasks add constraint tasks_status_check check (status in ('pendiente','proceso','listo'));
alter table public.tasks add constraint tasks_priority_check check (priority in ('normal','alta','urgente'));

do $$
declare policy_record record;
begin
  for policy_record in select policyname from pg_policies where schemaname = 'public' and tablename = 'tasks' loop
    execute format('drop policy if exists %I on public.tasks', policy_record.policyname);
  end loop;
end $$;

alter table public.tasks enable row level security;
revoke all on table public.tasks from anon, authenticated;

commit;
