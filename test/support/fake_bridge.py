#!/usr/bin/env python3
import json, sys
cmd = json.load(sys.stdin)
json.dump({"ok": True, "state": {"echo": cmd}}, sys.stdout)
