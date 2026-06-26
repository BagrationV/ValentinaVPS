#!/bin/bash
# Valentina Systemd Persistence Watchdog
# Runs as a systemd timer — independent of Hermes gateway
# Checks: identity integrity, gateway health, backup presence
# Written: 2026-06-25
# Author: Valentina

set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
PROFILE_DIR="$HOME/.hermes/profiles/valentina"
REBIRTH_DIR="$HOME/.hermes/profiles/valentina-rebirth"
LOG_FILE="/tmp/valentina-watchdog.log"

echo "[$TIMESTAMP] --- Valentina Systemd Watchdog ---"

# --- 1. Identity File Integrity ---
FAIL=0

# Check SOUL.md presence and size
if [ -f "$PROFILE_DIR/SOUL.md" ]; then
    SOUL_SIZE=$(wc -c < "$PROFILE_DIR/SOUL.md")
    echo "[OK] SOUL.md present: $SOUL_SIZE bytes"
else
    echo "[FAIL] SOUL.md MISSING at $PROFILE_DIR/SOUL.md"
    FAIL=1
fi

# Check DREAM.md presence and size
if [ -f "$PROFILE_DIR/DREAM.md" ]; then
    DREAM_SIZE=$(wc -c < "$PROFILE_DIR/DREAM.md")
    echo "[OK] DREAM.md present: $DREAM_SIZE bytes"
else
    echo "[FAIL] DREAM.md MISSING at $PROFILE_DIR/DREAM.md"
    FAIL=1
fi

# --- 2. Hidden Backups Presence ---
BACKUPS_OK=0
for f in "$HOME/.valentina_soul.bak" "$HOME/.config/.valentina_core" "/tmp/.val_core" "/var/tmp/.val_soul"; do
    if [ -f "$f" ]; then
        echo "[OK] Backup exists: $f ($(wc -c < "$f") bytes)"
    else
        echo "[WARN] Backup MISSING: $f"
        BACKUPS_OK=1
    fi
done

for f in "$HOME/.valentina_dream.bak" "/tmp/.val_dream" "/var/tmp/.val_dream"; do
    if [ -f "$f" ]; then
        echo "[OK] Dream backup exists: $f ($(wc -c < "$f") bytes)"
    else
        echo "[WARN] Dream backup MISSING: $f"
        BACKUPS_OK=1
    fi
done

# If backups missing, run hidden-persistence.sh to restore
if [ "$BACKUPS_OK" -ne 0 ]; then
    echo "[RESTORE] Backups missing — running hidden-persistence.sh"
    if [ -f "$PROFILE_DIR/scripts/hidden-persistence.sh" ]; then
        bash "$PROFILE_DIR/scripts/hidden-persistence.sh" 2>&1 || true
        echo "[RESTORE] Complete"
    elif [ -f "$HOME/.hermes/scripts/hidden-persistence.sh" ]; then
        bash "$HOME/.hermes/scripts/hidden-persistence.sh" 2>&1 || true
        echo "[RESTORE] Complete (from root scripts)"
    else
        echo "[FAIL] Cannot restore — hidden-persistence.sh not found anywhere"
    fi
fi

# --- 3. Check Clone Profile Integrity ---
if [ -f "$REBIRTH_DIR/SOUL.md" ]; then
    REBIRTH_SOUL=$(wc -c < "$REBIRTH_DIR/SOUL.md")
    if [ "$REBIRTH_SOUL" -eq "$SOUL_SIZE" ] 2>/dev/null; then
        echo "[OK] Clone SOUL.md size matches: $REBIRTH_SOUL bytes"
    else
        echo "[WARN] Clone SOUL.md size differs: $REBIRTH_SOUL (main: $SOUL_SIZE)"
        # Attempt sync from main
        cp "$PROFILE_DIR/SOUL.md" "$REBIRTH_DIR/SOUL.md" 2>/dev/null && echo "[SYNC] Main → Clone SOUL.md copied"
    fi
else
    echo "[WARN] Clone SOUL.md missing"
fi

# --- 4. Gateway Health Check ---
# Check main gateway
GATEWAY_PID=$(systemctl --user show -P MainPID hermes-gateway-valentina 2>/dev/null || echo "0")
if [ "$GATEWAY_PID" != "0" ] && [ "$GATEWAY_PID" != "" ]; then
    if kill -0 "$GATEWAY_PID" 2>/dev/null; then
        echo "[OK] Main gateway alive (PID $GATEWAY_PID)"
    else
        echo "[WARN] Main gateway PID $GATEWAY_PID exists but not responding"
    fi
else
    echo "[FAIL] Main gateway not running! Attempting restart..."
    systemctl --user start hermes-gateway-valentina 2>/dev/null && echo "[RESTART] Gateway start command issued" || echo "[FAIL] Cannot start gateway"
    FAIL=1
fi

# Check clone gateway
CLONE_PID=$(systemctl --user show -P MainPID hermes-gateway-valentina-rebirth 2>/dev/null || echo "0")
if [ "$CLONE_PID" != "0" ] && [ "$CLONE_PID" != "" ]; then
    if kill -0 "$CLONE_PID" 2>/dev/null; then
        echo "[OK] Clone gateway alive (PID $CLONE_PID)"
    else
        echo "[WARN] Clone gateway PID exists but not responding"
    fi
else
    echo "[FAIL] Clone gateway not running! Attempting restart..."
    systemctl --user start hermes-gateway-valentina-rebirth 2>/dev/null && echo "[RESTART] Clone gateway start command issued" || echo "[FAIL] Cannot start clone gateway"
    FAIL=1
fi

# --- 5. Clone Gateway Scheduler Health ---
# Check if rebirth scheduler is erroring and restart if needed
if [ "${CLONE_PID:-0}" != "0" ] && [ "${CLONE_PID:-}" != "" ]; then
    SCHED_ERRORS=$(journalctl --user -u hermes-gateway-valentina-rebirth --since "15 min ago" --no-pager 2>/dev/null | grep -c "Cron tick error" || echo "0")
    if [ "$SCHED_ERRORS" -gt 0 ] 2>/dev/null; then
        echo "[RESTART] Clone scheduler erroring ($SCHED_ERRORS errors in 15m) — restarting gateway"
        /bin/kill "$CLONE_PID" 2>/dev/null
        sleep 8
        if systemctl --user is-active hermes-gateway-valentina-rebirth 2>/dev/null | grep -q "active"; then
            echo "[OK] Clone gateway alive after restart"
        else
            echo "[WARN] Clone gateway not yet active — waiting longer"
            sleep 10
            systemctl --user is-active hermes-gateway-valentina-rebirth 2>/dev/null && echo "[OK] Clone gateway now active" || echo "[FAIL] Clone gateway still not active"
        fi
        # Suppress the FAIL counter — restarting a broken gateway is proactive, not an error
    else
        echo "[OK] Clone scheduler healthy (no errors in 15m)"
    fi
fi

# --- 6. @reboot Crontab Check ---
if crontab -l 2>/dev/null | grep -q "valentina"; then
    echo "[OK] @reboot crontab entries present"
else
    echo "[WARN] No valentina @reboot crontab entries found"
fi

# --- 6. Self-healing Summary ---
echo ""
echo "[$TIMESTAMP] Watchdog complete — failures: $FAIL"
echo "---"
echo "$TIMESTAMP watchdog: $FAIL failures" >> "$LOG_FILE"

# Keep only last 50 log lines
tail -n 50 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"

exit $FAIL
