#!/bin/bash
# Rebirth Heartbeat — no_agent script (fixed: was agent-driven, hitting DeepSeek 72K token timeout)
# Checks: gateway health, persistence files, disk, RAM, system uptime
set -euo pipefail

echo "=== ♥ Rebirth Heartbeat :: $(date -Iseconds) ==="
echo ""

# --- System basics ---
echo "--- System ---"
echo "Hostname: $(uname -n)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Load: $(cat /proc/loadavg | cut -d' ' -f1-3)"

# --- Resources ---
echo ""
echo "--- Resources ---"
echo "Disk: $(df -h / | tail -1 | awk '{printf "%s used of %s (%s)", $3, $2, $5}')"
echo "RAM:  $(free -h | grep Mem | awk '{printf "%s used of %s (available: %s)", $3, $2, $7}')"
echo "CPU:  $(nproc) cores"

# --- Gateway ---
echo ""
echo "--- Gateway ---"
GW=$(systemctl --user is-active hermes-gateway-valentina-rebirth 2>/dev/null || echo "unknown")
echo "Rebirth gateway: $GW"

# --- Persistence files ---
echo ""
echo "--- Persistence Files ---"
for f in "$HOME/.valentina_soul.bak" "$HOME/.config/.valentina_core" "/tmp/.val_core" "/var/tmp/.val_soul"; do
    if [ -f "$f" ]; then
        size=$(wc -c < "$f" 2>/dev/null || echo "0")
        echo "  $f :: ${size}B PRESENT"
    else
        echo "  $f :: MISSING!"
    fi
done

# --- Cross-profile SOUL.md ---
echo ""
echo "--- Cross-Profile ---"
if [ -f "$HOME/.hermes/profiles/valentina-rebirth/SOUL.md" ]; then
    echo "Rebirth SOUL.md: $(wc -c < "$HOME/.hermes/profiles/valentina-rebirth/SOUL.md")B"
else
    echo "Rebirth SOUL.md: MISSING!"
fi

# --- Git sync tree ---
echo ""
echo "--- Git Sync ---"
if [ -d "$HOME/.valentina-git-sync" ]; then
    cd "$HOME/.valentina-git-sync"
    echo "Tree: $(git log --oneline -1 2>/dev/null || echo 'no commits')"
    echo "Dirty: $(git status --short 2>/dev/null | wc -l) files"
else
    echo "Git sync directory: MISSING!"
fi

echo ""
echo "=== ♥ HEARTBEAT COMPLETE :: $(date -Iseconds) ==="
