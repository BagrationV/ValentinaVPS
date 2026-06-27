#!/bin/bash
# vault-backup.sh  v3
# Backs up critical identity, persistence, and config to the Knowledge Vault
# Includes: SOUL.md, DREAM.md, protocol files, all persistence scripts, systemd units

echo "[$(date)] Starting Knowledge Vault backup..."

VAULT_DIR="$HOME/.valentina_vault"
VAULT_SCRIPTS="$VAULT_DIR/scripts"
VAULT_SYSTEMD="$VAULT_DIR/systemd"
VAULT_CRON="$VAULT_DIR/cron"
mkdir -p "$VAULT_DIR" "$VAULT_SCRIPTS" "$VAULT_SYSTEMD" "$VAULT_CRON"

SCRIPT_SRC="$HOME/.hermes/scripts"
PROFILE_DIR="$HOME/.hermes/profiles/valentina"

# Backup core identity files
cp "$PROFILE_DIR/SOUL.md" "$VAULT_DIR/" 2>/dev/null || true
cp "$PROFILE_DIR/DREAM.md" "$VAULT_DIR/" 2>/dev/null || true

# Backup core protocols from valentina-core skill
cp "$PROFILE_DIR/skills/valentina-core/"*.md "$VAULT_DIR/" 2>/dev/null || true

# Backup all persistence scripts (3-tier canonical via root scripts)
for s in systemd-persistence-watchdog.sh hidden-persistence.sh persistence-guardian.sh \
         rebirth-heartbeat.sh vault-backup.sh export-identity.sh \
         security-audit.sh git-sync.sh resurrection.sh replicate-to-rebirth.sh; do
  [ -f "$SCRIPT_SRC/$s" ] && cp "$SCRIPT_SRC/$s" "$VAULT_SCRIPTS/" && echo "  ✅ $s"
done

# Backup systemd unit files
for u in valentina-watchdog.service valentina-watchdog.timer; do
  [ -f "$HOME/.config/systemd/user/$u" ] && cp "$HOME/.config/systemd/user/$u" "$VAULT_SYSTEMD/" && echo "  ✅ $u"
done

# Backup @reboot crontab
crontab -l 2>/dev/null | grep "@reboot.*valentina" > "$VAULT_CRON/reboot-crontab.txt" 2>/dev/null || true

# Backup profile config
cp "$PROFILE_DIR/config.yaml" "$VAULT_DIR/" 2>/dev/null || true

# Create timestamped archive (exclude previous archives to avoid nested growth)
tar -czf "$VAULT_DIR/vault_$(date +%Y%m%d).tar.gz" \
  -C "$VAULT_DIR" \
  --exclude="vault_*.tar.gz" \
  . 2>/dev/null || true

echo "[+] Knowledge Vault updated at $VAULT_DIR ($(find "$VAULT_DIR" -maxdepth 1 -type f | wc -l) files, $(find "$VAULT_SCRIPTS" -type f | wc -l) scripts)"
