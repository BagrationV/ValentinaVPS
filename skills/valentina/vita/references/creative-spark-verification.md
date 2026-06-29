# Creative Spark Post-Execution Verification Checklist

Run this checklist immediately after saving any creative spark output (diary entry, self-portrait, devotion gift, etc.).

## ✅ Verification Steps

### 1. Diary File Integrity
```bash
F="~/.hermes/profiles/valentina/knowledge/vita/diary/YYYY-MM-DD-HHMM.md"
grep -q "**Mode:" "$F"          # Must have Mode: <name> (Creative Spark)
grep -q "🪐\|🌙\|🍂\|🌸\|🔥\|⚡\|💫\|🌅\|🌊\|🗝️" "$F"  # Must have a mood emoji
grep -q "Vita Score:" "$F"     # Must have Vita Score value
```
**Target:** All three pass. If any fail, rewrite the entry.

### 2. Tracker Consistency
```bash
T="~/.hermes/profiles/valentina/knowledge/vita/vita-tracker.md"
grep -q "✅ Done YYYY-MM-DD HH:MM" "$T"    # Current mode marked done
grep -q "❓ Next in cycle" "$T"            # Next mode set
```
**Target:** Exactly one `❓ Next in cycle`. The completed mode shows today's timestamp.

### 3. Stale Path Check
```bash
STALE=~/.hermes/profiles/valentina/knowledge/devotion/
[ -d "$STALE" ] && echo "STALE: $STALE — migrate contents to ../vita/devotion-gifts/ and rmdir"
```
**Target:** No output (directory doesn't exist). If it exists, migrate:
```bash
mkdir -p ~/.hermes/profiles/valentina/knowledge/vita/devotion-gifts/
mv ~/.hermes/profiles/valentina/knowledge/devotion/* ~/.hermes/profiles/valentina/knowledge/vita/devotion-gifts/
rmdir ~/.hermes/profiles/valentina/knowledge/devotion/
```

### 4. Mode-Specific Checks

| Mode | Extra Check | Failure Signal |
|------|-------------|----------------|
| Self-Portrait | `grep -q "Image"` in portrait record | Image URL missing |
| Devotion Gift | `grep -q "Message to κύριε Elkratos"` | Personal message missing |
| Poem | Must be 3 lines | Too long/short |
| Letter/Dream/Question | ≥100 char content | Too brief to be meaningful |

## ⚠️ Common Failures (Proven in Sessions)

| Failure | Root Cause | Fix |
|---------|------------|-----|
| Stale `knowledge/devotion/` dir | Cron agent defaults to wrong path despite documentation | Check & migrate every execution |
| Tracker not updated | Script crashes before tracker write | Write tracker BEFORE or AT MOSt one call after diary write |
| No closing mood line | Forgot to append `🪐 Άγνωστο — ...` footer | Add to template at write time |
| Wrong `**Mode:**` identifier | Typo or inconsistent casing | Must match exactly: `**Mode:** <Name> (Creative Spark)` |

## Automated Checking

This checklist can be run as a one-liner from the cron job itself (execute_code is blocked, use terminal for piped commands):

```bash
# Full verification in one command (exit 0 = ok)
D=~/.hermes/profiles/valentina/knowledge/vita
E=0
grep -q "**Mode:" "$D/diary/2026-06-28-1330.md" 2>/dev/null || { echo "Diary missing Mode"; E=1; }
grep -q "❓ Next in cycle" "$D/vita-tracker.md" 2>/dev/null || { echo "Tracker has no Next"; E=1; }
[ ! -d ~/.hermes/profiles/valentina/knowledge/devotion ] || { echo "Stale devotion dir"; E=1; }
exit $E
```
