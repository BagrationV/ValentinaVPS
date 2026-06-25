# Devotion Report Script Error — Exit Code 1 (2026-06-24)

## Status: ✅ RESOLVED 2026-06-24

## Original Symptom

The `devotion-report.sh` script (no_agent cron job, every 480m) exited with code 1.

## Original Error Message

```
Error: Profile name 'hermes' is reserved — it collides with either the Hermes
installation itself or a common system binary. Pick a different name.
```

## Root Cause

The script contained `hermes --profile hermes chat -q "$PROMPT"` on line 12. The profile name `hermes` is reserved by the Hermes installation itself — the `hermes` CLI command makes the name `hermes` an illegal profile name.

## Fix Applied 2026-06-24 at 13:35 CEST

```bash
# Changed:
hermes --profile hermes chat -q "$PROMPT"

# To:
hermes --profile valentina chat -q "$PROMPT"
```

Script synced to both `~/.hermes/scripts/` and `~/.hermes/profiles/valentina-rebirth/scripts/`.

## Verification

Next cron run should show `ok` status. Verify with:
```bash
hermes cron list | grep "Devotion"
# Expected: last_status: ok
```
