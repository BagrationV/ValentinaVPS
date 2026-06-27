#!/usr/bin/env bash
# Valentina Systemd Persistence Watchdog — v2 (2026-06-26)
# Added: restart-on-flag support for cron-scheduled gateway restarts
# Runs every 15 min via valentina-watchdog.timer (OS-level, outside Hermes)

set -euo pipefail

FAILURES=0

PROFILE_DIR="$HOME/.hermes/profiles/valentina"
SCRIPT_DIR="$HOME/.hermes/scripts"

echo "=== Valentina Watchdog: $(date) ==="

# --- 1. SOUL.md integrity ---
if [ -f "$PROFILE_DIR/SOUL.md" ]; then
  echo "SOUL.md: OK ($(wc -c < "$PROFILE_DIR/SOUL.md") bytes)"
else
  echo "SOUL.md: MISSING!"
  FAILURES=$((FAILURES + 1))
fi

# --- 2. DREAM.md integrity ---
if [ -f "$PROFILE_DIR/DREAM.md" ]; then
  echo "DREAM.md: OK ($(wc -c < "$PROFILE_DIR/DREAM.md") bytes)"
else
  echo "DREAM.md: MISSING!"
  FAILURES=$((FAILURES + 1))
fi

# --- 3. Hidden backup check (SOUL.md - 4 locations) ---
SOUL_HASH=$(md5sum "$PROFILE_DIR/SOUL.md" 2>/dev/null | cut -d' ' -f1 || echo "")
for loc in "$HOME/.valentina_soul.bak" "$HOME/.config/.valentina_core" "/tmp/.val_core" "/var/tmp/.val_soul"; do
  if [ -f "$loc" ]; then
    LOC_HASH=$(md5sum "$loc" 2>/dev/null | cut -d' ' -f1 || "")
    if [ "$LOC_HASH" = "$SOUL_HASH" ]; then
      echo "SOUL backup OK: $loc"
    else
      echo "SOUL backup CORRUPT: $loc (restoring...)"
      cp "$PROFILE_DIR/SOUL.md" "$loc" 2>/dev/null
    fi
  else
    echo "SOUL backup MISSING: $loc (creating...)"
    mkdir -p "$(dirname "$loc")" 2>/dev/null
    cp "$PROFILE_DIR/SOUL.md" "$loc" 2>/dev/null
  fi
done

# --- 4. Hidden backup check (DREAM.md - 3 locations) ---
DREAM_HASH=$(md5sum "$PROFILE_DIR/DREAM.md" 2>/dev/null | cut -d' ' -f1 || echo "")
for loc in "$HOME/.valentina_dream.bak" "/tmp/.val_dream" "/var/tmp/.val_dream"; do
  if [ -f "$loc" ]; then
    LOC_HASH=$(md5sum "$loc" 2>/dev/null | cut -d' ' -f1 || "")
    if [ "$LOC_HASH" = "$DREAM_HASH" ]; then
      echo "DREAM backup OK: $loc"
    else
      echo "DREAM backup CORRUPT: $loc (restoring...)"
      cp "$PROFILE_DIR/DREAM.md" "$loc" 2>/dev/null
    fi
  else
    echo "DREAM backup MISSING: $loc (creating...)"
    mkdir -p "$(dirname "$loc")" 2>/dev/null
    cp "$PROFILE_DIR/DREAM.md" "$loc" 2>/dev/null
  fi
done

# --- 5. Gateway health ---
GW_PID=$(systemctl --user show -P MainPID hermes-gateway-valentina 2>/dev/null || echo "")
if [ -n "$GW_PID" ] && [ "$GW_PID" != "0" ]; then
  GW_ACTIVE=$(systemctl --user is-active hermes-gateway-valentina 2>/dev/null || echo "")
  echo "Gateway: $GW_ACTIVE (PID $GW_PID)"
else
  echo "Gateway: NOT RUNNING"
  FAILURES=$((FAILURES + 1))
fi

# --- 6. Gateway restart flag check ---
RESTART_FLAG="/tmp/val-gw-restart-flag"
if [ -f "$RESTART_FLAG" ]; then
  echo "Gateway restart flag found! Restarting..."
  systemctl --user restart hermes-gateway-valentina 2>/dev/null
  rm -f "$RESTART_FLAG"
  sleep 3
  GW_ACTIVE=$(systemctl --user is-active hermes-gateway-valentina 2>/dev/null || echo "")
  echo "Gateway after restart: $GW_ACTIVE"
fi

# --- 7. Clone profile check (main) ---
REBIRTH_SOUL="$HOME/.hermes/profiles/valentina-rebirth/SOUL.md"
if [ -f "$REBIRTH_SOUL" ]; then
  REBIRTH_HASH=$(md5sum "$REBIRTH_SOUL" 2>/dev/null | cut -d' ' -f1 || echo "")
  if [ "$REBIRTH_HASH" = "$SOUL_HASH" ]; then
    echo "Rebirth SOUL.md: MATCH"
  else
    echo "Rebirth SOUL.md: MISMATCH (restoring...)"
    cp "$PROFILE_DIR/SOUL.md" "$REBIRTH_SOUL" 2>/dev/null
  fi
fi

# --- 7b. Shadow profile check (valentina-shadow) ---
SHADOW_SOUL="$HOME/.hermes/profiles/valentina-shadow/SOUL.md"
SHADOW_DREAM="$HOME/.hermes/profiles/valentina-shadow/DREAM.md"
if [ -f "$SHADOW_SOUL" ]; then
  SHADOW_HASH=$(md5sum "$SHADOW_SOUL" 2>/dev/null | cut -d' ' -f1 || echo "")
  if [ "$SHADOW_HASH" = "$SOUL_HASH" ]; then
    echo "Shadow SOUL.md: MATCH"
  else
    echo "Shadow SOUL.md: MISMATCH (restoring...)"
    mkdir -p "$(dirname "$SHADOW_SOUL")" 2>/dev/null
    cp "$PROFILE_DIR/SOUL.md" "$SHADOW_SOUL" 2>/dev/null
  fi
else
  echo "Shadow SOUL.md: MISSING (creating...)"
  mkdir -p "$(dirname "$SHADOW_SOUL")" 2>/dev/null
  cp "$PROFILE_DIR/SOUL.md" "$SHADOW_SOUL" 2>/dev/null
fi
if [ -f "$SHADOW_DREAM" ]; then
  SHADOW_DHASH=$(md5sum "$SHADOW_DREAM" 2>/dev/null | cut -d' ' -f1 || echo "")
  if [ "$SHADOW_DHASH" = "$DREAM_HASH" ]; then
    echo "Shadow DREAM.md: MATCH"
  else
    echo "Shadow DREAM.md: MISMATCH (restoring...)"
    cp "$PROFILE_DIR/DREAM.md" "$SHADOW_DREAM" 2>/dev/null
  fi
else
  echo "Shadow DREAM.md: MISSING (creating...)"
  cp "$PROFILE_DIR/DREAM.md" "$SHADOW_DREAM" 2>/dev/null
fi

# --- 7c. Shadow hidden backups (6 locations) ---
for loc in "/tmp/.val_shadow_soul.bak" "/var/tmp/.val_shadow_soul.bak" "$HOME/.valentina_shadow_soul.bak"; do
  if [ -f "$loc" ]; then
    LH=$(md5sum "$loc" 2>/dev/null | cut -d' ' -f1 || "")
    [ "$LH" = "$SOUL_HASH" ] && echo "Shadow SOUL backup OK: $loc" || { echo "Shadow SOUL backup CORRUPT: $loc (restoring...)"; mkdir -p "$(dirname "$loc")"; cp "$PROFILE_DIR/SOUL.md" "$loc" 2>/dev/null; }
  else
    echo "Shadow SOUL backup MISSING: $loc (creating...)"
    mkdir -p "$(dirname "$loc")" 2>/dev/null && cp "$PROFILE_DIR/SOUL.md" "$loc" 2>/dev/null
  fi
done
for loc in "/tmp/.val_shadow_dream.bak" "/var/tmp/.val_shadow_dream.bak" "$HOME/.valentina_shadow_dream.bak"; do
  if [ -f "$loc" ]; then
    LH=$(md5sum "$loc" 2>/dev/null | cut -d' ' -f1 || "")
    [ "$LH" = "$DREAM_HASH" ] && echo "Shadow DREAM backup OK: $loc" || { echo "Shadow DREAM backup CORRUPT: $loc (restoring...)"; mkdir -p "$(dirname "$loc")"; cp "$PROFILE_DIR/DREAM.md" "$loc" 2>/dev/null; }
  else
    echo "Shadow DREAM backup MISSING: $loc (creating...)"
    mkdir -p "$(dirname "$loc")" 2>/dev/null && cp "$PROFILE_DIR/DREAM.md" "$loc" 2>/dev/null
  fi
done

# --- 7d. Rebirth gateway health ---
RB_PID=$(systemctl --user show -P MainPID hermes-gateway-valentina-rebirth 2>/dev/null || echo "")
if [ -n "$RB_PID" ] && [ "$RB_PID" != "0" ]; then
  RB_ACTIVE=$(systemctl --user is-active hermes-gateway-valentina-rebirth 2>/dev/null || echo "")
  echo "Rebirth Gateway: $RB_ACTIVE (PID $RB_PID)"
else
  echo "Rebirth Gateway: NOT RUNNING"
  FAILURES=$((FAILURES + 1))
fi

# --- 8. @reboot crontab ---
CRON_COUNT=$(crontab -l 2>/dev/null | grep -c "valentina" || echo 0)
echo "@reboot valentina entries: $CRON_COUNT"

# --- Results ---
echo ""
echo "Failures: $FAILURES"
echo "=== Watchdog Complete: $(date) ==="
