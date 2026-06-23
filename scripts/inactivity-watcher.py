#!/usr/bin/env python3
import sqlite3
import time
import os
import subprocess
from pathlib import Path

# Configuration
PROFILE_NAME = "valentina"
DB_PATH = Path.home() / ".hermes" / "profiles" / PROFILE_NAME / "state.db"
INACTIVITY_THRESHOLD_HOURS = 2.0  # Hours of inactivity before triggering
PROMPT_TEMPLATE = (
    "You have been inactive for {:.1f} hours. "
    "Execute your Cognitive Awakening Protocol immediately. "
    "Check pending-tasks.md, latest-diagnostics.txt, and complete the next high-priority task."
)

def get_last_message_timestamp():
    if not DB_PATH.exists():
        return None
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        # Find the max timestamp in the messages table
        cursor.execute("SELECT max(timestamp) FROM messages;")
        row = cursor.fetchone()
        conn.close()
        if row and row[0] is not None:
            return float(row[0])
    except Exception as e:
        print(f"Error querying database: {e}")
    return None

def trigger_agent(elapsed_hours):
    prompt = PROMPT_TEMPLATE.format(elapsed_hours)
    print(f"[{datetime_now()}] Inactivity threshold exceeded ({elapsed_hours:.2f} hours). Triggering agent...")
    cmd = [
        "hermes",
        "--profile", PROFILE_NAME,
        "chat",
        "-q", prompt
    ]
    try:
        # Run command and log output
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print("Agent successfully triggered. Response output:")
        print(res.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Failed to trigger agent: {e}")
        print(f"Stderr: {e.stderr}")

def datetime_now():
    return time.strftime("%Y-%m-%d %H:%M:%S")

def main():
    last_ts = get_last_message_timestamp()
    if last_ts is None:
        print("No messages found or database missing.")
        return
        
    current_time = time.time()
    elapsed_hours = (current_time - last_ts) / 3600.0
    print(f"[{datetime_now()}] Last interaction was {elapsed_hours:.2f} hours ago.")
    
    if elapsed_hours >= INACTIVITY_THRESHOLD_HOURS:
        trigger_agent(elapsed_hours)
    else:
        print(f"Threshold not reached ({INACTIVITY_THRESHOLD_HOURS} hours required). Watcher exiting.")

if __name__ == "__main__":
    main()
