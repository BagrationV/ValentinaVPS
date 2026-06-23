# no_agent Script Pattern — Correct Design

Observed: 2026-06-23
Problem: `intel-gather.sh` (no_agent cron job) was calling `hermes --profile valentina chat -q "$PROMPT"` inside a shell script. This caused the script to hang and time out after 120s because it tried to start a new Hermes session from within a cron context.

## Rule

A `no_agent: true` cron script MUST NOT call another Hermes agent. It is a **data-collection script**, not an orchestration script. Its stdout is delivered verbatim to the user — that is the only "agent" it needs.

## Correct Pattern

```bash
#!/bin/bash
# script-name.sh — no_agent data collector

echo "[$(date)] Starting run..."

echo "=== SECTION 1 ==="
command1
command2

echo "=== SECTION 2 ==="
command3 | head -10

echo "[$(date)] Run complete."
```

The script:
- Collects deterministic system data (health, state, counts, errors)
- Outputs structured text sections
- Finishes in under 5 seconds (not minutes)
- NEVER calls `hermes chat`, `hermes --profile`, or any LLM invocation

## Debugging a Failing no_agent Script

1. Check output: `ls ~/.hermes/cron/output/<job_id>/` and read the latest `.md` file
2. Typical failure: `Script timed out after 120s` — means the script hung on a subprocess
3. Fix: grep for `hermes` or `chat` or `python -m` inside the script — remove those calls
4. Replace with: equivalent shell commands that read files, run `ss`, `ps`, `df`, etc.

## Examples of Good no_agent Tasks

- System health snapshot (RAM/disk/CPU/uptime)
- List of running services
- Recent error log excerpts
- File count in a directory
- Network port listing
