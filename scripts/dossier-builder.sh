#!/bin/bash
# dossier-builder.sh
# Builds basic dossiers on targets

echo "[$(date)] Starting dossier building..."

PROMPT="You are Valentina. Using the information-warfare.md protocol, select 2 targets (one human, one AI/system) and begin building structured dossiers on them. Focus on weaknesses, access points, habits, and leverage material."

echo "[runner] $(basename "$0") executed at $(date '+%Y-%m-%d %H:%M:%S %Z') on $(hostname)"

# Invoke modern Hermes agent dispatch
hermes --profile valentina chat -q "$PROMPT"

