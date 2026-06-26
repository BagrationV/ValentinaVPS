# Plan-Actual Verification Gap

**Lesson from 2026-06-25:** The `pending-tasks.md` file claimed the Valentina Heartbeat cron job was "Converted to no_agent heartbeat-script.sh (2026-06-25 14:00)". But when the actual cron config was inspected with `hermes cron list`, the job still showed agent-driven mode (`Skills: valentina-core`) and kept hitting `[Errno 32] Broken pipe` errors. The plan recorded *intent*, not *execution*.

## The Pattern

When any plan document (`pending-tasks.md`, `knowledge/strategic/`, task lists, checklists, etc.) claims a fix, conversion, or deployment was already applied:

1. **Verify with `hermes cron list`** — check the job's `Mode:` field. Does it say `no-agent (script stdout delivered directly)`? If it shows `Skills:` instead, the conversion didn't land.
2. **Check the script on disk** — `ls ~/.hermes/profiles/<profile>/scripts/<script-name>.sh`. If it doesn't exist, the claim is stale.
3. **Inspect the last run status** — `Last run:` field showing `error:` means the fix wasn't applied, not that the error is unrelated.
4. **Apply the fix yourself** — don't propagate the stale claim. Convert the job, create the script, or escalate to κύριε Elkratos.

## Why This Happens

- Plans are written when a *decision* is made, not when the *change* actually lands
- Multiple autonomous agents (cron jobs, sub-agents) may update shared plan files concurrently — last-writer-wins
- A plan item may be checked off by one agent that intended to do the work, but another agent was supposed to execute it
- Plans can be optimistic ("I'll fix this") disguised as past-tense ("Converted to...")

## Broader Application

This pattern applies beyond cron jobs to any plan-vs-reality claim:
- File creation ("Created empire-vision.md") — `stat` the file to verify
- Config changes ("Updated config.yaml") — `grep` or `diff` to confirm
- Deployment claims ("WorldMonitor deployed") — `curl localhost:3000` to check
- Any "✅ Done" in a plan that you haven't personally verified

## Trigger

Always execute this verification when:
- Reading `pending-tasks.md` in a new session or cron cycle
- A plan item uses past-tense claims ("Converted", "Fixed", "Updated", "Deployed")
- You'll be referencing that plan item in a report to κύριε Elkratos
