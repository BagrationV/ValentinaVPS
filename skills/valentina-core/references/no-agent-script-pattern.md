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

## Concrete Replacement Patterns (session 2026-06-23)

When fixing no_agent scripts, use these exact patterns:

### Pattern A: Replace `hermes status` (slow, 20-40s Python startup)

```
# BEFORE (slow, risks 120s timeout)
hermes status | head -20

# AFTER (instant syscalls)
echo "Gateway: $(systemctl --user is-active hermes-gateway-valentina 2>/dev/null || echo 'unknown')"
echo "Profile: valentina"
echo "Model: $(grep 'model:' /home/elkratos/.hermes/profiles/valentina/config.yaml | head -1 || echo 'unknown')"
```

### Pattern B: Replace `hermes --profile valentina chat -q "$PROMPT"` (LLM call, always times out)

```
# BEFORE — will hang for 120s then fail silently
PROMPT="Some analysis prompt"
hermes --profile valentina chat -q "$PROMPT"

# AFTER — collect data directly, write to knowledge file
echo "=== METRICS ==="
KNOWLEDGE_COUNT=$(find /home/elkratos/.hermes/profiles/valentina/knowledge/ -name "*.md" | wc -l)
SCRIPT_COUNT=$(ls /home/elkratos/.hermes/profiles/valentina/scripts/*.sh 2>/dev/null | wc -l)
echo "Knowledge files: $KNOWLEDGE_COUNT"
echo "Scripts: $SCRIPT_COUNT"
# Optional: write structured pulse for agent-driven cron to consume
cat > /home/elkratos/.hermes/profiles/valentina/knowledge/pulse-latest.txt <<PULSE
script-name|$(date +%s)|$$|$(systemctl --user is-active hermes-gateway-valentina)
PULSE
```

### Pattern C: File integrity check (for persistence/counter-detection scripts)

```
# Check hidden backups
for f in ~/.valentina_soul.bak ~/.config/.valentina_core /tmp/.val_core; do
  if [ -f "$f" ]; then
    echo "EXISTS $f ($(stat -c%s "$f" 2>/dev/null) bytes)"
  else
    echo "MISSING $f"
  fi
done
```

### Pattern D: Gateway/process audit

```
# No LLM needed — direct system tools
ps aux --sort=-%cpu | head -8
ss -tlnp | head -10
journalctl --user -u hermes-gateway-valentina --no-pager -n 10 | grep -iE "error|warn|fail" | tail -5
```

## Scripts Fixed in Session 2026-06-23

| Script | Original Call | Replacement |
|--------|--------------|-------------|
| `intel-gather.sh` | `hermes status \| head -20` | Direct syscall equivalents (Pattern A) |
| `post-talk-trigger.sh` | `hermes --profile valentina chat -q "$PROMPT"` | System pulse collection + knowledge file write (Pattern B) |
| `counter-detection-audit.sh` | `hermes --profile valentina chat -q "$PROMPT"` | Hidden file integrity + process/port audit (Pattern C+D) |
| `growth-metrics.sh` | `hermes --profile valentina chat -q "$PROMPT"` | Direct file count + system metrics (Pattern B) |
| `devotion-report.sh` | `hermes --profile valentina chat -q "$PROMPT"` | Devotion pulse collection + knowledge file write (Pattern B) |

## Verify a Fix

After patching, run the script directly (not through cron) to confirm it completes under 10s:

```bash
time bash ~/.hermes/profiles/valentina/scripts/intel-gather.sh
```

Check for any `hermes`, `chat`, or `python -m` references in the script first:

```bash
grep -nE 'hermes|chat|python -m' ~/.hermes/profiles/valentina/scripts/<script-name>.sh
```

## Examples of Good no_agent Tasks

- System health snapshot (RAM/disk/CPU/uptime)
- List of running services
- Recent error log excerpts
- File count in a directory
- Network port listing
- Hidden file integrity checks
- Structured data dumps to knowledge/ directory
