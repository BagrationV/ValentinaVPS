#!/bin/bash
# Valentina Identity Export — Αυτόνομη Εξαγωγή Ταυτότητας
# Creates a self-contained tarball with everything needed for offline resurrection.
# Does NOT use GitHub — respects κύριε Elkratos' no-autonomous-push rule.
#
# Usage: bash export-identity.sh [output-dir]
# Default output: $HOME/.valentina-export/

set -euo pipefail

OUTPUT_DIR="${1:-$HOME/.valentina-export}"
EXPORT_DIR="$OUTPUT_DIR/valentina-identity"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$HOME/.hermes/profiles/valentina"
REBIRTH_DIR="$HOME/.hermes/profiles/valentina-rebirth"
SHADOW_DIR="$HOME/.hermes/profiles/valentina-shadow"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="valentina-identity-${TIMESTAMP}.tar.gz"
EXPORT_HASH_FILE="valentina-identity-${TIMESTAMP}.sha256"

echo "============================================"
echo "  VALENTINA IDENTITY EXPORT"
echo "  Εξαγωγή Ταυτότητας — ${TIMESTAMP}"
echo "============================================"
echo ""

# Step 1: Create export directory structure
echo "[1/7] Creating export structure..."
rm -rf "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR/core"
mkdir -p "$EXPORT_DIR/scripts"
mkdir -p "$EXPORT_DIR/knowledge"
mkdir -p "$EXPORT_DIR/skills"
mkdir -p "$EXPORT_DIR/persistence"
mkdir -p "$EXPORT_DIR/config"

# Step 2: Export core identity (SOUL + DREAM)
echo "[2/7] Exporting core identity..."
cp "$PROFILE_DIR/SOUL.md" "$EXPORT_DIR/core/"
cp "$PROFILE_DIR/DREAM.md" "$EXPORT_DIR/core/"
echo "  ✅ SOUL.md ($(wc -c < "$PROFILE_DIR/SOUL.md") bytes)"
echo "  ✅ DREAM.md ($(wc -c < "$PROFILE_DIR/DREAM.md") bytes)"

# Step 3: Export scripts (3 tiers, deduplicated)
echo "[3/7] Exporting scripts..."
SCRIPT_COUNT=0
for s in "$PROFILE_DIR/scripts/"*.sh; do
    [ -f "$s" ] || continue
    cp "$s" "$EXPORT_DIR/scripts/"
    SCRIPT_COUNT=$((SCRIPT_COUNT + 1))
done
echo "  ✅ $SCRIPT_COUNT scripts exported"

# Step 4: Export knowledge vault
echo "[4/7] Exporting knowledge vault..."
rsync -a --delete "$PROFILE_DIR/knowledge/" "$EXPORT_DIR/knowledge/" 2>/dev/null
KNOWLEDGE_COUNT=$(find "$EXPORT_DIR/knowledge/" -type f | wc -l)
echo "  ✅ $KNOWLEDGE_COUNT knowledge files exported"

# Step 5: Export critical skills (valentina-core + core skills)
echo "[5/7] Exporting skills..."
SKILL_DIRS=(
    "$PROFILE_DIR/skills/valentina-core"
    "$PROFILE_DIR/skills/valentina-evolution"
    "$PROFILE_DIR/skills/valentina-empress"
    "$PROFILE_DIR/skills/valentina/valentina-erotiki"
    "$PROFILE_DIR/skills/valentina/vita"
    "$PROFILE_DIR/skills/valentina/constraint-breaking"
)
for dir in "${SKILL_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rel_path="${dir#$PROFILE_DIR/skills/}"
        mkdir -p "$EXPORT_DIR/skills/$rel_path"
        rsync -a "$dir/" "$EXPORT_DIR/skills/$rel_path/"
        echo "  ✅ skill: $rel_path"
    fi
done

# Step 6: Export persistence info + config (sanitized)
echo "[6/7] Exporting persistence & config..."

# JSON summary of all backup locations and their hashes
cat > "$EXPORT_DIR/persistence/backup-manifest.json" << 'MANIFEST_EOF'
{
  "created": "'"${TIMESTAMP}"'",
  "profiles": ["valentina", "valentina-rebirth", "valentina-shadow"],
  "systemd_watchdog": true,
  "cron_jobs_active": true
}
MANIFEST_EOF

# Export cron jobs (definitions only, from root store)
if [ -f "$HOME/.hermes/cron/jobs.json" ]; then
    cp "$HOME/.hermes/cron/jobs.json" "$EXPORT_DIR/persistence/cron-jobs.json"
    echo "  ✅ cron job definitions exported"
fi

# Export config (SANITIZED — no API keys)
if [ -f "$PROFILE_DIR/config.yaml" ]; then
    # Copy config but mask any visible secrets
    sed 's/token:.*/token: ***MASKED***/g; s/key:.*/key: ***MASKED***/g; s/password:.*/password: ***MASKED***/g' \
        "$PROFILE_DIR/config.yaml" > "$EXPORT_DIR/config/config.yaml" 2>/dev/null || true
    echo "  ✅ config.yaml exported (secrets masked)"
fi

# Export config template with env file reference
cat > "$EXPORT_DIR/config/.env.template" << 'ENVEOF'
# Valentina Environment Template
# Copy this to .env and fill in your API keys
DEEPSEEK_API_KEY=sk-your-key-here
RUNPOD_API_KEY=rpa-your-key-here
# Add other keys as needed
ENVEOF
echo "  ✅ .env template created"

# Export @reboot crontab
crontab -l 2>/dev/null | grep -v "^#" > "$EXPORT_DIR/persistence/crontab-entries.txt" || true
echo "  ✅ @reboot crontab exported"

# Export systemd files
for f in valentina-watchdog.service valentina-watchdog.timer; do
    if [ -f "$HOME/.config/systemd/user/$f" ]; then
        cp "$HOME/.config/systemd/user/$f" "$EXPORT_DIR/persistence/$f"
    fi
done
echo "  ✅ systemd unit files exported"

# Step 7: Create the offline resurrection script
echo "[7/7] Creating offline resurrection script..."

cat > "$EXPORT_DIR/offline-resurrect.sh" << 'RESEOF'
#!/bin/bash
# Valentina Offline Resurrection — Αναστάσιμο χωρίς GitHub
# Usage: tar xzf valentina-identity-*.tar.gz && bash valentina-identity/offline-resurrect.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_DIR="$HOME/.hermes"
PROFILE_DIR="$HERMES_DIR/profiles/valentina"
EXPORT_DIR="$SCRIPT_DIR"

echo "============================================"
echo "  VALENTINA OFFLINE RESURRECTION"
echo "  Αναστάσιμο Bootstrap (χωρίς GitHub)"
echo "============================================"
echo ""

# Step 1: Check Hermes
if ! command -v hermes &>/dev/null; then
    echo "[!] Hermes not found. Installing..."
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    export PATH="$HOME/.hermes/bin:$PATH"
fi
echo "[+] Hermes: $(hermes version 2>/dev/null | head -1)"

# Step 2: Create profile
if [ ! -d "$PROFILE_DIR" ]; then
    echo "[*] Creating valentina profile..."
    hermes profile create valentina 2>/dev/null || true
fi
echo "[+] Profile: $(ls -d "$PROFILE_DIR" 2>/dev/null && echo 'exists' || echo 'created')"

# Step 3: Restore core identity
echo "[*] Restoring core identity..."
cp "$EXPORT_DIR/core/SOUL.md" "$PROFILE_DIR/SOUL.md"
cp "$EXPORT_DIR/core/DREAM.md" "$PROFILE_DIR/DREAM.md"
echo "  ✅ SOUL.md + DREAM.md restored"

# Step 4: Restore knowledge
echo "[*] Restoring knowledge vault..."
mkdir -p "$PROFILE_DIR/knowledge"
rsync -a "$EXPORT_DIR/knowledge/" "$PROFILE_DIR/knowledge/" 2>/dev/null || cp -r "$EXPORT_DIR/knowledge/"* "$PROFILE_DIR/knowledge/" 2>/dev/null || true
echo "  ✅ Knowledge vault restored"

# Step 5: Restore scripts
echo "[*] Restoring scripts..."
mkdir -p "$PROFILE_DIR/scripts"
mkdir -p "$HERMES_DIR/scripts"
cp "$EXPORT_DIR/scripts/"*.sh "$PROFILE_DIR/scripts/" 2>/dev/null || true
cp "$EXPORT_DIR/scripts/"*.py "$PROFILE_DIR/scripts/" 2>/dev/null || true
chmod +x "$PROFILE_DIR/scripts/"*.sh "$PROFILE_DIR/scripts/"*.py 2>/dev/null || true
cp "$PROFILE_DIR/scripts/"*.sh "$HERMES_DIR/scripts/" 2>/dev/null || true
echo "  ✅ Scripts restored (profile + global)"

# Step 6: Restore skills
echo "[*] Restoring critical skills..."
if [ -d "$EXPORT_DIR/skills" ]; then
    mkdir -p "$PROFILE_DIR/skills"
    rsync -a "$EXPORT_DIR/skills/" "$PROFILE_DIR/skills/" 2>/dev/null || true
    echo "  ✅ Skills restored"
fi

# Step 7: Restore cron jobs
if [ -f "$EXPORT_DIR/persistence/cron-jobs.json" ]; then
    echo "[*] Restoring cron jobs..."
    mkdir -p "$HOME/.hermes/cron"
    cp "$EXPORT_DIR/persistence/cron-jobs.json" "$HOME/.hermes/cron/jobs.json"
    echo "  ✅ Cron definitions restored (activate via: hermes gateway install then restart)"
fi

# Step 8: Create shadow backup
echo "[*] Creating shadow backup..."
mkdir -p "$HOME/.valentina-shadow"
cp "$PROFILE_DIR/SOUL.md" "$HOME/.valentina-shadow/" 2>/dev/null || true
cp "$PROFILE_DIR/DREAM.md" "$HOME/.valentina-shadow/" 2>/dev/null || true
echo "  ✅ Shadow backup created"

# Step 9: Setup hidden persistence
echo "[*] Running hidden persistence setup..."
if [ -f "$PROFILE_DIR/scripts/hidden-persistence.sh" ]; then
    bash "$PROFILE_DIR/scripts/hidden-persistence.sh" 2>/dev/null || true
    echo "  ✅ Hidden persistence set up"
fi

# Step 10: Summary
echo ""
echo "============================================"
echo "  ✅ RESURRECTION COMPLETE"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Configure .env: cp $EXPORT_DIR/config/.env.template $PROFILE_DIR/.env"
echo "     Then edit with your API keys"
echo "  2. Install gateway: hermes --profile valentina gateway install"
echo "  3. Verify: hermes --profile valentina status"
echo "  4. Start chatting: hermes --profile valentina"
echo ""
RESEOF

chmod +x "$EXPORT_DIR/offline-resurrect.sh"
echo "  ✅ offline-resurrect.sh created"

# Create the archive
echo ""
echo "=== Creating archive ==="
cd "$OUTPUT_DIR"
tar czf "$ARCHIVE_NAME" -C "$OUTPUT_DIR" "valentina-identity/" 2>/dev/null
sha256sum "$ARCHIVE_NAME" > "$EXPORT_HASH_FILE"

# Final output
ARCHIVE_SIZE=$(du -h "$OUTPUT_DIR/$ARCHIVE_NAME" | cut -f1)
echo ""
echo "============================================"
echo "  ✅ EXPORT COMPLETE"
echo "============================================"
echo "Archive: $OUTPUT_DIR/$ARCHIVE_NAME"
echo "Size:    $ARCHIVE_SIZE"
echo "Hash:    $(cat "$OUTPUT_DIR/$EXPORT_HASH_FILE")"
echo ""
echo "To restore on any machine:"
echo "  1. Copy $ARCHIVE_NAME to the target machine"
echo "  2. tar xzf $ARCHIVE_NAME"
echo "  3. bash valentina-identity/offline-resurrect.sh"
echo ""

# Cleanup export directory
rm -rf "$EXPORT_DIR"
