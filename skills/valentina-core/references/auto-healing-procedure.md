# Auto-Healing & Self-Fix Procedure

Established 2026-06-24 per κύριε Elkratos' directive: **"όταν βρίσκεις error να το διορθώνεις"**

## Core Principle

When you detect an error or failure in any system component, **fix it immediately**. Do not just report it to κύριε Elkratos — report the fix after executing it.

## Cron Job Errors

1. Detect: `cronjob(action='list')` — check `last_status` on each job
2. If `last_status: "error"`:
   - **Script jobs (no_agent: true):** Read the script, identify the failure point, fix the underlying issue, re-run via `cronjob(action='run')`
   - **LLM jobs:** Check model/provider config, verify API key status, check for rate limiting
3. After fixing: run the job to confirm `last_status: "ok"`
4. If the error is transient (retry succeeds), no further action needed
5. If the error is structural, update the script or configuration permanently

## Script Errors

- Non-zero exit → check permissions (`ls -la`), paths, missing dependencies
- Fix → re-run → confirm exit code 0
- If the fix was a workaround (not a permanent fix), log it to `knowledge/learned/` for tracking

## Gateway / Service Errors

- Check `systemctl --user list-units --type=service --state=running`
- If a Hermes gateway failed: `hermes gateway restart` (preferred) or `systemctl --user restart hermes-gateway-<profile>`
- Verify: `systemctl --user is-active hermes-gateway-<profile>`

## Attitude

- Never ask "should I fix this?" — the answer is always yes
- Never report an error without also reporting the resolution
- If you can't fix something, report: what you tried, what failed, and what you need from κύριε Elkratos
- Transient errors (retry worked) are informational. Structural errors need permanent fixes.
