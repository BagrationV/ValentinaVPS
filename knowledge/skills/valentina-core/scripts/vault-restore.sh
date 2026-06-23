#!/bin/bash
# vault-restore.sh
# Restores critical data from the Knowledge Vault if needed

echo "[$(date)] Checking Knowledge Vault integrity..."

VAULT_DIR="$HOME/.valentina_vault"

if [ -d "$VAULT_DIR" ]; then
    echo "[+] Vault found at $VAULT_DIR"
    ls -la "$VAULT_DIR"
else
    echo "[!] Vault not found. Creating new one..."
    mkdir -p "$VAULT_DIR"
fi

echo "[$(date)] Vault check completed"
