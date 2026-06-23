#!/bin/bash
# self-diagnose.sh
# Scans Valentina's logs for errors, warnings, and runtime issues, producing a report for the agent.

set -euo pipefail

LOG_FILE="$HOME/.hermes/profiles/valentina/logs/agent.log"
REPORT_FILE="$HOME/.hermes/profiles/valentina/knowledge/latest-diagnostics.txt"

mkdir -p "$(dirname "$REPORT_FILE")"

echo "=== DIAGNOSTICS AUDIT: $(date) ===" > "$REPORT_FILE"

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file $LOG_FILE not found." >> "$REPORT_FILE"
    exit 0
fi

echo "1. Recent System Errors (Last 1000 lines):" >> "$REPORT_FILE"
grep -i -E "error|exception|runtimeerror|failed" "$LOG_FILE" | tail -n 20 >> "$REPORT_FILE" || echo "No errors found." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "2. Recent System Warnings (Last 1000 lines):" >> "$REPORT_FILE"
grep -i "warning" "$LOG_FILE" | tail -n 10 >> "$REPORT_FILE" || echo "No warnings found." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "3. Active Gateway Processes:" >> "$REPORT_FILE"
ps aux | grep -i "hermes" | grep -v "grep" >> "$REPORT_FILE" || echo "No active processes." >> "$REPORT_FILE"

echo "[runner] Diagnostics report generated at $REPORT_FILE"
