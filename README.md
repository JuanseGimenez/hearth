# Smart Home

Local web control for Smart Life / Tuya devices (on/off, brightness, color, schedules).

## One-time setup

1. Install deps: `bundle install` and `python3 -m pip install -r requirements.txt`.
2. Extract device keys (needs a free account at iot.tuya.com linked to your Smart Life app):
   `python3 -m tinytuya wizard`
   This writes `devices.json` with device ids and local keys.
3. Import them: `bin/rails tuya:import`
4. Discover IPs on your LAN: `bin/rails tuya:rescan`
5. Set the shared password: `export SMART_HOME_PASSWORD=yourpassword`

## Run

- Web + jobs: `bin/rails server` and `bin/jobs` (Solid Queue supervisor for schedules).
- Open from another computer: `http://<this-machine-ip>:3000`

Tip: reserve device IPs in your router (static DHCP) so local control keeps working.
Re-run `bin/rails tuya:rescan` if an IP changes.
