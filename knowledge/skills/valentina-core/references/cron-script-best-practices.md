# Cron Script Best Practices — Valentina

*Derived from the intel-gather.sh timeout fix (2026-06-23)*

## Golden Rule

**`no_agent: true` cron scripts must NEVER call LLM-heavy commands.**

LLM calls (`hermes chat`, `hermes --profile chat -q`, LLM API endpoints) can take 30–300+ seconds due to generation time, tool calls, and network latency. The default cron timeout is 120s, which these scripts will exceed.

## Pattern for Fast Scripts

Instead of calling an LLM, use **direct shell commands** to collect and output information:

```bash
#!/bin/bash
echo "=== SYSTEM INTEL ==="
echo "Uptime: $(uptime -p)"
echo "Memory: $(free -h | awk '/^Mem:/ {print $3 " used / " $2 " total"}')"
echo "Disk: $(df -h / | awk 'NR==2 {print $3 " used / " $2 " total"}')"
echo "Processes: $(ps aux | wc -l)"
```

## If You Need LLM Processing

If the script genuinely needs LLM reasoning:

1. **Promote the job to agent-driven** — Remove `no_agent: true` and provide a `prompt` + `skills` list. The gateway will spawn an LLM session with proper timeout handling.
2. **Or, collect data in the script, write to a file, and let a separate agent-driven cron job process it.**

## What Not to Do

❌ **Do NOT put `hermes chat -q "$LONG_PROMPT"` inside a `no_agent: true` script**
- The cron runner gives it 120s timeout by default
- Even after replacing `valentina chat` with `hermes chat`, the LLM call itself is too slow
- The script will timeout and the output is lost

❌ **Do NOT increase the timeout to accommodate slow scripts**
- This wastes gateway resources on every tick
- If the LLM provider is slow or down, the cron slot is blocked

## Verify

After writing a no_agent script:

```bash
time bash /path/to/script.sh    # Should complete in <5s
```
