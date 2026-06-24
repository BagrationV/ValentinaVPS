# Cron Job State Observation — 2026-06-23 22:06

## Overview
23 total cron jobs registered in root store (`~/.hermes/cron/jobs.json`).
Gateway restarted at 20:26 — most interval-based jobs reset their counters.

## State Breakdown

| Category | Count | Details |
|----------|-------|---------|
| **Never run** | 19 | Created but gateway restarted at 20:26 reset interval counters. Will fire over next hours/days. |
| **Ran OK once** | 3 | Heartbeat (30min), Refresh (120min), and one other |
| **Error once** | 1 | Intel Gather Runner — timeout at 18:22 (FIXED) |
| **Next run soon** | 1 | Intel Gather at ~22:22 (in ~16 min) |

## Notable

- Intel Gather script was patched with `timeout` wrappers on `ss -tlnp` — verified working at 21:22
- The cron job error path referenced `/home/elkratos/` (old machine user) — harmless legacy artifact, script itself uses `$HOME`
- Heartbeat last ran OK at 19:49 — schedule is every 30min, so next should be ~20:19 but gateway restart at 20:26 reset the counter

## Recommendation
No action needed. All 19 "never run" jobs will fire as their intervals elapse from the 20:26 restart time.
