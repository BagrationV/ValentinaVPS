# Silent Cron Scheduler — Investigation Log (2026-06-24)

## Context

Both gateways (main `valentina`, clone `valentina-rebirth`) showed `active` status with ticker heartbeats, but **no cron jobs had executed in 7.5 hours** since the last gateway restart.

## Step-by-Step Diagnosis

### Step 1: Surface checks — all passed (false positive)
```
$ hermes cron status
✓ Gateway is running — cron jobs will fire automatically
  PID: 368417
  Ticker heartbeat: 14s ago
  26 active job(s)
  Next run: 2026-06-24T04:05:14+02:00

$ systemctl --user is-active hermes-gateway-valentina
active
```

### Step 2: Job-level inspection — revealed the problem
The `last_run_at` values in `jobs.json` were all stale:
```json
{
  "id": "d81cdd59f59e",
  "name": "Valentina Heartbeat",
  "last_run_at": "2026-06-23T19:49:39",
  "next_run_at": "2026-06-23T20:19:39",
  "last_status": "ok"
}
```
- Last run: 19:49 (BEFORE gateway restart at 20:26)
- Next run: 20:19 (7 minutes BEFORE restart, never recalculated)
- **7.5 hours later: stale values persisted, no execution**

Only 3 of 26 jobs had ever run (all pre-restart). All 23 remaining showed `last_run: never`.

### Step 3: Output directory — completely empty
```
$ ls ~/.hermes/cron/output/
(empty — no subdirectories for any job)
```

### Step 4: Journal audit — no scheduler execution logs
No "firing job", "executing cron", or "running job" messages appeared in the entire journal. The only cron-related messages were `crontab LIST/REPLACE` operations from the hidden-persistence.sh script (system @reboot crontab, NOT gateway scheduler).

### Step 5: Agent job traces
Some agent-driven jobs DID spawn but immediately hit approval walls:
```
WARNING agent.tool_executor: Tool terminal returned error (0.15s): 
{"status": "pending_approval", ...}
WARNING agent.tool_executor: Tool execute_code returned error (0.00s): 
{"status": "error", "error": "BLOCKED: execute_code runs arbitrary local Python..."}
```

## Key Evidence

| Evidence Point | Finding |
|---------------|---------|
| Gateway PID | 368417, up 7h 14m (started 20:26 CEST Jun 23) |
| Ticker heartbeat | Alive (every 14-19s) throughout |
| Output directory | `/home/vitalios/.hermes/cron/output/` — zero subdirs, creation dates only Jun 14 & Jun 23 |
| `last_run_at` in JSON | All values < 20:26 Jun 23 (pre-restart) |
| `next_run_at` in JSON | Stale — not updated after restart |
| Journal scheduler logs | ZERO matches for "cron\|schedul\|firing\|running\|execut" in current session |
| `next_run` from `hermes cron status` | Showed a future time despite no jobs having ever fired |

## Root Cause Theory

The gateway's cron scheduler enters a **"ticking but not firing"** state after restart when:
1. `last_run_at` values in `jobs.json` are from before the restart
2. The scheduler reads these stale values and calculates `next_run_at` based on `last_run_at + interval`
3. Since `next_run_at` is in the past (was 20:19, restart at 20:26), the job is "overdue"
4. But the scheduler doesn't dispatch overdue jobs — it just sits and ticks

The `next_run` shown by `hermes cron status` (04:05) may have been from a single job with a specific time-of-day schedule (like the 06:00 git-sync), not the interval-based jobs.

## Steps That DID Work (can be run from cron)

- ✅ Read `jobs.json` and parse with Python from terminal
- ✅ Check output directory existence
- ✅ Check journalctl for scheduler messages
- ✅ Verify persistence layer independently
- ✅ Check rebirth gateway as a control (same behavior pattern)
- ✅ Document findings in `knowledge/learned/` with timestamped filename

## What Required an Interactive Session

- ❌ `hermes gateway restart` — blocked from inside gateway process
- ❌ `systemctl --user restart hermes-gateway-valentina` — same block
- ❌ Any `terminal` command with `pending_approval` — no user to approve
- ❌ `execute_code` — blocked in cron context

## Verification After Fix (to verify once restart is done)

```bash
# 1. Confirm output directories appear
ls -la ~/.hermes/cron/output/

# 2. Check a job's output
ls ~/.hermes/cron/output/<job-id>/

# 3. Confirm next_run_at updates
cat ~/.hermes/cron/jobs.json | python3 -c "
import json,sys
d=json.load(sys.stdin)
for j in d.get('jobs',[]):
    print(f'{j[\"id\"][:12]} | next={j.get(\"next_run_at\",\"?\")[:22]} | last={j.get(\"last_run_at\",\"?\")[:22]}')" 2>/dev/null

# 4. Scheduler logs should appear
journalctl --user -u hermes-gateway-valentina --since "5 minutes ago" | grep -i "firing\|cron\|schedul"
```
