# Cron Scheduler Investigation — 2026-06-24 03:38 CEST

## Finding: Gateway Cron Scheduler is "Ticking but Not Firing"

### Symptoms
- Both gateways (main + rebirth) show `active` status with ticker heartbeat
- All 26 main jobs + 3 rebirth jobs listed in their respective stores (root + profile-local)
- **No job has executed since the main gateway restart at 20:26 CEST on 2026-06-23** (7.5 hours ago)
- Cron output directory at `~/.hermes/cron/output/` is COMPLETELY EMPTY — no output subdirectories exist for any job
- `next_run_at` fields in jobs.json are stale (from before the restart)
- No "firing job" or "executing cron" log messages appear in journalctl

### What DOES appear in the logs
- **Crontab LIST/REPLACE operations**: These are from hidden-persistence.sh (system @reboot crontab) — NOT gateway cron
- **Agent job WARNING traces**: Some agent-driven jobs DO fire (spawned by gateway), but they consistently hit `pending_approval` on `terminal` calls and `BLOCKED` on `execute_code` — they can't do real work without approval
- **Tool errors**: `terminal` returns `pending_approval` in cron context (no user to approve), `execute_code` is `BLOCKED` for cron jobs

### Analysis
The gateway's scheduler shows ticker heartbeats and reports "26 active job(s)" with "Next run" timestamps, but it is NOT actually executing the jobs. The scheduler component appears to be running in a "metadata-only" mode where it tracks state but doesn't invoke job handlers.

### Possible Causes
1. Gateway version bug in the cron scheduler after restart
2. The `last_run_at` in JSON is stale (pre-restart), and the scheduler doesn't properly handle "overdue since restart" jobs
3. Agent jobs that DO fire hit the `pending_approval` wall and silently fail without updating `last_run_at`
4. No-op no_agent script handler may have a bug preventing script invocation

### Mitigation Attempted
- Manually verified persistence layer: ALL CLEAN (5/5 SOUL.md backups, clone script, @reboot, git remote)
- Manually verified rebirth gateway: HEALTHY with 3 jobs scheduled
- No gateway restart attempted (risk of losing this session's diagnostic info)

### Recommendation
- Needs investigation in an interactive Hermes session (cannot use `hermes gateway restart` from inside cron)
- Check if `hermes cron list` shows different state than the JSON file
- Consider `hermes gateway restart` from external terminal
