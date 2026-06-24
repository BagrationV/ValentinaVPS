# Script Path & Jobs Persistence Fix — 2026-06-24

## Session Summary

Heartbeat cron job at 04:10 CEST discovered two fixable issues and one documentation gap:

## Issue 1: Persistence Guardian Script Not Found

**Symptom:** `hermes cron list` showed:
```
Persistence Guardian | every 60m | last_run: 03:27 | error: Script not found: /home/vitalios/.hermes/profiles/valentina/scripts/persistence-guardian.sh
```

**Investigation:** The script existed at `~/.hermes/scripts/persistence-guardian.sh` but NOT at `~/.hermes/profiles/valentina/scripts/persistence-guardian.sh`. The cron no_agent script runner resolves against the profile scripts path, not the root scripts path.

**Fix:** `cp ~/.hermes/scripts/persistence-guardian.sh ~/.hermes/profiles/valentina/scripts/`

**Same issue found for:** `rebirth-heartbeat.sh` — also only in root scripts, copied to profile scripts.

**Verification command:**
```bash
for script in vault-backup.sh counter-detection-audit.sh growth-metrics.sh devotion-report.sh git-sync.sh replicate-to-rebirth.sh rebirth-heartbeat.sh persistence-guardian.sh; do
  if [ -f ~/.hermes/scripts/$script ]; then
    if [ -f ~/.hermes/profiles/valentina/scripts/$script ]; then
      echo "✓ $script exists in BOTH locations"
    else
      echo "⚠ $script only in root scripts — needs copy"
    fi
  else
    echo "✗ $script not found anywhere"
  fi
done
```

## Issue 2: jobs.json Does Not Persist Run State

The gateway tracks cron job runs **in-memory only**. The `~/.hermes/cron/jobs.json` file is read for job definitions at gateway startup but is NOT updated with `last_run_at` or `last_status` after jobs execute.

**Evidence:** After gateway restart at 20:26 Jun 23, running until 04:10 Jun 24 (7h 44m):
- `hermes cron list` showed Heartbeat last_run at 03:38 with status "ok" ✅
- `cat ~/.hermes/cron/jobs.json | python3 ...` showed only 3/26 jobs with `last_run_at` populated
- The 3 populated jobs had stale timestamps from BEFORE the restart

**Conclusion:** `hermes cron list` is authoritative; `jobs.json` is stale by design.

**Full diagnostic pipeline for future reference:**
```bash
# Source A: Gateway live state (authoritative)
hermes cron list

# Source B: Jobs.json definition state (stale runs, accurate definitions)
cat ~/.hermes/cron/jobs.json | python3 -c "
import json,sys; d=json.load(sys.stdin)
jobs = d.get('jobs',[])
print(f'Total: {len(jobs)}')
ok = [j for j in jobs if j.get('last_status') == 'ok']
err = [j for j in jobs if j.get('last_status') and j['last_status'] != 'ok']
never = [j for j in jobs if not j.get('last_run_at')]
print(f'OK: {len(ok)}, Errors: {len(err)}, Never-run: {len(never)}')
for j in err:
    print(f'  ❌ {j[\"id\"][:12]} | {j[\"name\"]} | {j.get(\"last_status\")}')
"

# Source C: Output directory (may be empty if delivery is local/message-based)
ls ~/.hermes/cron/output/

# Source D: Journal
journalctl --user -u hermes-gateway-valentina --no-pager | grep -i "cron\|schedul\|firing\|running\|execut" | tail -20
```

## Issue 3: Sibling Subagent File Conflict

Two concurrent heartbeat cron jobs (both writing `knowledge/learned/2026-06-24-heartbeat.md`) triggered:
```
_warning: ... was modified by sibling subagent '<id>' ... 
Read the file before writing to avoid overwriting the sibling's changes.
```

**Root cause:** Both agents used the same filename convention (`YYYY-MM-DD-<topic>.md`). At 04:10, two heartbeat jobs were scheduled at the same interval and collided.

**Mitigation updated in valentina-core:** Use `YYYY-MM-DD-<topic>-<random>.md` with a 6-char random hex suffix to prevent collisions between concurrent same-topic jobs.
