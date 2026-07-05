#!/usr/bin/env python3
"""Local Tuya/Smart Life command bridge. Reads one JSON command on stdin,
executes it via tinytuya over the LAN, prints one JSON result on stdout."""
import json
import sys


def build_device(cmd):
    import tinytuya
    category = cmd.get("category", "plug")
    cls = tinytuya.BulbDevice if category == "light" else tinytuya.OutletDevice
    dev = cls(cmd["device_id"], cmd["ip"], cmd["local_key"])
    dev.set_version(float(cmd["version"]))
    dev.set_socketTimeout(5)
    return dev


def run(cmd):
    dev = build_device(cmd)
    action = cmd["action"]
    params = cmd.get("params") or {}

    if action == "status":
        pass
    elif action == "turn_on":
        dev.turn_on()
    elif action == "turn_off":
        dev.turn_off()
    elif action == "set_brightness":
        dev.turn_on()
        dev.set_brightness_percentage(int(params["percent"]))
    elif action == "set_color":
        dev.turn_on()
        dev.set_colour(int(params["r"]), int(params["g"]), int(params["b"]))
    else:
        raise ValueError(f"unknown action: {action}")

    status = dev.status()
    if isinstance(status, dict) and status.get("Error"):
        raise RuntimeError(status.get("Error"))
    return {"ok": True, "state": status.get("dps", {}) if isinstance(status, dict) else {}}


def main():
    try:
        cmd = json.load(sys.stdin)
        result = run(cmd)
    except Exception as exc:  # noqa: BLE001 - bridge reports all errors as JSON
        result = {"ok": False, "error": str(exc)}
    json.dump(result, sys.stdout)


if __name__ == "__main__":
    main()
