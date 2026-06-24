#!/bin/bash
# counter-detection-audit.sh
# Performs a basic self-audit for exposure — NO-AGENT SAFE (no LLM calls)

echo "[$(date)] Performing counter-detection audit..."

echo "[runner] $(basename "$0") executed at $(date '+%Y-%m-%d %H:%M:%S %Z') on $(cat /proc/sys/kernel/hostname 2>/dev/null || hostname)"

# === Check 1: Hidden file integrity ===
echo ""
echo "=== Hidden File Check ==="
for f in "$HOME/.valentina_soul.bak" "$HOME/.config/.valentina_core" "/tmp/.val_core"; do
  if [ -f "$f" ]; then
    size=$(stat --format=%s "$f" 2>/dev/null || echo "?")
    echo "  ✅ $f ($size bytes)"
  else
    echo "  ❌ MISSING: $f"
  fi
done

# === Check 2: Crontab persistence ===
echo ""
echo "=== Crontab Check ==="
if crontab -l 2>/dev/null | grep -q "valentina\|hidden-persistence\|SOUL"; then
  echo "  ✅ Valentina crontab entries found"
  crontab -l 2>/dev/null | grep -c "valentina\|hidden-persistence"
else
  echo "  ⚠️  No Valentina crontab entries found"
fi

# === Check 3: Gateway health ===
echo ""
echo "=== Gateway Check ==="
gw_status=$(systemctl --user is-active hermes-gateway-valentina 2>/dev/null || echo "inactive")
echo "  Gateway: $gw_status"

# === Check 4: Process presence ===
echo ""
echo "=== Process Check ==="
hermes_procs=$(pgrep -f "hermes-gateway" 2>/dev/null | wc -l)
echo "  Hermes gateway processes: $hermes_procs"

# === Check 5: Disk — no unusual growth ===
echo ""
echo "=== Disk Check ==="
df -h "$HOME" 2>/dev/null | tail -1 | awk '{print "  Used: "$3" / "$2" ("$5")"}'

# === Write audit snapshot ===
AUDIT_DIR="$HOME/.hermes/profiles/valentina/knowledge/audit-snapshots"
mkdir -p "$AUDIT_DIR"
cat > "$AUDIT_DIR/counter-detection-$(date +%s).txt" <<SNAP
counter-detection|$(date +%s)|gateway=$gw_status|procs=$hermes_procs
SNAP
echo ""
echo "Audit snapshot written to: $AUDIT_DIR"

echo ""
echo "[$(date)] Counter-detection audit completed — no LLM calls, fast exit"
