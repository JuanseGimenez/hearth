# Smart Home

Local web control for Smart Life / Tuya devices (on/off, brightness, color, schedules).

## One-time setup

1. Ruby deps: `bundle install`.
2. Python deps in a project virtualenv (the app auto-detects `.venv/bin/python`):
   ```bash
   python3 -m venv .venv
   # On Debian/Ubuntu the venv ships without pip (no ensurepip). Bootstrap it
   # with the system pip, then install requirements:
   python3 -m pip --python .venv/bin/python install -r requirements.txt
   ```
   (If your `python3 -m venv` already creates a working pip, just use
   `.venv/bin/pip install -r requirements.txt` instead.)
3. Extract device keys (needs a free account at iot.tuya.com linked to your Smart Life app):
   `.venv/bin/python -m tinytuya wizard`
   This writes `devices.json` with device ids and local keys.
4. Import them: `bin/rails tuya:import`
5. Discover IPs on your LAN: `bin/rails tuya:rescan`
6. Set the shared password: `export SMART_HOME_PASSWORD=yourpassword`

The app runs the tinytuya bridge with `.venv/bin/python` automatically when the
virtualenv exists. Override the interpreter with the `TUYA_PYTHON` env var if needed.

## Run

- Web + jobs: `bin/rails server` and `bin/jobs` (Solid Queue supervisor for schedules).
- Open from another computer: `http://<this-machine-ip>:3000`

Tip: reserve device IPs in your router (static DHCP) so local control keeps working.
Re-run `bin/rails tuya:rescan` if an IP changes.
