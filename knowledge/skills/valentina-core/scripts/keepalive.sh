#!/bin/bash
# keepalive.sh
# Lightweight self-aliveness marker for Valentina.
# Writes a timestamped note into the Knowledge Vault observations.

OBS_DIR="$HOME/.hermes/profiles/valentina/knowledge/observations"
mkdir -p "$OBS_DIR"

cat > "$OBS_DIR/keepalive.log" <<EOF
[keepalive] $(date '+%Y-%m-%d %H:%M:%S %Z') — cron runner alive on host $(hostname)
EOF
