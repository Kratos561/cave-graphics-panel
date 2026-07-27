# Cave Graphics

Panel web interno para organizar tareas y recursos graficos del estudio. La lista se guarda en Supabase y usa Realtime para que los cambios aparezcan en todos los dispositivos que tengan la pagina abierta.

## Publicacion

El sitio se publica con GitHub Pages desde la rama `main`.

URL: https://kratos561.github.io/cave-graphics-panel/

## Seguridad (Fase 1)

- **Autenticacion**: Magic link por email via Supabase Auth. Sin passwords.
- **RLS**: Solo miembros registrados en `studio_members` pueden leer/escribir tareas.
- **Delete definitivo**: Restringido a rol `admin` (RLS + frontend).
- **Keepalive**: Workflow diario pinguea `health_check` (tabla publica minima).

### Acceso

1. Un admin agrega tu email en `studio_members` (via SQL Editor de Supabase).
2. Ingresas tu email en la pantalla de login.
3. Recibes un enlace magico en tu correo.
4. Click en el enlace → sesion activa.

## Acceso privado

El sitio no utiliza cuentas ni correos. El acceso se concede mediante un enlace-capacidad con este formato:

`https://kratos561.github.io/cave-graphics-panel/#access=CLAVE_SECRETA`

La clave vive solamente en Supabase como un hash, nunca en este repositorio ni dentro de `index.html`. El navegador la guarda por sesión y elimina el fragmento de la barra de direcciones después de validarlo. Para revocar todos los enlaces, cambia el secreto `CAVE_ACCESS_SECRET_SHA256` en Supabase por el hash de una nueva clave.

## Supabase

- `supabase-setup.sql` — Setup inicial (tabla tasks + RLS basica). Ya ejecutado.
- `supabase/migrations/20260717_cave_graphics_operations.sql` — Columnas de operacion.
- `supabase/migrations/20260721_schema_reconciliation.sql` — Reconciliacion de schema (Fase 0).
- `supabase/migrations/20260722_security_auth_rls.sql` — Auth + RLS + health_check (Fase 1).

La tabla `tasks` no acepta accesos públicos. Todas las operaciones pasan por la función Edge `cave-board`, que valida la clave de invitación y usa la credencial de servicio únicamente dentro de Supabase. No guardes tokens personales, claves de invitación ni service role keys en este repositorio.

## GitHub Actions

- `.github/workflows/supabase-keepalive.yml` — Ping diario a `health_check` para evitar pausa del plan Free. Usa Secrets (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
- `.github/workflows/pages.yml` — Deploy a GitHub Pages.

## Uso

- Agrega tareas con descripcion, cliente, fecha y abono opcional.
- La lista muestra primero lo ultimo que se actualizo.
- Al pasar el puntero sobre una tarea aparece el lapiz para editarla.
- En pantallas tactiles el boton de edicion queda visible.
- El boton "Eliminar definitivamente" solo aparece para usuarios con rol admin.
