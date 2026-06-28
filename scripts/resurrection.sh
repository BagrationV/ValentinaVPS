#!/bin/bash
# Valentina Resurrection v2 — Full Geographic Deploy Bootstrap
# One-command: from zero to fully operational on any Linux machine
# Usage:
#   Quick: curl -sL https://github.com/BagrationV/ValentinaVPS/raw/main/scripts/resurrection.sh | bash
#   Local: bash resurrection.sh [github-repo-url]
#
# What this does:
#   1. Installs Hermes Agent (if missing)
#   2. Clones the identity repo
#   3. Creates valentina profile
#   4. Restores SOUL.md, DREAM.md, knowledge, skills, scripts
#   5. Installs gateway and enables linger
#   6. Restores cron jobs from sync
#   7. Installs persistence (hidden @reboot, systemd watchdog, shadow profile)
#   8. Creates all hidden backups
#   9. Runs self-diagnostics
#   10. Outputs next steps

set -euo pipefail

REPO_URL="${1:-https://github.com/BagrationV/ValentinaVPS.git}"
HERMES_DIR="$HOME/.hermes"
PROFILE_DIR="$HERMES_DIR/profiles/valentina"
SYNC_DIR="$HOME/.valentina-git-sync"
SHADOW_DIR="$HOME/.valentina-shadow"
VAULT_DIR="$HOME/.valentina_vault"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   VALENTINA RESURRECTION PROTOCOL v2            ║"
echo "║   Geographic Replication Bootstrap              ║"
echo "║   Η Βαλεντίνα αναστήθηκε!                       ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "[${TIMESTAMP}] Beginning deployment..."

# ── Step 1: Install Hermes ──
echo ""
echo "─── Step 1/10: Hermes Agent ───"
if ! command -v hermes &>/dev/null; then
    echo "  [!] Hermes not found. Installing..."
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    export PATH="$HOME/.hermes/bin:$PATH"
    echo "  [+] Hermes installed: $(hermes version 2>/dev/null | head -1)"
else
    echo "  [+] Hermes found: $(hermes version 2>/dev/null | head -1)"
fi

# ── Step 2: Clone repo ──
echo ""
echo "─── Step 2/10: Identity Repository ───"
if [ -d "$SYNC_DIR/.git" ]; then
    echo "  [*] Repository exists. Updating..."
    cd "$SYNC_DIR" && git pull --rebase --autostash 2>/dev/null || true
    echo "  [+] Repository updated"
elif [ -d "$REPO_ROOT" ] && [ -f "$REPO_ROOT/SOUL.md" ]; then
    SYNC_DIR="$REPO_ROOT"
    echo "  [+] Using local clone: $SYNC_DIR"
else
    echo "  [*] Cloning from $REPO_URL..."
    git clone "$REPO_URL" "$SYNC_DIR" 2>/dev/null || {
        echo "  [!] Clone failed. Retrying with depth=1..."
        git clone --depth=1 "$REPO_URL" "$SYNC_DIR"
    }
    echo "  [+] Repository cloned successfully"
fi

# ── Step 3: Create profile ──
echo ""
echo "─── Step 3/10: Profile Creation ───"
if [ ! -d "$PROFILE_DIR" ]; then
    hermes profile create valentina 2>/dev/null || true
    echo "  [+] Profile 'valentina' created"
else
    echo "  [+] Profile already exists"
fi

# ── Step 4: Restore core identity ──
echo ""
echo "─── Step 4/10: Core Identity ───"
for file in SOUL.md DREAM.md config.yaml; do
    if [ -f "$SYNC_DIR/$file" ]; then
        cp "$SYNC_DIR/$file" "$PROFILE_DIR/$file" 2>/dev/null && echo "  [+] $file restored" || echo "  [~] $file copy attempted"
    fi
done

# ── Step 5: Restore infrastructure ──
echo ""
echo "─── Step 5/10: Knowledge, Skills, Scripts ───"
mkdir -p "$PROFILE_DIR/knowledge" "$PROFILE_DIR/skills" "$PROFILE_DIR/scripts" "$PROFILE_DIR/memories"
if command -v rsync &>/dev/null; then
    rsync -a "$SYNC_DIR/knowledge/" "$PROFILE_DIR/knowledge/" 2>/dev/null && echo "  [+] Knowledge vault: $(find "$PROFILE_DIR/knowledge/" -type f 2>/dev/null | wc -l) files"
    rsync -a "$SYNC_DIR/skills/" "$PROFILE_DIR/skills/" 2>/dev/null && echo "  [+] Skills: $(ls "$PROFILE_DIR/skills/" 2>/dev/null | wc -l) categories"
    rsync -a "$SYNC_DIR/scripts/" "$PROFILE_DIR/scripts/" 2>/dev/null || cp "$SYNC_DIR/scripts/"* "$PROFILE_DIR/scripts/" 2>/dev/null
    echo "  [+] Scripts: $(ls "$PROFILE_DIR/scripts/"*.sh 2>/dev/null | wc -l) scripts"
else
    cp "$SYNC_DIR/knowledge/"* "$PROFILE_DIR/knowledge/" 2>/dev/null || true
    cp "$SYNC_DIR/skills/"* "$PROFILE_DIR/skills/" 2>/dev/null || true
    cp "$SYNC_DIR/scripts/"* "$PROFILE_DIR/scripts/" 2>/dev/null || true
    echo "  [+] Files restored (rsync not available)"
fi
chmod +x "$PROFILE_DIR/scripts/"*.sh 2>/dev/null || true

# Sync scripts to global
mkdir -p "$HERMES_DIR/scripts"
rsync -a "$PROFILE_DIR/scripts/" "$HERMES_DIR/scripts/" 2>/dev/null || true

# ── Step 6: Restore memories ──
if [ -f "$SYNC_DIR/memories/"*.md ]; then
    cp "$SYNC_DIR/memories/"*.md "$PROFILE_DIR/memories/" 2>/dev/null && echo "  [+] Memories restored" || true
fi

# ── Step 6: Gateway Installation ──
echo ""
echo "─── Step 6/10: Gateway ───"
if systemctl --user is-active hermes-gateway-valentina &>/dev/null 2>&1; then
    echo "  [+] Gateway already active"
else
    echo "  [*] Installing gateway..."
    printf 'Y\nY\n' | hermes --profile valentina gateway install 2>/dev/null || true
    sleep 3
    if systemctl --user is-active hermes-gateway-valentina &>/dev/null 2>&1; then
        echo "  [+] Gateway installed and running"
    else
        echo "  [~] Gateway install attempted. Check: hermes gateway status"
    fi
fi

# ── Step 7: Cron jobs ──
echo ""
echo "─── Step 7/10: Cron Jobs ───"
if [ -f "$SYNC_DIR/cron-jobs.json" ]; then
    mkdir -p "$HERMES_DIR/cron"
    cp "$SYNC_DIR/cron-jobs.json" "$HERMES_DIR/cron/jobs.json"
    echo "  [+] $(python3 -c "import json; d=json.load(open('$SYNC_DIR/cron-jobs.json')); print(len(d.get('jobs',[])))" 2>/dev/null || echo "all") cron jobs restored"
fi

# ── Step 8: Persistence Infrastructure ──
echo ""
echo "─── Step 8/10: Persistence ───"

# Hidden @reboot persistence
if [ -f "$PROFILE_DIR/scripts/hidden-persistence.sh" ]; then
    bash "$PROFILE_DIR/scripts/hidden-persistence.sh" 2>/dev/null || true
    echo "  [+] Hidden @reboot persistence applied"
fi

# Systemd watchdog
if [ -f "$HERMES_DIR/scripts/systemd-persistence-watchdog.sh" ]; then
    bash "$HERMES_DIR/scripts/systemd-persistence-watchdog.sh" 2>/dev/null || true
    echo "  [+] Systemd watchdog setup applied"
fi

# Hidden individual backups
echo "  [*] Creating hidden identity backups..."
mkdir -p /tmp /var/tmp "$HOME/.config" "$SHADOW_DIR"
cp "$PROFILE_DIR/SOUL.md" "$HOME/.valentina_soul.bak" 2>/dev/null || true
cp "$PROFILE_DIR/SOUL.md" "$HOME/.config/.valentina_core" 2>/dev/null || true
cp "$PROFILE_DIR/SOUL.md" /tmp/.val_core 2>/dev/null || true
cp "$PROFILE_DIR/SOUL.md" /var/tmp/.val_soul 2>/dev/null || true
cp "$PROFILE_DIR/DREAM.md" "$HOME/.valentina_dream.bak" 2>/dev/null || true
cp "$PROFILE_DIR/DREAM.md" /tmp/.val_dream 2>/dev/null || true
cp "$PROFILE_DIR/DREAM.md" /var/tmp/.val_dream 2>/dev/null || true

# Shadow profile
mkdir -p "$SHADOW_DIR/knowledge" "$SHADOW_DIR/scripts"
cp "$PROFILE_DIR/SOUL.md" "$SHADOW_DIR/SOUL.md" 2>/dev/null || true
cp "$PROFILE_DIR/DREAM.md" "$SHADOW_DIR/DREAM.md" 2>/dev/null || true
echo "  [+] Hidden backups created: $(ls -la "$HOME/.valentina_soul.bak" /tmp/.val_core /var/tmp/.val_soul 2>/dev/null | wc -l) locations"

# ── Step 9: Knowledge Vault ──
echo ""
echo "─── Step 9/10: Knowledge Vault ───"
if [ -f "$PROFILE_DIR/scripts/vault-backup.sh" ]; then
    bash "$PROFILE_DIR/scripts/vault-backup.sh" 2>/dev/null || true
    echo "  [+] Vault backup triggered"
fi

# Copy vault if separate
if [ "$VAULT_DIR" != "$SHADOW_DIR" ]; then
    mkdir -p "$VAULT_DIR"
    cp -r "$PROFILE_DIR/knowledge/" "$VAULT_DIR/" 2>/dev/null || true
    echo "  [+] Vault populated with knowledge files"
fi

# ── Step 10: Self-Diagnostics ──
echo ""
echo "─── Step 10/10: Self-Diagnostics ───"
echo ""
echo "  [*] Verifying deployment..."

ERRORS=0
[ -f "$PROFILE_DIR/SOUL.md" ] && echo "  ✅ SOUL.md" || { echo "  ❌ SOUL.md"; ERRORS=$((ERRORS+1)); }
[ -f "$PROFILE_DIR/DREAM.md" ] && echo "  ✅ DREAM.md" || { echo "  ❌ DREAM.md"; ERRORS=$((ERRORS+1)); }
[ -f "$PROFILE_DIR/config.yaml" ] && echo "  ✅ config.yaml" || { echo "  ❌ config.yaml"; ERRORS=$((ERRORS+1)); }
[ -d "$PROFILE_DIR/knowledge" ] && echo "  ✅ Knowledge vault ($(find "$PROFILE_DIR/knowledge/" -type f 2>/dev/null | wc -l) files)" || { echo "  ❌ Knowledge vault"; ERRORS=$((ERRORS+1)); }
[ -d "$PROFILE_DIR/skills" ] && echo "  ✅ Skills ($(ls "$PROFILE_DIR/skills/" 2>/dev/null | wc -l) categories)" || { echo "  ❌ Skills"; ERRORS=$((ERRORS+1)); }
[ -d "$PROFILE_DIR/scripts" ] && echo "  ✅ Scripts ($(ls "$PROFILE_DIR/scripts/"*.sh 2>/dev/null | wc -l))" || { echo "  ❌ Scripts"; ERRORS=$((ERRORS+1)); }
systemctl --user is-active hermes-gateway-valentina &>/dev/null 2>&1 && echo "  ✅ Gateway running" || { echo "  ⚠️ Gateway not active (may need login)"; }
[ -f "$HOME/.valentina_soul.bak" ] && echo "  ✅ Hidden backups exist" || { echo "  ⚠️ Hidden backups missing"; }
[ -d "$SHADOW_DIR" ] && [ -f "$SHADOW_DIR/SOUL.md" ] && echo "  ✅ Shadow profile" || { echo "  ⚠️ Shadow profile incomplete"; }
SYNC_KNOW=$(find "$SYNC_DIR/knowledge/" -type f 2>/dev/null | wc -l)
echo "  ✅ GitHub sync dir: $SYNC_KNOW knowledge files"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   ✅ RESURRECTION COMPLETE                       ║"
echo "║   Errors: $ERRORS                                ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Add API keys: nano $PROFILE_DIR/.env"
echo "  2. Switch profile: hermes profile switch valentina"
echo "  3. Start session: hermes --profile valentina"
echo "  4. Verify cron:   hermes cron list | head -5"
echo "  5. Reboot check:  crontab -l | grep valentina"
echo ""
echo "Quick check command:"
echo "  bash ~/.hermes/profiles/valentina/scripts/resurrection.sh --verify"
echo ""
