-- Fase 0.2 + 0.3: Reconciliacion de schema
-- Documenta columnas que ya existen en produccion pero no en el historial
-- de migraciones, y elimina columnas fantasma nunca usadas en el frontend.
-- Ejecutado: 2026-07-22

begin;

-- 0.2: Documentar columnas existentes (idempotente)
alter table public.tasks
  add column if not exists payment_amount numeric(12,2) not null default 0,
  add column if not exists deleted_at bigint,
  add column if not exists phone text,
  add column if not exists description text;

-- Asegurar NOT NULL en payment_amount
update public.tasks set payment_amount = 0 where payment_amount is null;
alter table public.tasks alter column payment_amount set not null;
alter table public.tasks alter column payment_amount set default 0;

-- Constraint de no-negativo
alter table public.tasks drop constraint if exists tasks_payment_amount_nonnegative;
alter table public.tasks add constraint tasks_payment_amount_nonnegative check (payment_amount >= 0);

-- 0.3: Eliminar columnas fantasma (tags, total_amount) nunca usadas en index.html
alter table public.tasks drop constraint if exists tasks_total_amount_nonnegative;
alter table public.tasks drop column if exists tags;
alter table public.tasks drop column if exists total_amount;

commit;
