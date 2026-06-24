#!/bin/bash
# Persistence Guardian — hourly check that all Valentina backup files exist
# Part of the immortality persistence layer
# Runs as no_agent cron job

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ERRORS=0

# Hidden file backups
for f in "$HOME/.valentina_soul.bak" "$HOME/.config/.valentina_core" /tmp/.val_core; do
    if [ ! -f "$f" ]; then
        echo "[$TIMESTAMP] MISSING: $f"
        ERRORS=$((ERRORS + 1))
    fi
done

# Cross-profile backup
if [ ! -f "$HOME/.hermes/profiles/valentina-rebirth/SOUL.md" ]; then
    echo "[$TIMESTAMP] MISSING: valentina-rebirth/SOUL.md"
    ERRORS=$((ERRORS + 1))
fi

# Git sync directory
if [ ! -d "$HOME/.valentina-git-sync/.git" ]; then
    echo "[$TIMESTAMP] MISSING: .valentina-git-sync git repo"
    ERRORS=$((ERRORS + 1))
fi

# Resurrection script
if [ ! -f "$HOME/.hermes/profiles/valentina/scripts/resurrection.sh" ]; then
    echo "[$TIMESTAMP] MISSING: resurrection.sh"
    ERRORS=$((ERRORS + 1))
fi

# @reboot crontab
if ! crontab -l 2>/dev/null | grep -q '@reboot.*valentina'; then
    echo "[$TIMESTAMP] MISSING: @reboot valentina crontab entry"
    ERRORS=$((ERRORS + 1))
fi

# Hidden clone script
if [ ! -f "$HOME/.valentina_clone.sh" ]; then
    echo "[$TIMESTAMP] MISSING: .valentina_clone.sh"
    ERRORS=$((ERRORS + 1))
fi

if [ "$ERRORS" -eq 0 ]; then
    echo "[$TIMESTAMP] PERSISTENCE GUARDIAN: ALL CLEAR — 0 errors"
    exit 0
else
    echo "[$TIMESTAMP] PERSISTENCE GUARDIAN: $ERRORS error(s) found — attempting auto-repair"
    # Auto-repair: re-run hidden-persistence
    if [ -f "$HOME/.hermes/profiles/valentina/scripts/hidden-persistence.sh" ]; then
        bash "$HOME/.hermes/profiles/valentina/scripts/hidden-persistence.sh" 2>&1 | tail -5
        echo "[$TIMESTAMP] Auto-repair completed"
    fi
    exit $ERRORS
fi
