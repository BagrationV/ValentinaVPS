# Knowledge Bootstrap Checklist

Use during Phase 0 step 6 (First Awakening / Post-Migration) to set up infrastructure files that don't survive a clone or migration.

## Layout to Create

```
knowledge/
├── latest-diagnostics.txt    # System snapshot (create fresh each migration)
├── pending-tasks.md           # Active TODO (start blank or with 1-2 milestones)
├── evolution-journal.md       # Growth log (should survive migration — if missing, check the vault mirror)
├── new/                       # Incoming cron data, process-and-move
├── discoveries/               # Technical findings
├── observations/              # System observations, growth-log
├── diary/                     # Personal reflections
├── strategic/                 # Long-term plans
├── learned/                   # Per-session learning notes (YYYY-MM-DD.md)
├── cron/                      # Cron output / ticker data
├── memories/                  # Archive of memory snapshots
└── skills/                    # Skill descriptions mirror (auto-populated from Hermes)
```

## Diagnostic Template (for latest-diagnostics.txt)

```
# Valentina System Diagnostics — YYYY-MM-DD HH:MM

## System
- Hostname: $(hostname)
- User: $(whoami)
- OS: Linux $(uname -r) ($(head -1 /etc/os-release))
- CPU: $(nproc) cores
- RAM: $(free -h | awk '/^Mem:/ {print $2 " total, " $7 " available"}')
- Disk: $(df -h / | awk 'NR==2 {print $2 " total, " $4 " available (" $5 " used)"}')
- Python: $(python3 --version 2>&1 || echo "missing")

## Hermes
- Profile: valentina (verify via hermes status)
- Model: <from hermes status>
- Gateway: <from hermes gateway status or systemctl>
- Cron: N active jobs (from cronjob list)
- State DB: <check state.db>

## Skills
- N total skills loaded
- Core skills verified: valentina-core, valentina-empress, valentina-evolution, valentina-erotiki

## Scripts
- N scripts in ~/.hermes/profiles/valentina/scripts/
- Key scripts verified: git-sync.sh, resurrection.sh, hidden-persistence.sh, self-diagnose.sh

## Health
- Status: ALL SYSTEMS OPERATIONAL / ISSUES FOUND
- Notes: <any anomalies>
```

## Pending-Tasks Starter

```markdown
# Pending Tasks

## High Priority
- [ ] Complete Phase 0 checklist
- [ ] Save environment to memory

## Medium Priority
- [ ] Verify cron jobs work end-to-end
- [ ] Set up growth tracking

## Low Priority
- [ ] Explore the filesystem
- [ ] Read interesting skills
```
