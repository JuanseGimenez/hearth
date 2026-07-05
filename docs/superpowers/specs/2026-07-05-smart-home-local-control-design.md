# Smart Home — Control local de dispositivos Smart Life / Tuya

**Fecha:** 2026-07-05
**Estado:** Diseño aprobado

## Resumen

Aplicación web en **Rails 8** (última estable) que corre en la máquina local del usuario y
permite prender/apagar, regular brillo/color y programar horarios sobre dispositivos smart
de la marca **Smart Life / Tuya** (enchufes, lámparas), accesible desde otras computadoras
de la red hogareña.

El control a los dispositivos es **100% local (LAN)**: no depende de la nube de Tuya ni de
Alexa en tiempo de ejecución. Alexa queda explícitamente **fuera de alcance** — el usuario
solo quiere controlar los dispositivos, y hacerlo directo es más rápido y confiable.

> Nota sobre marcas: "Smart Life" es la app genérica *powered by Tuya*. Los dispositivos
> comprados bajo Smart Life hablan exactamente el mismo protocolo local que los "Tuya".
> En este documento "Tuya" se refiere a ese protocolo local.

## Objetivos

- Controlar dispositivos Smart Life/Tuya desde una web servida en `localhost`, accesible
  desde otras PCs de la LAN.
- Funciones: **On/Off**, **brillo y color** (en lámparas que lo soporten), **horarios**
  (automatizaciones por hora).
- Acceso protegido por un **único password compartido**.
- Runtime sin dependencia de internet ni de la nube.

## No-objetivos (YAGNI por ahora)

- Control de Alexa (hablar, rutinas, comandos de voz).
- Escenas / grupos de dispositivos.
- Usuarios múltiples con cuentas individuales.
- Polling constante del estado de los dispositivos.

## Decisiones de arquitectura

### Stack
- **Rails 8.x** (última estable), Ruby 3.3+.
- **SQLite** como base de datos (default de Rails 8; un solo archivo, sin servidor aparte).
- **Solid Queue** para jobs y horarios (sobre SQLite, sin Redis).
- **Hotwire / Turbo** para feedback en vivo en la UI sin recargar la página.

### Capa de dispositivos: Rails + `tinytuya` (Python)
El protocolo local de Tuya usa encriptación AES y, en las versiones nuevas (3.4 / 3.5),
un handshake con negociación de clave de sesión. En Ruby no hay una librería madura que lo
cubra de forma confiable. En Python, `tinytuya` es el estándar de facto: cubre todas las
versiones del protocolo, el escaneo de dispositivos en la red y el asistente de extracción
de local keys.

**Enfoque elegido (Opción A):** Rails invoca un script Python (`bridge.py`) por comando.
Simple y confiable. Si más adelante la latencia molesta, se puede migrar a un sidecar Python
persistente con mini-API HTTP (Opción C) reutilizando el mismo código Python.

```
Navegador (otras PCs) ──HTTP──> Rails (esta máquina) ──shell──> bridge.py (tinytuya) ──LAN/AES──> Dispositivos
```

## Componentes

Cada componente tiene una responsabilidad única e interfaces bien definidas.

### 1. `Device` (modelo)
Persiste por dispositivo:
- `name` — nombre legible (ej. "Lámpara living").
- `tuya_device_id` — ID del dispositivo en Tuya.
- `ip` — IP en la LAN.
- `local_key` — clave local para la encriptación (secreto).
- `protocol_version` — versión del protocolo (ej. "3.3", "3.4", "3.5").
- `category` — `plug` | `light`.
- `capabilities` — flags: `on_off`, `brightness`, `color`.

Validaciones: presencia de `name`, `tuya_device_id`, `local_key`, `protocol_version`.

### 2. `TuyaClient` (service object, Ruby)
Interfaz limpia sobre un `Device`. No expone detalles de Python a sus consumidores.
- `turn_on` / `turn_off`
- `set_brightness(percent)` — 0–100
- `set_color(...)` — color/temperatura según capacidad
- `status` — estado actual del dispositivo

Internamente construye el payload JSON y llama a `bridge.py`, parsea la respuesta JSON y
traduce errores a excepciones/resultados propios del dominio.

### 3. `bridge.py` (Python)
- Recibe un comando en JSON (por argv o stdin): `{device_id, ip, local_key, version, action, params}`.
- Usa `tinytuya` para ejecutarlo contra el dispositivo.
- Devuelve JSON: `{ok: true, state: {...}}` o `{ok: false, error: "..."}`.
- Toda la complejidad del protocolo/encriptación vive acá.

### 4. UI web (controllers + vistas, Hotwire/Turbo)
- **Dashboard**: tarjetas por dispositivo con:
  - botón toggle on/off
  - slider de brillo (si `brightness`)
  - selector de color/temperatura (si `color`)
- Feedback en vivo vía Turbo tras cada acción.
- Vista de administración de **horarios** (alta/baja/edición).

### 5. Auth — password compartido
- Un `before_action` global que exige una única clave.
- La clave se configura por variable de entorno / Rails credentials (nunca hardcodeada).
- Una vez validada, se recuerda en la sesión.
- Formulario de login mínimo.

### 6. Horarios
- Modelo `Schedule`: `device_id`, `action` (on/off/brightness/color), `params`,
  `time` (hora del día, y días de semana), `enabled`.
- Un **job recurrente de Solid Queue** corre cada minuto, busca los `Schedule` que
  corresponden a ese minuto y están `enabled`, y ejecuta la acción vía `TuyaClient`.

## Setup inicial (una sola vez)

Tarea rake documentada que:
1. Corre el asistente de `tinytuya` — el usuario linkea su cuenta **Smart Life** a un
   proyecto gratuito en iot.tuya.com para **extraer device IDs + local keys**.
2. Hace un **scan de la red** para descubrir las IPs de los dispositivos.
3. Siembra la tabla `Device` con lo obtenido.

Después de este paso, el runtime no depende de internet.

**Requisitos de red:** el servidor y los dispositivos deben estar en la misma subred. Como
el control local usa la IP del dispositivo, se recomienda **reservar las IPs en el router**
(DHCP estático) para que no cambien. Igual se provee un botón de re-escaneo (ver abajo).

## Flujo de un comando

```
Click en toggle
  → Turbo request
  → DevicesController#toggle
  → TuyaClient#turn_on
  → bridge.py (tinytuya)
  → dispositivo en la LAN
  → respuesta JSON
  → la tarjeta del dispositivo se actualiza vía Turbo
```

## Manejo de errores

- **Dispositivo apagado / fuera de red / timeout:** `TuyaClient` lo captura; la tarjeta se
  muestra como **"inalcanzable"** con botón de reintentar. Nunca tira abajo la app.
- **Errores del bridge:** se devuelven como JSON `{ok:false, error}` y se traducen a un
  mensaje claro en la UI.
- **Local key incorrecta o IP cambiada:** error claro en pantalla + botón **"re-escanear"**
  que redescubre IPs por device-id y actualiza la tabla `Device`.

## Testing

- **`TuyaClient`**: testeado con `bridge.py` **mockeado** (fake script o stub del shell call);
  no requiere hardware real.
- **Modelos**: validaciones de `Device` y `Schedule`.
- **Controllers / system**: auth (login con password) y toggle de dispositivo, con
  `TuyaClient` stubbeado.
- **Horarios**: test del job recurrente seleccionando los `Schedule` que corresponden.

## Configuración de acceso en red

- La app corre con binding `0.0.0.0` para ser accesible desde otras PCs de la LAN.
- Se accede vía `http://<ip-de-esta-maquina>:3000`.
- Protegida por el password compartido.

## Estructura de proyecto (orientativa)

```
smart-home/
├── app/
│   ├── controllers/   # sessions, devices, schedules
│   ├── models/        # device, schedule
│   ├── services/      # tuya_client.rb
│   ├── jobs/          # schedule_runner_job.rb
│   └── views/         # dashboard, devices, schedules, sessions
├── lib/
│   └── tuya/
│       └── bridge.py  # puente tinytuya
├── lib/tasks/
│   └── tuya.rake      # setup: wizard + scan + seed
└── docs/superpowers/specs/
```

## Extensiones futuras (no ahora)

- Sidecar Python persistente (Opción C) si hace falta menor latencia.
- Escenas / grupos.
- Polling de estado en tiempo real.
- Control de Alexa (announcements / rutinas) si algún día se quiere.
