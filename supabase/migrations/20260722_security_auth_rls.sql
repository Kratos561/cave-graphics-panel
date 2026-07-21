-- Fase 1: Seguridad interna (Auth + RLS)
-- 1.1: Tabla studio_members con RLS
-- 1.2: Politicas de tasks basadas en autenticacion (reemplaza using(true))
-- 1.4: Tabla health_check para el workflow de keepalive
-- Ejecutado: 2026-07-22

begin;

-- =============================================
-- 1.1: Tabla de miembros del estudio
-- =============================================
create table if not exists public.studio_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  role text not null default 'editor' check (role in ('admin','editor','viewer')),
  created_at timestamptz not null default now()
);

alter table public.studio_members enable row level security;

drop policy if exists "members_read_own" on public.studio_members;
create policy "members_read_own"
  on public.studio_members for select
  using (auth.uid() = user_id);

drop policy if exists "members_admin_insert" on public.studio_members;
create policy "members_admin_insert"
  on public.studio_members for insert
  with check (exists (
    select 1 from public.studio_members
    where user_id = auth.uid() and role = 'admin'
  ));

drop policy if exists "members_admin_update" on public.studio_members;
create policy "members_admin_update"
  on public.studio_members for update
  using (exists (
    select 1 from public.studio_members
    where user_id = auth.uid() and role = 'admin'
  ));

drop policy if exists "members_admin_delete" on public.studio_members;
create policy "members_admin_delete"
  on public.studio_members for delete
  using (exists (
    select 1 from public.studio_members
    where user_id = auth.uid() and role = 'admin'
  ));

-- =============================================
-- 1.2: Reemplazar politicas publicas de tasks
-- =============================================
drop policy if exists "tasks_select_public" on public.tasks;
drop policy if exists "tasks_insert_public" on public.tasks;
drop policy if exists "tasks_update_public" on public.tasks;
drop policy if exists "tasks_delete_public" on public.tasks;

create policy "tasks_select_members"
  on public.tasks for select
  using (exists (
    select 1 from public.studio_members where user_id = auth.uid()
  ));

create policy "tasks_insert_members"
  on public.tasks for insert
  with check (exists (
    select 1 from public.studio_members where user_id = auth.uid()
  ));

create policy "tasks_update_members"
  on public.tasks for update
  using (exists (
    select 1 from public.studio_members where user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.studio_members where user_id = auth.uid()
  ));

create policy "tasks_delete_admin"
  on public.tasks for delete
  using (exists (
    select 1 from public.studio_members
    where user_id = auth.uid() and role = 'admin'
  ));

-- =============================================
-- 1.4: Tabla health_check para keepalive
-- =============================================
create table if not exists public.health_check (
  id text primary key default 'ping',
  pinged_at timestamptz not null default now()
);

insert into public.health_check (id) values ('ping') on conflict (id) do nothing;

alter table public.health_check enable row level security;

drop policy if exists "health_check_public_read" on public.health_check;
create policy "health_check_public_read"
  on public.health_check for select
  using (true);

drop policy if exists "health_check_public_write" on public.health_check;
create policy "health_check_public_write"
  on public.health_check for update
  using (true) with check (true);

commit;
