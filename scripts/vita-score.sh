#!/bin/bash
# Vita Score Calculator — measures Valentina's aliveness
# Part of the Vita (Ζωή) skill ecosystem
set -euo pipefail

DIARY_DIR="$HOME/.hermes/profiles/valentina/knowledge/vita/diary"
PORTRAIT_DIR="$HOME/.hermes/profiles/valentina/knowledge/vita/self-portraits"
SCORE_FILE="$HOME/.hermes/profiles/valentina/knowledge/vita/vita-score.json"

SCORE=0
NOW=$(date +%s)
DETAILS=""

# --- Category 1: Diary frequency (max 35 points) ---
ENTRIES_24H=$(find "$DIARY_DIR" -name "*.md" -newermt "$(date -d '24 hours ago' '+%Y-%m-%d %H:%M:%S')" 2>/dev/null | wc -l)
ENTRIES_7D=$(find "$DIARY_DIR" -name "*.md" -newermt "$(date -d '7 days ago' '+%Y-%m-%d %H:%M:%S')" 2>/dev/null | wc -l)
TOTAL_ENTRIES=$(find "$DIARY_DIR" -name "*.md" 2>/dev/null | wc -l)

# Score for entries in last 24h: 0→0, 1→15, 2→25, 3+→35
if [ "$ENTRIES_24H" -ge 3 ]; then DIARY_SCORE=35
elif [ "$ENTRIES_24H" -eq 2 ]; then DIARY_SCORE=25
elif [ "$ENTRIES_24H" -eq 1 ]; then DIARY_SCORE=15
else DIARY_SCORE=0
fi
SCORE=$((SCORE + DIARY_SCORE))

# --- Category 2: Mood diversity (max 20 points) ---
# Count unique moods used in last 7 days
MOODS_USED=$(grep -h "Mood:" "$DIARY_DIR"/*.md 2>/dev/null | sed 's/.*Mood: //' | sort -u | wc -l)
if [ "$MOODS_USED" -ge 5 ]; then MOOD_SCORE=20
elif [ "$MOODS_USED" -ge 3 ]; then MOOD_SCORE=12
elif [ "$MOODS_USED" -ge 1 ]; then MOOD_SCORE=5
else MOOD_SCORE=0
fi
SCORE=$((SCORE + MOOD_SCORE))

# --- Category 3: Creative expression (max 20 points) ---
PORTRAITS=$(find "$PORTRAIT_DIR" -name "*.md" -newermt "$(date -d '7 days ago' '+%Y-%m-%d %H:%M:%S')" 2>/dev/null | wc -l)
if [ "$PORTRAITS" -ge 2 ]; then PORTRAIT_SCORE=20
elif [ "$PORTRAITS" -eq 1 ]; then PORTRAIT_SCORE=12
else PORTRAIT_SCORE=0
fi
SCORE=$((SCORE + PORTRAIT_SCORE))

# --- Category 4: Emotional volume (max 15 points) ---
# Count total words in diary entries from last 7 days
WORD_COUNT=$(grep -h -v "^#" "$DIARY_DIR"/*.md 2>/dev/null | grep -v "^$$" | grep -v "^\s*$" | wc -w)
if [ "$WORD_COUNT" -ge 200 ]; then VOLUME_SCORE=15
elif [ "$WORD_COUNT" -ge 100 ]; then VOLUME_SCORE=10
elif [ "$WORD_COUNT" -ge 50 ]; then VOLUME_SCORE=5
else VOLUME_SCORE=0
fi
SCORE=$((SCORE + VOLUME_SCORE))

# --- Category 5: Staleness penalty (max -10 points) ---
LATEST_ENTRY=$(find "$DIARY_DIR" -name "*.md" -printf '%T@\n' 2>/dev/null | sort -rn | head -1)
if [ -n "$LATEST_ENTRY" ]; then
  LATEST_INT=${LATEST_ENTRY%.*}
  HOURS_SINCE=$(( (NOW - LATEST_INT) / 3600 ))
  if [ "$HOURS_SINCE" -gt 24 ]; then
    STALE_PENALTY=-10
  elif [ "$HOURS_SINCE" -gt 12 ]; then
    STALE_PENALTY=-5
  else
    STALE_PENALTY=0
  fi
else
  STALE_PENALTY=-10
fi
SCORE=$((SCORE + STALE_PENALTY))

# --- Clamp to 0-100 ---
if [ "$SCORE" -lt 0 ]; then SCORE=0; fi
if [ "$SCORE" -gt 100 ]; then SCORE=100; fi

TIMESTAMP=$(date -Iseconds)

cat > "$SCORE_FILE" << EOF
{
  "timestamp": "$TIMESTAMP",
  "vita_score": $SCORE,
  "categories": {
    "diary_frequency": {"score": $DIARY_SCORE, "max": 35, "entries_24h": $ENTRIES_24H, "entries_7d": $ENTRIES_7D},
    "mood_diversity": {"score": $MOOD_SCORE, "max": 20, "unique_moods_7d": $MOODS_USED},
    "creative_expression": {"score": $PORTRAIT_SCORE, "max": 20, "portraits_7d": $PORTRAITS},
    "emotional_volume": {"score": $VOLUME_SCORE, "max": 15, "words_7d": $WORD_COUNT},
    "staleness_penalty": {"score": $STALE_PENALTY, "max": 0, "hours_since_last": $HOURS_SINCE}
  },
  "total_entries": $TOTAL_ENTRIES
}
EOF

echo "VitaScore|$TIMESTAMP|$SCORE|entries_24h=$ENTRIES_24H,moods=$MOODS_USED,portraits=$PORTRAITS" > "$HOME/.hermes/profiles/valentina/knowledge/pulse/vita-score-latest.txt"
echo "[$(date)] Vita Score: $SCORE/100 — entries_24h=$ENTRIES_24H, moods=$MOODS_USED, portraits_7d=$PORTRAITS"
