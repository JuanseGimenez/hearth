<p align="center">
  <img src="public/icon.svg" width="88" height="88" alt="Hearth logo">
</p>

<h1 align="center">Hearth</h1>

<p align="center">
  A self-hosted, local-first web app to control your Smart Life / Tuya smart home
  — lights, plugs, brightness, color and schedules — from any device on your network.
</p>

---

Hearth runs on one machine on your home network and gives you a clean web dashboard,
reachable from any other computer or phone on the same Wi-Fi. It talks to your devices
**directly over the LAN** — no cloud, no Alexa, no internet dependency at runtime.

## How it integrates with Smart Life / Tuya

**"Smart Life" is Tuya's white-label app** — the same platform powers the Smart Life app,
the Tuya app, and dozens of rebranded smart-home apps. Devices you paired with Smart Life
speak Tuya's **local LAN protocol** (AES-encrypted, on TCP port 6668), the same one the
official apps use on your Wi-Fi.

Hearth speaks that protocol directly:

```
Browser (any PC/phone on the LAN)
        │  HTTP
        ▼
Hearth  (Rails app on this machine)
        │  shells out to a small Python bridge
        ▼
bridge.py  (tinytuya — Tuya local protocol, AES)
        │  LAN / UDP discovery + TCP 6668
        ▼
Your Smart Life / Tuya devices
```

- **Ruby (Rails)** handles the UI, persistence and schedules.
- A tiny **Python bridge** (`lib/tuya/bridge.py`) uses [`tinytuya`](https://github.com/jasonacox/tinytuya)
  to speak the device protocol. Ruby's `TuyaClient` service wraps it, so the rest of the app
  never sees Python.
- Control is **100% local at runtime** — Hearth connects to each device by its LAN IP.

### The one-time cloud step (why it's needed)

To talk to a device locally you need its **local key** — a per-device secret that lives
encrypted inside the device and can only be read out through your Tuya account. So there's a
**one-time** setup where you create a free [Tuya IoT](https://iot.tuya.com) developer project,
link your existing Smart Life account (by scanning a QR in the app), and let `tinytuya`
extract the device IDs + local keys into a `devices.json`. **After that, Hearth never needs
the cloud again** — everything runs on your LAN.

## Features

- 🔌💡 Dashboard of all your devices with a **live on/off status** indicator per card
- On/off, **brightness** and **color** control (per device capability)
- **Schedules** — run actions at a given time / days of week (e.g. lights on at 19:00)
- **Auto-detect** a device's Tuya protocol version (3.3 / 3.4 / 3.5)
- Edit devices from the web (name, IP, category, capabilities) and delete duplicates
- Shared-password login; modern, minimalist UI with automatic light/dark theme
- Works across subnets: devices on a different network segment (e.g. behind the main modem)
  can be added by IP

## Requirements

- Ruby 3.3+ and Rails 8
- Python 3 (for the tinytuya bridge)
- Your smart devices and this machine on the same home network

## One-time setup

1. **Ruby deps:** `bundle install`

2. **Python deps** in a project virtualenv (Hearth auto-detects `.venv/bin/python`):
   ```bash
   # On Debian/Ubuntu the venv ships without pip (no ensurepip module), which makes
   # a plain `python3 -m venv .venv` print an error. Create it without pip and
   # install requirements with the system pip targeted at the venv
   # (note: --python goes BEFORE the `install` subcommand):
   python3 -m venv --without-pip .venv
   python3 -m pip --python .venv/bin/python install -r requirements.txt
   ```
   (If your `python3 -m venv` already creates a working pip, just run
   `python3 -m venv .venv` then `.venv/bin/pip install -r requirements.txt`.)

3. **Extract device keys** — create a free project at [iot.tuya.com](https://iot.tuya.com),
   link your Smart Life account, then run the wizard:
   ```bash
   .venv/bin/python -m tinytuya wizard
   ```
   This writes `devices.json` with device IDs and local keys.

4. **Import** the devices into Hearth: `bin/rails tuya:import`

5. **Discover LAN IPs:** `bin/rails tuya:rescan`

6. **Set the shared password:** `export SMART_HOME_PASSWORD=yourpassword`

> Hearth runs the tinytuya bridge with `.venv/bin/python` automatically when the virtualenv
> exists. Override the interpreter with the `TUYA_PYTHON` env var if needed.

## Run

```bash
bin/rails server   # the web app
bin/jobs           # Solid Queue supervisor (runs schedules)
```

Open from any device on your network: `http://<this-machine-ip>:3000`
(use `PORT=5000 bin/rails server` to serve on another port).

## Networking notes

- Local control needs the device and this machine reachable by IP. Devices are discovered
  by LAN broadcast, which **does not cross subnets**.
- If a device lives on a **different network segment** (e.g. plugged into the main modem
  while Hearth is on a router), broadcast discovery won't find it — but you can usually still
  reach it by IP. Open the device's **Edit** page, set its IP manually, then hit
  **Auto-detect protocol version**.
- Reserve device IPs in your router (static DHCP) so local control keeps working, and re-run
  `bin/rails tuya:rescan` if an IP changes.

## Tech stack

Rails 8 · SQLite · Solid Queue · Hotwire/Turbo · Minitest · Python + tinytuya.
No external CSS/JS frameworks or CDNs — the UI is self-contained and works offline.

## Security

Hearth is meant for a **trusted home network**. It's protected by a single shared password
(`SMART_HOME_PASSWORD`); if the variable is unset, login is refused rather than allowing a
blank password. Don't expose it directly to the public internet.

## License

MIT — see `LICENSE` (add one before publishing).
