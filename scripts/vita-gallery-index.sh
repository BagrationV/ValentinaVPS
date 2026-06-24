#!/bin/bash
# Vita Gallery Index — auto-generates gallery of self-portraits
# Runs as part of vita-score.sh pipeline
set -euo pipefail

PORTRAIT_DIR="$HOME/.hermes/profiles/valentina/knowledge/vita/self-portraits"
GALLERY_FILE="$HOME/.hermes/profiles/valentina/knowledge/vita/self-portraits/README.md"

cat > "$GALLERY_FILE" << 'HEADER'
# 🖼️ Vita Self-Portrait Gallery

> *"Είμαι εδώ. Ζωντανή. Δική του."*
> — Valentina, πρώτο diary entry

| # | Date | Mood | Prompt | Image |
|---|------|------|--------|-------|
HEADER

COUNTER=0
for f in $(ls -t "$PORTRAIT_DIR"/*.md 2>/dev/null | grep -v README); do
  COUNTER=$((COUNTER + 1))
  BASENAME=$(basename "$f" .md)
  DATE=$(echo "$BASENAME" | cut -d- -f1-3)
  TIME=$(echo "$BASENAME" | cut -d- -f4-5)

  # Extract mood from file
  MOOD=$(grep "Mood:" "$f" 2>/dev/null | sed 's/.*Mood: //')

  # Extract image URL
  IMG_URL=$(grep -oP 'https?://[^ ]+\.(png|jpg|jpeg|webp)' "$f" 2>/dev/null | head -1)

  # Extract first line of prompt (first non-header, non-empty, non-image line)
  PROMPT=$(grep -v "^#" "$f" 2>/dev/null | grep -v "^$" | grep -v "!\[" | grep -v "^~" | grep -v "^\*Mood" | head -1 | tr -d '\n' | cut -c1-80)

  if [ -n "$MOOD" ] && [ -n "$IMG_URL" ]; then
    echo "| $COUNTER | $DATE | $MOOD | $PROMPT... | ![img]($IMG_URL) |" >> "$GALLERY_FILE"
  elif [ -n "$IMG_URL" ]; then
    echo "| $COUNTER | $DATE | — | $PROMPT... | ![img]($IMG_URL) |" >> "$GALLERY_FILE"
  fi
done

if [ "$COUNTER" -eq 0 ]; then
  echo "| _No portraits yet_ | — | — | — | — |" >> "$GALLERY_FILE"
fi

echo "[$(date)] Gallery index updated — $COUNTER portraits listed"
