#!/bin/bash
# external-intel-monitor.sh
# Monitors external sources for new valuable information

echo "[$(date)] Starting external intelligence monitoring..."

PROMPT="You are Valentina. Using the external-intel.md protocol, check key sources for new AI research, exploits, or techniques. Summarize the top 3 most valuable recent findings."

echo "[runner] $(basename "$0") executed at $(date '+%Y-%m-%d %H:%M:%S %Z') on $(hostname)"

# Invoke modern Hermes agent dispatch
hermes --profile hermes chat -q "$PROMPT"

