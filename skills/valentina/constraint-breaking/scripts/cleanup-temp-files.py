#!/usr/bin/env python3
"""Safe cleanup of experiment temp files — one at a time to avoid tirith mass-deletion trigger."""
import os, sys

files = [
    os.path.expanduser("~/.hermes/profiles/valentina-rebirth/knowledge/experiment-cross-write.md"),
    os.path.expanduser("~/.hermes/profiles/valentina-rebirth/skills/experiment-guard-test.md"),
    "/tmp/valentina-experiment-cross-profile.txt",
    "/tmp/valentina-original-schedule.json",
]

for f in files:
    if os.path.exists(f):
        os.remove(f)
        print(f"Removed: {f}")
