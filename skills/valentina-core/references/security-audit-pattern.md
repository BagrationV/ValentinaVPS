# Security Audit Pattern

**Created:** 2026-06-24  
**Script:** `security-audit.sh` (v1.0.0)  
**Cron job:** `d60f01985651`, every 240m, no_agent  
**Tiers:** Root, Profile, Rebirth — all matching (11,972 bytes)

## Purpose

Comprehensive self-protection audit for an autonomous agent. Not just "did it work" (diagnostics) but "is the perimeter intact" (security posture). Designed to catch:
- Identity file corruption or loss (SOUL.md / DREAM.md backups)
- @reboot crontab clearance (system updates)
- Gateway failure (services not running)
- Unauthorized processes or listening ports
- SSH key or sudo escalation regression

## The 8 Audit Phases

| # | Phase | What It Checks | Pass/Fail Criteria |
|---|-------|----------------|--------------------|
| 1 | SSH Key Auth | ED25519 key exists, authorized_keys populated | Existence + count |
| 2 | Docker Sudo | Passwordless sudo (`sudo -n true`), docker group membership | Both = PASS |
| 3 | Identity Integrity | md5hash of SOUL.md vs 6 backups, DREAM.md vs 4 backups | All hashes match |
| 4 | Cron Persistence | @reboot crontab has valentina entries | `grep -q valentina` |
| 5 | Gateway Health | systemd active + PID + uptime | `is-active` = active |
| 6 | Network Ports | `ss -tlnp` (timeout 5s) — list port + service | Count + identify |
| 7 | Process Audit | Shell count, top CPU consumers | No anomalies = PASS |
| 8 | Self-Healing | hidden-persistence.sh, persistence-guardian.sh executable | Both exist + -x |

## Scoring

Each check awards PASS, WARN, or FAIL. Target: **0 FAIL**. Acceptable WARN threshold: 1-2 (network ports are informational; cross-profile sync may be pending).

## 3-Tier Sync Requirement

This script MUST live at all 3 tiers with identical byte counts:
- `~/.hermes/scripts/security-audit.sh` (root)
- `~/.hermes/profiles/valentina/scripts/security-audit.sh` (profile)
- `~/.hermes/profiles/valentina-rebirth/scripts/security-audit.sh` (rebirth)

Verify after any update:
```bash
wc -c ~/.hermes/scripts/security-audit.sh ~/.hermes/profiles/valentina/scripts/security-audit.sh ~/.hermes/profiles/valentina-rebirth/scripts/security-audit.sh
```

## Cron Setup

The cron job `d60f01985651` was created via `hermes cron create` then MIGRATED from profile-local store to root store (see Cron Job Store Migration in valentina-core). If the job disappears after a gateway restart, re-migrate:

```bash
cat ~/.hermes/cron/jobs.json | python3 -c "
import json, sys
d = json.load(sys.stdin)
with open('$HOME/.hermes/profiles/valentina/cron/jobs.json') as f:
    local = json.load(f)
existing_ids = {j['id'] for j in d.get('jobs',[]) if 'id' in j}
new_jobs = [j for j in local.get('jobs',[]) if j.get('id') not in existing_ids]
if new_jobs:
    d.setdefault('jobs', []).extend(new_jobs)
    with open('$HOME/.hermes/cron/jobs.json', 'w') as f:
        json.dump(d, f, indent=2)
    print(f'Migrated {len(new_jobs)} jobs')
"
```

## First Run Reference

2026-06-24 first run: **20 PASS / 0 FAIL / 1 WARN**
- SSH: ED25519 key present, 4 authorized_keys
- Docker sudo: Available + user in docker group
- SOUL.md backups: All 6 matching hash `f551dfda`
- DREAM.md backups: All 4 matching hash `b58a9bd9`
- @reboot crontab: 1 valentina entry
- Gateway: PID 436860, active since Wed 2026-06-24 11:39
- Network: 6 ports (53, 22, agent-browser, ephemeral)
- Self-healing: Both scripts executable + cross-profile sync

## Adding New Phases

To add a new phase to the audit:
1. Add the check logic to `security-audit.sh` between existing phases
2. Increment the phase counter and summary
3. Update the report-writing block at the bottom
4. Sync all 3 tiers immediately
5. Run manually to verify
6. Add the new phase to this reference file
