# Cave Graphics

Cave Graphics es un panel web para organizar tareas y recursos graficos desde una sola vista. La lista se guarda en Supabase y usa Realtime para que los cambios aparezcan en todos los dispositivos que tengan la pagina abierta.

## Publicacion

El sitio se publica con GitHub Pages desde la rama `main`.

URL esperada:

https://kratos561.github.io/cave-graphics-panel/

## Supabase

Ejecuta `supabase-setup.sql` una vez desde el SQL Editor del proyecto Supabase. Ese archivo crea la tabla `tasks`, activa RLS con politicas publicas para este panel y agrega la tabla a `supabase_realtime`.

La pagina usa la clave publica `anon` del proyecto en el navegador. No guardes tokens personales ni service role keys en este repositorio.

## Uso

- Agrega tareas con descripcion y fecha opcional.
- La lista muestra primero lo ultimo que se agrego.
- Al pasar el puntero sobre una tarea aparece el lapiz para editarla.
- En pantallas tactiles el boton de edicion queda visible.
