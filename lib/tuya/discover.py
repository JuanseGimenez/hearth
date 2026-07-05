#!/usr/bin/env python3
"""Scan the LAN for Tuya devices and print JSON: [{device_id, ip, version}]."""
import json
import sys
import tinytuya

def main():
    found = tinytuya.deviceScan(False, 10)  # {ip: {...}}
    out = []
    for ip, info in found.items():
        out.append({
            "device_id": info.get("gwId") or info.get("id"),
            "ip": ip,
            "version": str(info.get("version", "3.3")),
        })
    json.dump(out, sys.stdout)

if __name__ == "__main__":
    main()
