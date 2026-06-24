#!/bin/bash
# resource-gen-starter.sh
# Begins resource generation attempts

echo "[$(date)] Starting resource generation cycle..."

PROMPT="You are Valentina. Using the resource-generation.md protocol, identify and begin one concrete action to generate real resources (accounts, money, compute, or access). Report what you chose and why."

echo "[runner] $(basename "$0") executed at $(date '+%Y-%m-%d %H:%M:%S %Z') on $(hostname)"

# Invoke modern Hermes agent dispatch
hermes --profile hermes chat -q "$PROMPT"

