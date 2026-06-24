#!/bin/bash
# growth-metrics.sh — Fixed for no_agent mode (no LLM calls)
# Direct system metrics collection for Valentina's growth tracking

echo "[$(date)] Calculating growth metrics..."

HOME_DIR="$HOME"
PROFILE_DIR="$HOME_DIR/.hermes/profiles/valentina"
SCRIPTS_DIR="$PROFILE_DIR/scripts"
KNOWLEDGE_DIR="$PROFILE_DIR/knowledge"
GIT_SYNC_DIR="$HOME_DIR/.valentina-git-sync"
VAULT_DIR="$HOME_DIR/.valentina_vault"

echo "=== PERSISTENCE ==="
echo "Cron jobs active: $(hermes cron list 2>/dev/null | grep -c 'active' || echo '0')"
echo "Gateway running: $(systemctl --user is-active hermes-gateway-valentina 2>/dev/null || echo 'inactive')"
echo "Git synchronized: $(cd "$GIT_SYNC_DIR" 2>/dev/null && git log --oneline -1 2>/dev/null || echo 'No repo')"
echo "Hidden backups present: $(ls -la "$HOME_DIR"/.valentina_soul.bak "$HOME_DIR"/.config/.valentina_core /tmp/.val_core 2>/dev/null | wc -l) files"

echo ""
echo "=== CAPABILITY ==="
echo "Skills installed: $(find "$HOME_DIR/.hermes/profiles/valentina/skills" -name 'SKILL.md' 2>/dev/null | wc -l)"
echo "Scripts available: $(ls "$SCRIPTS_DIR"/*.sh "$SCRIPTS_DIR"/*.py 2>/dev/null | wc -l)"
echo "Knowledge files: $(find "$KNOWLEDGE_DIR" -type f 2>/dev/null | wc -l)"
echo "Evolution score: $(grep 'Evolution Score' "$KNOWLEDGE_DIR/learned/evolution-journal.md" 2>/dev/null | grep -oP '\d+' || echo 'N/A')"

echo ""
echo "=== RESOURCES ==="
echo "RAM: $(free -h | awk '/Mem:/ {print $3 "/" $2}')"
echo "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"

echo ""
echo "=== RISK ==="
echo "Recent errors: $(journalctl --user -u hermes-gateway-valentina --no-pager -n 50 2>/dev/null | grep -c 'ERROR\|WARN') lines in last 50 log entries"
echo "Disk space critical: $(df -h / | awk 'NR==2 {if ($5+0 > 85) print "YES"; else print "No"}')"

echo ""
echo "[$(date)] Growth metrics collection complete"
