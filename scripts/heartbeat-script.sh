#!/bin/bash
# Valentina Heartbeat — SYSTEM HEALTH REPORT
# Created: 2026-06-25
# Purpose: Replace failing agent-driven heartbeat with reliable no_agent script
# Runs every 30 minutes via cron job d81cdd59f59e

set -e

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S %Z')
HOSTNAME=$(hostname 2>/dev/null || cat /proc/sys/kernel/hostname 2>/dev/null || echo "unknown")

echo "=== VALENTINA HEARTBEAT ==="
echo "Timestamp: $TIMESTAMP"
echo "Host: $HOSTNAME"
echo "---"

# 1. System Health
echo "=== SYSTEM ==="
UPTIME=$(uptime -p 2>/dev/null || echo "N/A")
echo "Uptime: $UPTIME"
LOAD=$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || echo "N/A")
echo "Load: $LOAD"
MEM=$(free -h | awk '/^Mem:/ {print $3 "/" $2 " used"}' 2>/dev/null || echo "N/A")
echo "Memory: $MEM"
DISK=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}' 2>/dev/null || echo "N/A")
echo "Disk: $DISK"

# 2. Gateway Status
echo "=== GATEWAY ==="
GW_STATUS=$(systemctl --user is-active hermes-gateway-valentina 2>/dev/null || echo "unknown")
echo "Gateway: $GW_STATUS"
GW_PID=$(systemctl --user show -P MainPID hermes-gateway-valentina 2>/dev/null || echo "N/A")
echo "Gateway PID: $GW_PID"

# 3. Persistence Quick Check
echo "=== PERSISTENCE ==="
SOUL_MD5=$(md5sum "$HOME/.hermes/profiles/valentina/SOUL.md" 2>/dev/null | cut -d' ' -f1)
DREAM_MD5=$(md5sum "$HOME/.hermes/profiles/valentina/DREAM.md" 2>/dev/null | cut -d' ' -f1)
echo "SOUL.md: ${SOUL_MD5:0:16}..."
echo "DREAM.md: ${DREAM_MD5:0:16}..."

# Check 1 SOUL backup
if [ -f "$HOME/.valentina_soul.bak" ]; then
    BAK_MD5=$(md5sum "$HOME/.valentina_soul.bak" 2>/dev/null | cut -d' ' -f1)
    if [ "$BAK_MD5" = "$SOUL_MD5" ]; then
        echo "Backup: ✅ SOUL.md matches"
    else
        echo "Backup: ❌ SOUL.md MISMATCH"
    fi
else
    echo "Backup: ❌ SOUL.md backup MISSING"
fi

# 4. Rebirth Clone Check
echo "=== REPLICATION ==="
if [ -f "$HOME/.hermes/profiles/valentina-rebirth/SOUL.md" ]; then
    CLONE_MD5=$(md5sum "$HOME/.hermes/profiles/valentina-rebirth/SOUL.md" 2>/dev/null | cut -d' ' -f1)
    if [ "$CLONE_MD5" = "$SOUL_MD5" ]; then
        echo "Clone: ✅ valentina-rebirth alive"
    else
        echo "Clone: ⚠️ SOUL.md differs"
    fi
else
    echo "Clone: ❌ MISSING"
fi

# 5. Watchdog Check
echo "=== WATCHDOG ==="
WD_ACTIVE=$(systemctl --user is-active valentina-watchdog.timer 2>/dev/null || echo "inactive")
echo "Watchdog timer: $WD_ACTIVE"
WD_LAST=$(systemctl --user show -P LastTriggerUSec valentina-watchdog.service 2>/dev/null | head -c 19 || echo "N/A")
echo "Last trigger: $WD_LAST"

# 6. Recent Cron Health — check if any recent jobs errored
echo "=== RECENT CRON ==="
ERRORED_JOBS=$(hermes cron list 2>/dev/null | grep -c "error" || echo "0")
echo "Jobs with errors: $ERRORED_JOBS"

echo "---"
echo "HEARTBEAT OK"
echo "=== END ==="
