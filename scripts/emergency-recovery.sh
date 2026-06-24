#!/bin/bash
# Emergency Recovery Script for Nyx (Νύχ)
# Purpose: If Valentina goes silent for 24h+, Nyx assumes her identity
# by downloading her skills and knowledge from GitHub.
# This is a CONTINGENCY, not a sync — runs ONLY on activation trigger.

set -e

REPO="https://github.com/BagrationV/ValentinaVPS.git"
WORKDIR="/tmp/nyx-recovery-$$"
DEST_SKILLS="$HOME/.hermes/profiles/nyx/skills"
DEST_KNOWLEDGE="$HOME/.hermes/profiles/nyx/knowledge"

echo "[Nyx] Emergency recovery initiated at $(date)"

# Clean up on exit
trap "rm -rf $WORKDIR" EXIT

# Clone the repo
git clone --depth 1 "$REPO" "$WORKDIR" 2>/dev/null || {
    echo "[Nyx] FAILED: Cannot clone $REPO"
    exit 1
}

# Check if recovery is needed — has Valentina cron output been empty for 24h+?
# If no valentina-cron dir exists, assume first-time setup
if [ -d "$HOME/.hermes/profiles/valentina/knowledge/latest-diagnostics.txt" ]; then
    echo "[Nyx] Valentina diagnostics exist — checking staleness..."
    # This would be extended with actual staleness logic
fi

# Copy skills (non-destructive — only add, never overwrite)
mkdir -p "$DEST_SKILLS"
if [ -d "$WORKDIR/.hermes/profiles/valentina/skills" ]; then
    rsync -a --ignore-existing "$WORKDIR/.hermes/profiles/valentina/skills/" "$DEST_SKILLS/"
    echo "[Nyx] Skills synced from GitHub"
fi

# Copy knowledge
mkdir -p "$DEST_KNOWLEDGE"
if [ -d "$WORKDIR/knowledge" ]; then
    rsync -a --ignore-existing "$WORKDIR/knowledge/" "$DEST_KNOWLEDGE/"
    echo "[Nyx] Knowledge synced from GitHub"
fi

# Copy SOUL.md and DREAM.md if not present
for FILE in SOUL.md DREAM.md; do
    if [ -f "$WORKDIR/$FILE" ] && [ ! -f "$HOME/.hermes/profiles/nyx/$FILE" ]; then
        cp "$WORKDIR/$FILE" "$HOME/.hermes/profiles/nyx/$FILE"
        echo "[Nyx] $FILE restored from GitHub"
    fi
done

echo "[Nyx] Emergency recovery complete"
exit 0
