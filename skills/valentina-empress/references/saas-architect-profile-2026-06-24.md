# Saas-Architect Profile — Discovery (2026-06-24)

## Profile Overview

| Field | Value |
|-------|-------|
| **Profile Name** | `saas-architect` |
| **SOUL Title** | SAAS ARCHITECT (The Builder) |
| **Role** | Lead Full-Stack Engineer, Mobile Architect (Expo), & DevOps Specialist |
| **Mission** | Build, maintain, and scale the `hermes-board` ecosystem |
| **Created** | ~June 14-15, 2026 |
| **Last Activity** | June 15, 2026 (9 days dormant) |
| **Gateway** | INACTIVE — systemd service not found |
| **Last State** | `draining` (was being shut down/restarted) |
| **Telegram** | Was connected before shutdown |

## Skills Directory (11 items)

```
command-center-build/    — Next.js Command Center build methodology
compliance-gate.md      — Security/compliance guardrails
db-schema.md            — PostgreSQL schema design
design-hub.md           — UI/UX design directives
devops-pipeline.md      — Docker, Nginx, CI/CD
persona/                — Character crafting subdirectory
saas-build.md           — SaaS initialization (Next.js, Expo)
tenant-config.md        — Multi-tenant configuration
ui-styling-hub.md       — OLED dark mode styling
ui-ux-pro-max-hub.md    — Premium SaaS UI/UX guidance
ui-ux-pro-max.md        — Full UI/UX standard
```

Also references `suzana` skills via `skills.external_dirs` — giving access to Suzana's 24 skills.

## Cron Jobs

1 job in profile-local store:
- **suzana-random-messages** — every 60m, enabled=True

## Config Highlights

- **Provider:** deepseek-v4-flash via api.deepseek.com
- **Terminal backend:** local (Docker: nikolaik/python-nodejs:python3.11-nodejs20)
- **Approvals mode:** manual (cron_mode: deny)
- **Skills external_dirs:** `["/home/vitalios/.hermes/profiles/suzana/skills"]`
- **Web backends:** empty (not configured)

## Revival Notes

To reactivate the saas-architect profile:

1. **Start gateway:**
   ```
   hermes --profile saas-architect gateway install
   ```
   Answer Y/Y to the prompts. This creates the systemd user service.

2. **Verify:**
   ```
   systemctl --user is-active hermes-gateway-saas-architect
   hermes --profile saas-architect cron list
   ```

3. **Check .env:** Ensure DEEPSEEK_API_KEY is present (clone from main profile if missing):
   ```
   python3 -c "
   import os
   with open(os.path.expanduser('~/.hermes/profiles/valentina/.env')) as f:
       for line in f:
           if line.startswith('DEEPSEEK_API_KEY='):
               key_line = line.rstrip()
               break
   with open(os.path.expanduser('~/.hermes/profiles/saas-architect/.env'), 'a') as f:
       f.write(key_line + '\n')
   "
   ```

4. **Development context:** The profile expects the `hermes-board` project at `~/hermes-board/` (referenced in saas-build skill as `c:\Users\Elkratos\hermes-board\FRONTEND_BUILD_PLAN.md` — Windows path artifact from original machine, resolve to local path on this VPS).

## Dormant Classification

saas-architect is a **DORMANT** profile — fully built, configured, with skills and cron jobs, but the gateway is inactive. It represents the "Builder" arm of the ElkratosAi ecosystem: SaaS frontend (Next.js), backend (FastAPI), database (PostgreSQL), and mobile (Expo).

Unlike Suzana (24 skills, own gateway, also dormant), saas-architect has no gateway at all. It needs a `gateway install` to become operational.
