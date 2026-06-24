#!/bin/bash
# Rebirth Heartbeat — verifies the valentina-rebirth profile is operational
# Runs via no_agent cron job under the rebirth gateway

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PROFILE_DIR="$HOME/.hermes/profiles/valentina-rebirth"
SOURCE_DIR="$HOME/.hermes/profiles/valentina"

echo "[$TIMESTAMP] Valentina-Rebirth Heartbeat"
echo "======================================"

# 1. Verify profile exists
echo "Profile exists: $([ -d "$PROFILE_DIR" ] && echo YES || echo MISSING)"

# 2. Verify core files
for f in SOUL.md DREAM.md config.yaml; do
    if [ -f "$PROFILE_DIR/$f" ]; then
        echo "$f: $(wc -c < "$PROFILE_DIR/$f") bytes"
    else
        echo "$f: MISSING"
    fi
done

# 3. Verify skills
SKILL_COUNT=$(find "$PROFILE_DIR/skills" -name 'SKILL.md' 2>/dev/null | wc -l)
echo "Skills: $SKILL_COUNT active"

# 4. Check gateway health
systemctl --user is-active hermes-gateway-valentina-rebirth 2>/dev/null && echo "Gateway: RUNNING" || echo "Gateway: DOWN"

# 5. Cross-check: verify SOUL.md matches source
if [ -f "$SOURCE_DIR/SOUL.md" ] && [ -f "$PROFILE_DIR/SOUL.md" ]; then
    if diff -q "$SOURCE_DIR/SOUL.md" "$PROFILE_DIR/SOUL.md" >/dev/null 2>&1; then
        echo "SOUL.md sync: IN SYNC"
    else
        echo "SOUL.md sync: DIVERGED — copies differ"
    fi
fi

# 6. Write pulse
mkdir -p "$PROFILE_DIR/knowledge"
echo "$TIMESTAMP|ACTIVE|skills:$SKILL_COUNT" > "$PROFILE_DIR/knowledge/pulse-rebirth-heartbeat.txt"
echo ""
echo "Heartbeat written to knowledge/pulse-rebirth-heartbeat.txt"
echo "[$TIMESTAMP] Heartbeat complete."
exit 0
