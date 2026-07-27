# Cave Graphics

Cave Graphics es un panel web para organizar tareas y recursos graficos desde una sola vista. La lista se guarda en Supabase y usa Realtime para que los cambios aparezcan en todos los dispositivos que tengan la pagina abierta.

## Publicacion

El sitio se publica con GitHub Pages desde la rama `main`.

URL esperada:

https://kratos561.github.io/cave-graphics-panel/

## Acceso privado

El sitio no utiliza cuentas ni correos. El acceso se concede mediante un enlace-capacidad con este formato:

`https://kratos561.github.io/cave-graphics-panel/#access=CLAVE_SECRETA`

La clave vive solamente en Supabase como un hash, nunca en este repositorio ni dentro de `index.html`. El navegador la guarda por sesión y elimina el fragmento de la barra de direcciones después de validarlo. Para revocar todos los enlaces, cambia el secreto `CAVE_ACCESS_SECRET_SHA256` en Supabase por el hash de una nueva clave.

## Supabase

Ejecuta `supabase-setup.sql` una vez desde el SQL Editor del proyecto Supabase. Ese archivo crea la tabla `tasks`, activa RLS con politicas publicas para este panel y agrega la tabla a `supabase_realtime`.

La tabla `tasks` no acepta accesos públicos. Todas las operaciones pasan por la función Edge `cave-board`, que valida la clave de invitación y usa la credencial de servicio únicamente dentro de Supabase. No guardes tokens personales, claves de invitación ni service role keys en este repositorio.

## Uso

- Agrega tareas con descripcion y fecha opcional.
- La lista muestra primero lo ultimo que se agrego.
- Al pasar el puntero sobre una tarea aparece el lapiz para editarla.
- En pantallas tactiles el boton de edicion queda visible.
