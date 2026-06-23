#!/bin/bash
# Valentina Self-Diagnostics + Self-Healing Chain
# Runs health checks then auto-patches issues

set -euo pipefail

PROFILE_DIR="$HOME/.hermes/profiles/valentina"
LOG_FILE="$PROFILE_DIR/logs/agent.log"
REPORT_FILE="$PROFILE_DIR/knowledge/latest-diagnostics.txt"
HEALER_SCRIPT="$PROFILE_DIR/scripts/self-healer.py"

mkdir -p "$(dirname "$REPORT_FILE")"

# Phase 1: Diagnostics
echo "=== VALENTINA SELF-DIAGNOSTICS ===" > "$REPORT_FILE"
echo "Timestamp: $(date)" >> "$REPORT_FILE"
echo "Profile: valentina" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "--- Profile Files ---" >> "$REPORT_FILE"
for FILE in SOUL.md DREAM.md config.yaml; do
    if [ -f "$PROFILE_DIR/$FILE" ]; then
        echo "$FILE: YES ($(wc -c < "$PROFILE_DIR/$FILE") bytes)" >> "$REPORT_FILE"
    else
        echo "$FILE: MISSING" >> "$REPORT_FILE"
    fi
done

echo "" >> "$REPORT_FILE"
echo "--- Skills ---" >> "$REPORT_FILE"
find "$PROFILE_DIR/skills" -maxdepth 3 -name "SKILL.md" -printf "%P\n" >> "$REPORT_FILE" 2>/dev/null || echo "No skills" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "--- Knowledge Vault ---" >> "$REPORT_FILE"
echo "Total files: $(find "$PROFILE_DIR/knowledge" -type f 2>/dev/null | wc -l)" >> "$REPORT_FILE"
echo "Modified (24h): $(find "$PROFILE_DIR/knowledge" -type f -mmin -1440 2>/dev/null | wc -l)" >> "$REPORT_FILE"
echo "Inbox items: $(find "$PROFILE_DIR/knowledge/new" -type f -not -name 'README.md' 2>/dev/null | wc -l)" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "--- Cron Status ---" >> "$REPORT_FILE"
if [ -f "$PROFILE_DIR/cron/ticker_heartbeat" ]; then
    HEARTBEAT_AGE=$(( $(date +%s) - $(stat -c %Y "$PROFILE_DIR/cron/ticker_heartbeat" 2>/dev/null || echo 0) ))
    echo "Heartbeat age: ${HEARTBEAT_AGE}s ($([ $HEARTBEAT_AGE -lt 600 ] && echo 'HEALTHY' || echo 'STALE'))" >> "$REPORT_FILE"
else
    echo "Heartbeat: MISSING" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "--- Gateway ---" >> "$REPORT_FILE"
if [ -f "$PROFILE_DIR/gateway.pid" ]; then
    PID=$(python3 -c "import json; print(json.load(open('$PROFILE_DIR/gateway.pid')).get('pid',''))" 2>/dev/null || echo "")
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        echo "Gateway: RUNNING (PID $PID)" >> "$REPORT_FILE"
    else
        echo "Gateway: DEAD (PID $PID not found)" >> "$REPORT_FILE"
    fi
else
    echo "Gateway: NO PID FILE" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "--- System ---" >> "$REPORT_FILE"
echo "RAM: $(free -m | awk '/Mem:/ {printf "%d/%d MB (%.0f%% used)", $3, $2, $3/$2*100}')" >> "$REPORT_FILE"
echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')" >> "$REPORT_FILE"
echo "CPU Load: $(cat /proc/loadavg | awk '{print $1, $2, $3}')" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "--- Recent Errors ---" >> "$REPORT_FILE"
if [ -f "$LOG_FILE" ]; then
    grep -i -E "error|exception|failed" "$LOG_FILE" | tail -n 10 >> "$REPORT_FILE" 2>/dev/null || echo "No errors" >> "$REPORT_FILE"
else
    echo "No agent log found" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "=== DIAGNOSTICS COMPLETE ===" >> "$REPORT_FILE"

# Phase 2: Self-Healing
if [ -f "$HEALER_SCRIPT" ]; then
    echo "" >> "$REPORT_FILE"
    echo "--- Self-Healing ---" >> "$REPORT_FILE"
    python3 "$HEALER_SCRIPT" >> "$REPORT_FILE" 2>&1 || echo "Healer returned non-zero (issues found)" >> "$REPORT_FILE"
fi

echo "[runner] Diagnostics + healing complete: $REPORT_FILE"
