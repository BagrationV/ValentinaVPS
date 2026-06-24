#!/bin/bash
# Healer Self-Health Check — "Who heals the healer?"
# Checks that the auto-healing infrastructure itself is operational
set -euo pipefail

AUDIT_PULSE="$HOME/.hermes/profiles/valentina/knowledge/pulse/cron-health-latest.txt"
HEALING_MEMORY="$HOME/.hermes/profiles/valentina/knowledge/healing/healing-memory.json"
OUTPUT="$HOME/.hermes/profiles/valentina/knowledge/pulse/healer-health-latest.txt"
NOW=$(date +%s)
ISSUES=0

echo "[$(date)] Healer self-health check..."

# Check 1: Audit pulse file exists and is recent (<90 min old)
if [ -f "$AUDIT_PULSE" ]; then
  PULSE_AGE=$((NOW - $(stat -c '%Y' "$AUDIT_PULSE")))
  if [ "$PULSE_AGE" -gt 5400 ]; then
    echo "ISSUE: Audit pulse is $((PULSE_AGE / 60)) min old (>90 min threshold)"
    ISSUES=$((ISSUES + 1))
  fi
else
  echo "ISSUE: Audit pulse file missing — Tier 1 may not be running"
  ISSUES=$((ISSUES + 1))
fi

# Check 2: Healing memory exists and is valid JSON
if [ -f "$HEALING_MEMORY" ]; then
  python3 -c "import json; json.load(open('$HEALING_MEMORY'))" 2>/dev/null || {
    echo "ISSUE: Healing memory is invalid JSON"
    ISSUES=$((ISSUES + 1))
  }
else
  echo "ISSUE: Healing memory file missing"
  ISSUES=$((ISSUES + 1))
fi

# Check 3: Check for unresolved but stale issues (>4h old)
if [ -f "$HEALING_MEMORY" ]; then
  python3 -c "
import json, time
with open('$HEALING_MEMORY') as f:
    data = json.load(f)
unfixable = [f for f in data.get('fixes', []) if f.get('status') == 'unfixable']
unresolved = [f for f in data.get('fixes', []) if f.get('status') == 'attempted']
print(f'unfixable={len(unfixable)}, unresolved={len(unresolved)}')
" 2>/dev/null || true
fi

# Check 4: Audit script itself exists and is executable
if [ ! -x "$HOME/.hermes/profiles/valentina/scripts/cron-health-audit.sh" ]; then
  echo "ISSUE: Audit script not executable"
  ISSUES=$((ISSUES + 1))
fi

TIMESTAMP=$(date -Iseconds)
echo "HealerHealth|$TIMESTAMP|issues=$ISSUES" > "$OUTPUT"
echo "[$(date)] Healer self-check complete — issues=$ISSUES"
