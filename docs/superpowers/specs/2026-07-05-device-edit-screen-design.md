# Device Edit Screen — Design

**Fecha:** 2026-07-05
**Estado:** Diseño aprobado

## Resumen

Agregar una pantalla web para editar dispositivos ya importados: setear IP, versión de
protocolo, categoría y capacidades, auto-detectar la versión de protocolo, y borrar
dispositivos (para limpiar duplicados). Necesario porque los dispositivos que cuelgan de
una subred distinta (ej. la red del modem) no se descubren por broadcast y hay que cargarles
la IP a mano; hoy eso solo se puede hacer por consola.

## Motivación

- Los dispositivos en otra subred (red del modem, `192.168.0.x`) son alcanzables por IP
  directa pero el broadcast de descubrimiento no cruza, así que quedan sin IP tras
  `tuya:rescan`. Hay que cargar IP + versión manualmente.
- No hay forma de activar brillo/color, corregir la categoría, ni borrar duplicados
  ("Velador" fantasma) desde la web.

## Alcance

**Incluye:**
- Editar: nombre, categoría (`plug`/`light`), IP, versión de protocolo, capacidades
  (`on_off`, `brightness`, `color`).
- Auto-detectar versión: probar 3.3/3.4/3.5 con `TuyaClient#status` sobre la IP guardada,
  persistir la que funcione, y reportar el resultado.
- Borrar dispositivo (para duplicados).
- Link "Editar" en cada tarjeta del dashboard.

**No incluye (YAGNI):**
- Crear dispositivos desde cero a mano (siguen viniendo de `tuya:import`).
- Editar la local key (secreto; se re-importa si hace falta).

## Diseño

### Rutas
```ruby
resources :devices, only: [ :index, :edit, :update, :destroy ] do
  member do
    post :command        # (existente)
    post :detect_version # nuevo
  end
end
```

### Controlador (`DevicesController`)
- `edit` — carga el dispositivo, renderiza el form.
- `update` — strong params: `name, category, ip, protocol_version, on_off, brightness, color`.
  Redirige al dashboard en éxito; re-renderiza `edit` con `:unprocessable_entity` si falla la
  validación.
- `destroy` — borra el dispositivo, redirige al dashboard.
- `detect_version` — si el dispositivo no tiene IP, redirige a `edit` con alerta "cargá y
  guardá la IP primero". Si tiene IP, prueba `%w[3.3 3.4 3.5]` con `TuyaClient#status`
  (seteando `protocol_version` en memoria por intento); a la primera que da `ok: true`,
  persiste esa versión y redirige a `edit` con aviso de éxito. Si ninguna funciona, redirige
  con alerta.

### Vistas
- `devices/edit.html.erb`: form con los campos del alcance + botón "Auto-detectar versión"
  (POST a `detect_version`) + botón "Borrar" (con confirmación).
- `devices/_device.html.erb`: agregar link "Editar" (`edit_device_path(device)`), sin quitar
  los controles existentes.

### Errores
- `detect_version` sin IP → alerta clara, sin llamar a la red.
- `TuyaClient#status` ya devuelve `{ok:false, error:}` en caso de fallo; se refleja en el
  flash.

## Testing (Minitest)
- `update` cambia atributos y redirige.
- `destroy` borra el dispositivo.
- `detect_version` con `TuyaClient` stubbeado: encuentra y persiste la versión que responde
  `ok: true`.
- `detect_version` sin IP: no llama a `TuyaClient`, redirige con alerta.
- Todo bajo `require_login` (auth existente).
