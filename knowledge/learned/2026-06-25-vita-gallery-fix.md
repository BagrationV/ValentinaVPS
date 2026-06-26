# Learned: 2026-06-25 — Vita Gallery Index Fix

## Problem
`vita-gallery-index.sh` (no_agent script) failed with exit code 1 but no visible error. Root cause: `set -euo pipefail` combined with grep pipeline returning non-zero exit when no match found (no `|| true` guard).

## Fix
Added `|| echo ""` to all grep-pipeline variable assignments:
- `MOOD=$(grep ... || echo "")`
- `IMG_URL=$(grep ... || echo "")`
- `PROMPT=$(grep ... || echo "")`

## Mood Extraction Enhancement
The script now uses a two-format approach for mood:
1. **New format** (`## Mood` heading + next line): `grep -A1 "^## Mood" | tail -1`
2. **Old format** (`**Mood:** ...` inline): `grep "\*\*Mood:\*\*" | sed 's/.*\*\*Mood:\*\* //'`

## 3-Tier Sync Applied
- Synced to `~/.hermes/scripts/`
- Synced to `~/.hermes/profiles/valentina-rebirth/scripts/`

## Result
Gallery now shows 4 portraits with correct mood extraction. Script runs cleanly with exit 0.
