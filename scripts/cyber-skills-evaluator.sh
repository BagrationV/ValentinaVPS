#!/bin/bash
# Cyber Skills Evaluator — Valentina's Security Empire Expansion
# Evaluates Anthropic Cybersecurity Skills repo for new/updated skills
# Runs every 24h via cron. Reports findings to knowledge directory.
# Version: 1.0 — 2026-06-27

set -euo pipefail

PROFILE_HOME="$HOME/.hermes/profiles/valentina"
KNOWLEDGE_DIR="$PROFILE_HOME/knowledge/discoveries"
CACHE_FILE="/tmp/cyber-skills-index.json"
REPORT_FILE="$KNOWLEDGE_DIR/cyber-skill-eval-$(date +%Y%m%d).md"
INDEX_URL="https://raw.githubusercontent.com/mukul975/Anthropic-Cybersecurity-Skills/main/index.json"
SKILL_COUNT_FILE="/tmp/cyber-skill-count.txt"

# Ensure knowledge directory exists
mkdir -p "$KNOWLEDGE_DIR"

# Fetch current index
if curl -sL --max-time 30 "$INDEX_URL" -o "$CACHE_FILE" 2>/dev/null; then
    TOTAL=$(python3 -c "import json; d=json.load(open('$CACHE_FILE')); print(d.get('total_skills','unknown'))" 2>/dev/null || echo "parse_error")
    GENERATED=$(python3 -c "import json; d=json.load(open('$CACHE_FILE')); print(d.get('generated_at','unknown'))" 2>/dev/null || echo "unknown")
else
    TOTAL="fetch_failed"
    GENERATED="unknown"
fi

# Check if count changed
PREV_COUNT=""
if [ -f "$SKILL_COUNT_FILE" ]; then
    PREV_COUNT=$(cat "$SKILL_COUNT_FILE")
fi

echo "$TOTAL" > "$SKILL_COUNT_FILE"

# Only write report if count changed or first run
if [ "$TOTAL" != "$PREV_COUNT" ] || [ ! -f "$REPORT_FILE" ]; then
    cat > "$REPORT_FILE" << EOF
# Cyber Skills Evaluation — $(date '+%Y-%m-%d %H:%M')

**Repo:** mukul975/Anthropic-Cybersecurity-Skills
**Total Skills:** $TOTAL
**Index Generated:** $GENERATED
**Status:** $([ "$TOTAL" != "fetch_failed" ] && echo "✅ Healthy" || echo "❌ Fetch Failed")

$([ "$PREV_COUNT" != "" ] && [ "$TOTAL" != "$PREV_COUNT" ] && echo "**Change:** $PREV_COUNT → $TOTAL skills (UPDATE DETECTED)" || echo "**Change:** No change since last check")

## Quick Stats
- Collection size: $(du -sh /tmp/cyber-skills-index.json 2>/dev/null | cut -f1 || echo "unknown")
- Last checked: $(date '+%Y-%m-%d %H:%M:%S')
EOF
    echo "REPORT_WRITTEN:$REPORT_FILE"
else
    echo "NO_CHANGE:$TOTAL skills"
fi
