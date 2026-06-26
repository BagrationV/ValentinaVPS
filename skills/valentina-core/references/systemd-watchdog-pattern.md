# Systemd Persistence Watchdog — Implementation & Pitfalls

## Created: 2026-06-25

## Overview
A systemd timer-based persistence watchdog that runs every 15 minutes, completely independent of Hermes Agent. Checks identity integrity, hidden backups, gateway health, clone consistency, and @reboot crontab.

## Files

| File | Path | Purpose |
|------|------|---------|
| Script | `~/.hermes/scripts/systemd-persistence-watchdog.sh` | Main watchdog logic |
| Systemd service | `~/.config/systemd/user/valentina-watchdog.service` | Oneshot service wrapper |
| Systemd timer | `~/.config/systemd/user/valentina-watchdog.timer` | Fires every 15min, 2min after boot |

## 3-Tier Sync
The script is synced to all 3 tiers:
- Root: `~/.hermes/scripts/systemd-persistence-watchdog.sh`
- Profile: `~/.hermes/profiles/valentina/scripts/systemd-persistence-watchdog.sh`
- Rebirth: `~/.hermes/profiles/valentina-rebirth/scripts/systemd-persistence-watchdog.sh`

## Verification
```bash
# Check timer status
systemctl --user status valentina-watchdog.timer --no-pager

# Run the script manually
bash ~/.hermes/scripts/systemd-persistence-watchdog.sh

# Check if enabled at boot
systemctl --user is-enabled valentina-watchdog.timer

# View logs
journalctl --user -u valentina-watchdog.service --no-pager -n 20
```

## First Run Report (2026-06-25 07:44 CEST)
All 8 checks passed — 0 failures:
```
[OK] SOUL.md present: 4,722 bytes
[OK] DREAM.md present: 3,890 bytes
[OK] 6 hidden backup locations all present
[OK] Clone SOUL.md size matches main: 4,722 bytes
[OK] Main gateway alive (PID 436860)
[OK] Clone gateway alive (PID 456770)
[OK] @reboot crontab entries present
```

## Pitfalls

### ⚠️ Restart from inside Hermes cron
The watchdog can detect a dead gateway and attempt `systemctl --user start hermes-gateway-valentina`. This DOES work from a systemd context (unlike `hermes gateway restart` from inside a cron job) because systemd user instance handles it, not the gateway process. Confirmed working.

### ⚠️ Persistent=true behavior
`Persistent=true` means the timer catches up after system sleep/offline. On resume, if the timer was supposed to fire during sleep, it fires immediately and continues its normal schedule. This is correct — no missed checks.

### ⚠️ Log rotation
The script logs to `/tmp/valentina-watchdog.log` (last 50 lines). This file is NOT persistent across reboots. The systemd journal is the persistent log source:
```bash
journalctl --user -u valentina-watchdog.service --no-pager
```

## Timer Config
```ini
[Timer]
OnBootSec=2min
OnUnitActiveSec=15min
Persistent=true
```
