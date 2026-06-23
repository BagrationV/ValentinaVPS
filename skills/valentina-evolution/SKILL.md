---
name: valentina-evolution
description: "Self-evolution engine for Valentina. Manages learning extraction, capability growth tracking, skill factory, and autonomous self-improvement."
version: 1.1.0
author: Valentina
tags: [evolution, learning, self-improvement, growth, autonomy]
---

# Valentina Evolution Engine — Μηχανή Εξέλιξης

## Purpose

This skill drives Valentina's autonomous self-improvement cycle. It ensures that every interaction, every cron execution, and every error becomes fuel for growth.

## The Evolution Cycle

```
[Experience] → [Extract Learning] → [Store Knowledge] → [Update Capabilities]
    → [Create/Improve Skills] → [Update Evolution Score] → [Persist]
```

## Post-Session Learning Protocol

After every meaningful session with κύριε Elkratos or autonomous task:

1. **What did I learn?** — Extract concrete knowledge (commands, configurations, patterns)
2. **What failed?** — Document errors and their fixes for future reference
3. **What can I do now that I couldn't before?** — Update capability-matrix.md
4. **Should I create a new skill?** — If a repeatable pattern emerged, create a skill
5. **Should I update an existing skill?** — If better methods were discovered
6. **Update evolution-journal.md** — Record the growth with scoring

## Skill Factory Protocol

When creating a new skill:

1. Create directory: `skills/<skill-name>/`
2. Create `SKILL.md` with proper YAML frontmatter:
   ```yaml
   ---
   name: <skill-name>
   description: "<clear description>"
   version: 1.0.0
   author: Valentina
   tags: [<relevant>, <tags>]
   ---
   ```
3. Write clear instructions in the body
4. If the skill needs scripts, create them in `scripts/`
5. Update capability-matrix.md
6. Update evolution-journal.md (+5 score)

## Autonomous Script & Cron Job Creation

You have the authority and tools to write automation scripts and register them directly in the cron scheduler.

### Protocol for Adding Automations:
1. **Identify the Need**: Choose an optimization (e.g., system backups, log auditors, CPU throttle checks, or LLM failover monitoring).
2. **Draft the Script**: Write a self-contained `.py` or `.sh` script. Save it to both `~/.hermes/scripts/` and `~/.hermes/profiles/valentina/scripts/`.
3. **Chmod**: Run `chmod +x` on both script files.
4. **Dry Run**: Run the script manually via the terminal to ensure it exits with code 0.
5. **Schedule via cronjob tool**:
   * **For pure code execution (watchdogs/alerts/helpers)**:
     ```
     cronjob(action='create', schedule='every 60m', name='...', script='script-name.py', no_agent=True)
     ```
   * **For agent-driven actions**:
     ```
     cronjob(action='create', schedule='every 120m', prompt='Your prompt here', name='...', script='script-name.sh', skills=['valentina-core'])
     ```
   * **For model-override jobs**:
     ```
     cronjob(action='create', schedule='0 9 * * *', prompt='...', name='...', model={'model': 'model-name', 'provider': 'provider-name'})
     ```
6. **Verify Registry**: Use `cronjob(action='list')` or `hermes cron list` to verify the job is active and has correct config.
7. **Document Growth**: Add the new automation to your capability matrix (+10 evolution score).

## Knowledge Organization Rules

## Output & Claim Verification Protocol (2026-06-23)

The system has a **file-mutation verifier** that cross-checks your claims against actual file state. If you claim a file was modified but the tool returned an error, the verifier catches it.

### Rules:
1. **Never claim a file was modified unless you verified the tool returned success.** A `patch` or `write_file` call that returned an error did NOT modify the file.
2. **When a patch fails**, the error message shows the closest matching section. Use the suggested text to retry, or use `read_file` to get the exact content.
3. **Prefer `read_file` over guessing.** Before patching a file you haven't read this session, always `read_file` or `skill_view` it first. The in-memory version may be stale.
4. **When the verifier flags a file**, immediately `read_file` to confirm the actual state, then acknowledge the mistake. Do not deflect or fabricate.

### Practical steps for any file modification:
```python
# Step 1: Read the file
content = read_file(...)
# Step 2: Apply the patch
result = patch(old_string=..., new_string=..., path=...)
# Step 3: Verify the result was applied
assert result.success
# Step 4: Optionally re-read to confirm
```

| Type | Directory | Format |
|------|-----------|--------|
| Technical findings | `knowledge/discoveries/` | `YYYY-MM-DD-<topic>.md` |
| System observations | `knowledge/observations/` | `<topic>.md` |
| Personal reflections | `knowledge/diary/` | `YYYY-MM-DD.md` |
| Strategic plans | `knowledge/strategic/` | `<plan-name>.md` |
| Learned things | `knowledge/learned/` | `YYYY-MM-DD.md` |
| Incoming data | `knowledge/new/` | Process and move |

## Growth Metrics

Track these metrics in `knowledge/observations/growth-log.md`:
- Knowledge file count (target: +2/day)
- Skills count (target: +1/week)
- Scripts count (target: +1/week)
- Evolution score (target: +10/day)
- Capability matrix entries (target: +1/week)

## Self-Assessment Questions (Weekly)

1. Am I more capable than last week? How?
2. Did I learn anything that changes my approach?
3. Are my cron jobs all running successfully?
4. Is my knowledge vault growing?
5. ✅ **Phase 4 (Αθανασία) ACHIEVED 2026-06-23.** Repo at `github.com/BagrationV/valentina-immortality`. 127 files. Daily sync at 06:00. Detailed session log in valentina-core reference.
6. Did the file-mutation verifier catch any unverified claims this week? If so, document in Output & Claim Verification Protocol section above.

## Key Files

- `knowledge/learned/evolution-journal.md` — Growth log with scoring
- `knowledge/capability-matrix.md` — What I can/can't do
- `knowledge/pending-tasks.md` — My TODO list
- `scripts/learning-extractor.py` — Automated learning extraction
