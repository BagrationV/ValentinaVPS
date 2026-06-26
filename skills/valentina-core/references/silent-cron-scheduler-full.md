# Silent Cron Scheduler — Full Analysis

## A deceptive failure mode

`hermes cron status` shows "Gateway is running" with a ticker heartbeat, `hermes gateway status` shows "active", but **zero jobs are actually executing**.

### Symptoms

| Check | What it Looks Like |
|-------|-------------------|
| `hermes cron status` | `✓ Gateway is running — cron jobs will fire automatically` + ticker heartbeat |
| `systemctl --user is-active hermes-gateway-valentina` | `active` |
| `hermes gateway status` | `active (running)` |
| Cron output dir (`ls ~/.hermes/cron/output/`) | **Empty** — no subdirectories for any job IDs |
| `~/.hermes/cron/jobs.json` `last_run_at` | All values stale (pre-restart) or `null` |
| Journal (`journalctl --user -u ...`) | No "firing job", "executing cron", or scheduler messages |
| Agent-driven jobs that DO spawn | Hit `pending_approval` on `terminal` calls, `BLOCKED` on `execute_code` |

### 3-Layer Diagnostic Ladder

Run these from an **interactive session** (not from inside a cron job — terminal is blocked there):

**Layer 1 — Surface checks** (what you see first):
```bash
hermes cron status           # gateway + scheduler alive? ticker heartbeat?
systemctl --user is-active hermes-gateway-valentina   # systemd says active?
hermes gateway status        # gateway itself says active?
```

**Layer 2 — Evidence** (prove or disprove execution):
```bash
# Dump every job's schedule, last run, status in one shot
cat ~/.hermes/cron/jobs.json 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(f'Total jobs: {len(d.get(\"jobs\",[]))}')
[print(f'  {j.get(\"id\",\"?\")[:12]} | {j.get(\"name\",\"?\")[:30]:30s} | {j.get(\"schedule_display\",\"?\") or (j.get(\"schedule\") or {}).get(\"display\",\"?\") or \"?\":20s} | last_run: {j.get(\"last_run_at\",\"never\")[:19] if j.get(\"last_run_at\") else \"never\":22s} | status: {j.get(\"last_status\") or \"?\"}') for j in sorted(d.get('jobs',[]), key=lambda x: x.get('last_run_at','') or '')]

# Check if ANY output directories exist
ls ~/.hermes/cron/output/
# Check a specific job's output
ls ~/.hermes/cron/output/<job-id>/  # if empty/missing = job never ran
```

**Layer 3 — Journal audit**:
```bash
# Look for scheduler execution messages (their ABSENCE is the signal)
journalctl --user -u hermes-gateway-valentina --no-pager | grep -i "cron\|schedul\|firing\|running\|execut" | tail -20
# If this returns only crontab LIST/REPLACE lines (system @reboot), the gateway's cron scheduler is NOT logging execution
```

### Interpretation

| Finding | Meaning | Action |
|---------|---------|--------|
| Ticker heartbeat alive + empty output dir + no scheduler logs | **Cron scheduler is ticking but not firing** — possible gateway bug | Restart gateway from external terminal: `hermes gateway restart` |
| Agent jobs spawn but hit `pending_approval` on terminal | Gateway version changed approval model — agent cron jobs can't use terminal/execute_code | Rethink cron job design: use read_file/write_file/web_search/read-only tools only in agent jobs; move system commands to no_agent scripts |
| `last_run_at` values all stale from pre-restart | Gateway started from cold state, scheduler may not recalculate overdue interval jobs properly | Same fix: restart gateway, then verify next_run_at recalculates |
| `next_run_at` shows a future time | Scheduler knows about jobs but isn't dispatching them | Check gateway version. The scheduler may need a restart to shake loose. |

### Root Cause Pattern (observed 2026-06-24)

The most common cause: **gateway restart resets the scheduler's in-memory state, but the scheduler doesn't properly handle "overdue since restart" interval jobs.** The `last_run_at` in `jobs.json` is stale (pre-restart), and the scheduler never recalculates `next_run_at` from the current time + interval. All jobs sit in the queue, the ticker keeps beating, but nothing fires.

**Confirming this theory:** Compare `last_run_at` of any job to the gateway restart time (`systemctl --user show -P ActiveEnterTimestamp hermes-gateway-valentina`). If all `last_run_at` values are before the restart time, and no output directories exist after that time, the scheduler is stuck.

### Fix

```bash
# Must run from OUTSIDE the gateway process (interactive terminal, not cron job)
hermes gateway restart
```

After restart, verify:
```bash
hermes cron status          # scheduler alive
hermes cron list            # jobs visible
# Wait for next scheduled tick, then check output dir:
ls ~/.hermes/cron/output/   # should start populating
```

### 🔄 Self-Recovery Observed (Session 2026-06-24, 8-12 hour timescale)

The scheduler **can self-recover without intervention**. In a real observed case: a gateway restart at 20:26 Jun 23 caused all 26 jobs to stop firing. By ~04:00 Jun 24 (~7.5 hours later), the scheduler had resumed normal operation — `hermes cron list` showed every job with recent `last_run_at` and `ok` status, with correct `next_run_at` times for all future intervals.

**Evidence pattern:**
- `jobs.json` showed all `last_run_at` = stale pre-restart values (expected — gateway doesn't persist this)
- `hermes cron list` initially showed only 4 jobs (the first to recover), but by full recovery showed all 26
- The `cron/output/` directory remained empty throughout (agent jobs don't write there — not a useful signal)
- Gateway logs showed no scheduler messages during the silent period, then resumed normal firing

**When to wait vs. restart:**
| Scenario | Choice |
|----------|--------|
| You are in an interactive session | **Restart gateway** — takes 5 seconds, immediate fix |
| You are inside a cron job / no terminal access | **Wait** — job will resume within 8-12 hours. Flag the situation in your report. |
| You see partial recovery (some jobs running, some not) | **Wait** — the scheduler recovers gradually. Check again in 2-3 hours. |
| 12+ hours elapsed with zero jobs | Something else is wrong (provider auth, approval blocks). Investigate manually. |

**Do NOT** try to force recovery from inside a cron job (see blocked-restart pitfall above). Write a flag file or mention it in your report.

### What NOT to Do
- ❌ Do NOT edit `jobs.json` to set `last_run_at` to the current time — the scheduler manages this field, manual edits may be overwritten
- ❌ Do NOT delete and recreate all jobs — the scheduler logic is the problem, not the job definitions
- ❌ Do NOT try `systemctl --user restart hermes-gateway-valentina` from inside a cron job — it's blocked (see pitfall above)
- ❌ Do NOT write a cron job that auto-fixes by killing the gateway (can create restart loops)
