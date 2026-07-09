-- Cave Graphics - tabla y sincronizacion en tiempo real.
-- Ejecuta este archivo una vez en Supabase SQL Editor.

create table if not exists public.tasks (
  id text primary key,
  text text not null check (length(trim(text)) > 0),
  date date,
  created_at bigint not null default ((extract(epoch from now()) * 1000)::bigint),
  updated_at bigint not null default ((extract(epoch from now()) * 1000)::bigint)
);

alter table public.tasks
  add column if not exists updated_at bigint not null default ((extract(epoch from now()) * 1000)::bigint);

create or replace function public.set_tasks_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = ((extract(epoch from now()) * 1000)::bigint);
  return new;
end;
$$;

drop trigger if exists tasks_set_updated_at on public.tasks;

create trigger tasks_set_updated_at
before update on public.tasks
for each row
execute function public.set_tasks_updated_at();

alter table public.tasks enable row level security;

drop policy if exists "tasks_select_public" on public.tasks;
drop policy if exists "tasks_insert_public" on public.tasks;
drop policy if exists "tasks_update_public" on public.tasks;
drop policy if exists "tasks_delete_public" on public.tasks;

create policy "tasks_select_public"
on public.tasks
for select
using (true);

create policy "tasks_insert_public"
on public.tasks
for insert
with check (true);

create policy "tasks_update_public"
on public.tasks
for update
using (true)
with check (true);

create policy "tasks_delete_public"
on public.tasks
for delete
using (true);

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'tasks'
  ) then
    alter publication supabase_realtime add table public.tasks;
  end if;
end;
$$;
