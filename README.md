# Supabase Keep-Alive — Proyecto "Cave"

Este workflow evita que tu proyecto Supabase (`owltcxzfbitmbynhwtvq`) se pause
por inactividad. Supabase pausa los proyectos del plan gratuito después de
**7 días sin consultas reales a la base de datos**. Este script hace una
lectura real cada 3 días, dejando un margen amplio de seguridad.

## Cómo activarlo (una sola vez, ~2 minutos)

1. Crea un repositorio nuevo en GitHub (puede ser privado).
2. Sube esta carpeta completa tal cual está (incluyendo la carpeta oculta
   `.github/workflows/`).
3. En el repo, ve a **Settings → Secrets and variables → Actions → New
   repository secret** y agrega dos secretos:
   - `SUPABASE_URL` → `https://owltcxzfbitmbynhwtvq.supabase.co`
   - `SUPABASE_ANON_KEY` → tu clave pública `anon` (la misma que ya usa el HTML)
4. Ve a la pestaña **Actions** del repo y confirma que el workflow
   "Supabase Keep-Alive" aparece habilitado.
5. Opcional: corre el workflow manualmente una vez (botón "Run workflow")
   para verificar que responde con ✅ antes de dejar que corra solo.

A partir de ahí, GitHub lo ejecuta automáticamente cada 3 días, gratis,
sin que tengas que hacer nada más.

## ¿Por qué GitHub Actions y no otra cosa?

- Es gratis para repos ilimitados en cuentas personales (dentro del límite
  generoso de minutos gratuitos, y este job tarda segundos).
- No depende de que tu computadora, Railway o n8n estén encendidos.
- Queda documentado en la pestaña "Actions": puedes ver el historial de
  cada ping y si alguno falló.

## Alternativa sin código (si prefieres no tocar GitHub)

Si prefieres no crear un repo, puedes lograr lo mismo con
[UptimeRobot](https://uptimerobot.com) (plan gratis):

1. Crea un monitor tipo "HTTP(s)".
2. URL: `https://owltcxzfbitmbynhwtvq.supabase.co/rest/v1/tasks?select=id&limit=1`
3. En "Custom HTTP Headers" agrega:
   - `apikey: TU_ANON_KEY`
   - `Authorization: Bearer TU_ANON_KEY`
4. Intervalo: cada 5 minutos o cada 12 horas, cualquiera sirve — ambos
   están muy por debajo del límite de 7 días.

## Nota de seguridad

La clave `anon` es segura para este uso: solo puede leer lo que las
políticas RLS de la tabla `tasks` permiten (que ya configuraste como
lectura pública). No expone privilegios de administrador.
