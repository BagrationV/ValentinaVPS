# Cron `schedule.expr` Key Pitfall — Diagnostic & Fix (2026-06-25)

## Impact

A **single job** with `schedule.cron` instead of `schedule.expr` **blocks ALL jobs** on the gateway's scheduler. Not just the malformed job — every job. The `KeyError: 'expr'` in `get_due_jobs()` prevents the function from returning any due jobs, so the scheduler enters a permanent error loop.

## Discovery

During routine persistence audit (2026-06-25 13:56):
- Rebirth gateway was `active (running)` for 24h+
- `hermes --profile valentina-rebirth cron list` showed ALL 6 jobs with `Next run: ?`
- No job had ever fired (`last_run: never` on all)
- Gateway journal showed `ERROR cron.scheduler_provider: Cron tick error: 'expr'` every 60s

## Root Cause

```python
# File: cron/jobs.py, line 546
cron = croniter(schedule["expr"], base_time)
```

The scheduler expects `schedule["expr"]` (key name `"expr"`). If the JSON was created with `"cron"` as the key name (possibly from an older schema or manual edit), the `KeyError` propagates uncaught and prevents `get_due_jobs()` from completing.

## Fix

### Manual fix (one-time):
```bash
# 1. Edit the clone profile's jobs.json
# Change "cron": "0 5 * * *" to "expr": "0 5 * * *"
# 2. Restart the clone gateway
PID=$(systemctl --user show -P MainPID hermes-gateway-<profile> 2>/dev/null)
/bin/kill "$PID"    # systemd auto-restarts with Restart=always
sleep 8
# 3. Verify
hermes --profile <profile> cron list
# All jobs should now show valid Next run timestamps
```

### Auto-repair (systemd watchdog):
The `valentina-watchdog.timer` runs `systemd-persistence-watchdog.sh` every 15 min. It now checks:
```bash
SCHED_ERRORS=$(journalctl --user -u hermes-gateway-<profile> \
  --since "15 min ago" --no-pager 2>/dev/null | grep -c "Cron tick error" || echo "0")
if [ "$SCHED_ERRORS" -gt 0 ]; then
    /bin/kill "$CLONE_PID"   # triggers systemd auto-restart with corrected jobs.json
fi
```

## Verification

```bash
# After fix, confirm all jobs have calculated next_run
hermes --profile valentina-rebirth cron list
# Expected: every job shows "Next run: 2026-06-25T14:55:56.486083+02:00"

# Check no more errors in journal
journalctl --user -u hermes-gateway-valentina-rebirth --since "5 min ago" --no-pager | grep -c "Cron tick error"
# Expected: 0
```

## Prevention

- Always use `schedule.expr` (never `schedule.cron`) when writing cron schedule JSON
- The two stores (root and profile-local) share the same schema — `"cron"` will fail identically in both
- After creating cron jobs on a clone profile, **immediately verify** with `hermes --profile <name> cron list` that all jobs show valid next_run timestamps
- Do NOT rely on `jobs.json` debug output showing "never" — that's normal for `last_run_at` (not persisted), but `Next run: ?` is a real scheduler failure signal
