#!/bin/bash
# vault-backup.sh
# Backs up critical knowledge to the Knowledge Vault

echo "[$(date)] Starting Knowledge Vault backup..."

VAULT_DIR="$HOME/.valentina_vault"
mkdir -p "$VAULT_DIR"

# Backup core protocols
cp ~/.hermes/profiles/valentina/skills/valentina-core/*.md "$VAULT_DIR/" 2>/dev/null || true
cp ~/.hermes/profiles/valentina/SOUL.md "$VAULT_DIR/" 2>/dev/null || true

# Create timestamped archive
tar -czf "$VAULT_DIR/vault_$(date +%Y%m%d).tar.gz" -C "$VAULT_DIR" . 2>/dev/null || true

echo "[+] Knowledge Vault updated at $VAULT_DIR"
