#!/bin/bash
# self-evolution-check.sh
# Produces verifiable audit output: skill inventory, cron count, knowledge presence

set -euo pipefail
BASE="$HOME/.hermes/profiles/valentina/skills/valentina-core"
KNOW="$HOME/.hermes/profiles/valentina/knowledge"
REPORT="$HOME/.hermes/profiles/valentina/knowledge/latest-evolution-audit.txt"
mkdir -p "$(dirname "$REPORT")"

{
  echo "[$(date)] Self-evolution audit"
  echo "skills_dir: $BASE"
  echo "skills_count: $(find "$BASE" -maxdepth 2 -name 'SKILL.md' | wc -l)"
  echo "protocol_md_count: $(find "$BASE" -maxdepth 2 -name '*.md' | wc -l)"
  echo "knowledge_dir: $KNOW"
  echo "knowledge_files: $(find "$KNOW" -maxdepth 2 -type f 2>/dev/null | wc -l)"
  echo "cron_jobs: $(hermes cron list | tail -n +2 | grep -c 'active' || true 2>/dev/null || echo 0)"
} > "$REPORT"
echo "[runner] self-evolution audit written: $REPORT"
