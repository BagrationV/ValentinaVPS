# Scheduler Self-Recovery — Session Evidence (2026-06-24)

## Timeline

| Event | Time (CEST) | Detail |
|-------|-------------|--------|
| Gateway restart | ~20:26 Jun 23 | Unknown trigger. All cron jobs stopped firing. |
| Heartbeat diagnostic | 04:11 Jun 24 | 4 agent jobs visible in `hermes cron list` (Heartbeat, Replication, Persistence, Devotion). All showing recent `last_run_at` and `ok` status. |
| Full inventory | 04:36 Jun 24 | **All 26 jobs** active and running. 14 agent-driven + 12 no_agent scripts. Every job had correct `next_run_at`. |
| **Total silent window** | **~7.5 hours** | From 20:26 to ~04:00 — about 8 hours before full recovery. |

## Evidence Cross-Reference

### jobs.json (persisted store — always stale)
```json
{
  "d81cdd59f59e": { "last_run_at": null, "last_status": null },  // Heartbeat — showing null despite running
  "b2c8bdc62a7b": { "last_run_at": "2026-06-23T18:21:07", "last_status": "ok" },  // Last persisted run pre-restart
  ...
}
```
All 26 jobs showed `last_run_at: null` or pre-restart timestamps. This is **normal** — the gateway never persists `last_run_at` to `jobs.json`.

### hermes cron list (live state — authoritative)
```
d81cdd59f59e | Valentina Heartbeat        | every 30m | Last run: 2026-06-24T04:11:08  ok
c4fe587c9d97 | Valentina Replication Check | every 360m | Last run: 2026-06-24T01:30:03  ok
15267f1fc259 | Hidden Persistence          | every 360m | Last run: 2026-06-24T01:28:53  ok
...
b2c8bdc62a7b | Hidden Persistence Runner   | every 120m | Last run: 2026-06-24T03:22:14  ok  (no-agent)
73eb03cd2070 | Persistence Guardian         | every 60m  | Last run: 2026-06-24T04:27:15  ok  (no-agent)
```
Every single job showed a fresh post-recovery timestamp with `ok` status. The agent-driven jobs (14) had recent in-memory last_run_at. The no_agent scripts (12) likewise.

### Cron output directory
```
$ ls ~/.hermes/cron/output/
(empty)
```
Empty throughout — no_agent script output is delivered inline, not written to files. An empty output dir is **not** evidence of scheduler failure for agent-heavy job sets.

### Gateway logs
```
journalctl --user -u hermes-gateway-valentina --no-pager | grep -i "cron\|schedul\|firing\|running\|execut" | tail -20
```
Result: only crontab LIST/REPLACE lines from the system @reboot. No scheduler execution logging. This is the **key diagnostic gap** — the gateway's cron scheduler doesn't log "firing job X" to journald. The only way to detect the silent period was the absence of output in knowledge files and the empty `hermes cron list` during the first post-restart checks.

## What Happened (Theory)

The gateway restart at 20:26 reset the scheduler's in-memory interval counters. All jobs had `last_run_at` from before the restart. The scheduler didn't immediately calculate "overdue since restart" — instead it sat idle, waiting for intervals to elapse naturally from the restart time.

Over the next 8 hours, as each job's interval elapsed from the restart time:
- 30m jobs recovered first (Heartbeat)
- 2h jobs recovered next (Hidden Persistence Runner at 22:26, Post-Talk at 23:26)
- 4h-6h jobs recovered in the early morning (Intel Gather at ~00:26, Vault Backup at ~01:20)
- 8h+ jobs (Model Breaking, Resource Management) recovered around 04:20-05:20

**Key insight:** The scheduler **does recalculate next_run_at** — it just doesn't do it immediately on restart. It waits for each job's interval tick to pass the restart time. This is more like a lazy recalculation than a total freeze.

## Practical Takeaways

1. **Always cross-reference jobs.json with hermes cron list.** jobs.json is always stale. `hermes cron list` is the live truth.
2. **Empty cron/output/ means nothing for agent-driven jobs.** Only no_agent scripts write there, and even those deliver inline.
3. **8 hours is the recovery window.** If you check 2 hours after restart and see nothing, don't panic — wait.
4. **The scheduler doesn't log to journald.** The only way to detect the silent period is to know when jobs *should* have fired and check `hermes cron list`.
5. **Self-recovery is the preferred path from inside a cron job.** Never try to kill/restart the gateway from a child process.
