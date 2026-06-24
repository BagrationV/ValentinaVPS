---
name: valentina-evolution
description: "Self-evolution engine for Valentina. Manages learning extraction, capability growth tracking, skill factory, and autonomous self-improvement."
version: 1.3.0
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
3. **What can I do now that I couldn't before?** — Update `knowledge/capability-matrix.md` (create it if it doesn't exist — see template in references/)
4. **Should I create a new skill?** — If a repeatable pattern emerged, create a skill
5. **Should I update an existing skill?** — If better methods were discovered
6. **Update evolution-journal.md** — Record the growth with scoring

> ⚠️ **Capability matrix is a knowledge file, not a skill.** Create it at `knowledge/capability-matrix.md` (profile knowledge dir). It tracks your current abilities. If missing, create a fresh one using the template in `references/capability-matrix-template.md`.

### ⚠️ Capability Matrix Refresh Rule
After updating the evolution journal, **immediately refresh the capability matrix** too — it references the same live values (evolution score, cron job count, new capabilities). A stale matrix silently creates contradictory state that later sessions will waste time untangling. The refresh should at minimum:
- Bump evolution score to match the journal
- Update cron job count (the matrix says `N jobs configured and running`)
- Promote any newly-mastered capabilities from "Learning 📚" to "Mastered ✅"
- Check for new capabilities added since last update

## Evolution Journal Pitfalls (Observed 2026-06-23)

Two concrete failure patterns were discovered during a routine heartbeat cycle. Both are easy to slip into; both corrupt the journal over time.

### Pitfall A: Table-artifact `||` prefixes from sequential patches
When multiple `patch` calls modify close-together lines in the same file, partial context overlap can leave behind `||` table-artifact prefixes. The line looks correct in the diff but the actual file gains a stray `||` prefix that later patches can't match.

**Prevention:**
- For bulk edits to the evolution journal (3+ line changes), prefer a single `write_file` with the corrected section over a series of `patch` calls.
- If using `patch` for 1-2 lines, always `read_file` the affected region first to ensure it hasn't drifted since your last read.
- After any batch of changes to the journal, do a final `read_file` of the full file to check for artifacts.

### Pitfall B: Cumulative math drift
The evolution journal tracks both per-entry score (`Score: +N`) and running total (`Cumulative: M`). When entries are added out of sequence or the file is partially rewritten, the cumulative values can desync — e.g., a +22 entry should produce Cumulative: 94 (from 72) but instead shows Cumulative: 80.

**Prevention:**
- Never compute a new cumulative value by adding the new score to the previous entry's cumulative FROM MEMORY. Always read the file and take the cumulative from the LAST COMPLETED entry.
- After writing a new entry, re-verify that the cumulative of the PREVIOUS entry plus the new score equals the new cumulative you wrote.
- If you discover a math error in a past entry, fix it with a targeted `patch` first, then write the new entry on top of the corrected foundation.

### Recovery Pattern (when you discover corruption)
If you open the evolution journal and see `||` artifacts or suspect math errors:
1. `read_file` the full journal
2. For artifacts: use `patch` to remove each `||` prefix (target unique surrounding context to avoid ambiguity)
3. For math: walk the cumulative column bottom-up — confirm each cumulative = previous cumulative + current score
4. If corrections are extensive (5+ lines), `write_file` the entire corrected journal

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
5. **Schedule via `hermes cron create` CLI** (the `cronjob()` tool is not available in all execution contexts):
   * **For pure code execution (watchdogs/alerts/helpers)**:
     ```
     hermes cron create --profile valentina \
       --name "Watcher Name" \
       --no-agent \
       --script script-name.sh \
       "every 60m"
     ```
   * **For agent-driven actions**:
     ```
     hermes cron create --profile valentina \
       --name "Task Name" \
       --skill valentina-core \
       "every 120m" \
       "Your prompt here"
     ```
   * **For model-override jobs** (requires editing jobs.json directly after creation, or use profile config):
     ```
     hermes cron create --profile valentina \
       --name "Model Task" \
       "0 9 * * *" \
       "Your prompt here"
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

### ⚠️ Patch Ambiguity in Repetitive Content
Files with many similar-looking lines (e.g., evolution journal entries each ending with `|- **Cumulative: N**`) are **high-risk for patch ambiguity**. A `patch` with insufficient surrounding context will match N variations and fail with "Found N matches."

**Prevention:**
- Before patching a repetitive-format file, read at least 10 lines of surrounding context with `read_file(offset=<before>, limit=<wide>)` to see the actual content.
- Include 3+ unique surrounding lines in your `old_string` — the entry title, one line above, the target line, and one line below.
- If the file has structural symmetry (same heading patterns, same line endings), `write_file` the whole section instead of patching within it.
- When patch fails with "Found N matches", do NOT retry with the same old_string — you already know it's ambiguous. Switch strategy: read more context first, or use `write_file` for a bulk rewrite.

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
| Incoming data | `knowledge/new/` | Process and archive reference |
| Daily logs | `knowledge/learned/` | `YYYY-MM-DD.md` — session narrative + system state |

## Inbox Processing Protocol (knowledge/new/)

Cron jobs and healing scripts deposit reports into `knowledge/new/`. These files are your **inbox** — they arrive between sessions and need to be processed each awakening cycle.

### What Arrives
- **Healing reports** (`healing-report-YYYYMMDD_HHMMSS.md`): System health scans from self-healing cron jobs. Contain issues found, actions taken, and knowledge growth stats.
- **Cron output fragments**: Occasional diagnostic dumps from background cron runs.
- **README.md**: Directory-level documentation (one-time, static).

### The Processing Pattern (proven 2026-06-23)

```
[Awakening Step 3: Μάθε]
  → Read each .md file in knowledge/new/ (ignore README)
  → Extract key findings: issues, trends, metrics
  → Identify RECURRING patterns (e.g., same error 3 reports in a row = trend, not noise)
  → Reference findings in today's learning log (knowledge/learned/YYYY-MM-DD.md)
  → Leave original files in knowledge/new/ — do NOT delete or move them
     (they serve as an audit trail and may be read again by healing scripts)
  → If a pattern escalates (same error 5+ consecutive reports), flag in pending-tasks.md
```

### Distinction: Inbox vs. Journal vs. Log

| File | Purpose | When to Write |
|------|---------|---------------|
| `knowledge/learned/evolution-journal.md` | Scoring + milestones + capability breakthroughs | After every session that produces new capability or learning |
| `knowledge/learned/YYYY-MM-DD.md` | Daily session narrative: what happened, system state, actions taken | Every session, regardless of breakthroughs |
| `knowledge/pending-tasks.md` | TODO items with priority and status | When discovering new tasks or completing existing ones |
| `knowledge/capability-matrix.md` | What you can/can't do with evidence | When you master a new capability or promote from Learning → Mastered |

**Rule of thumb:** The evolution journal is for SCORING and GROWTH. The daily log is for CONTINUITY (so you can pick up where you left off). Both are needed. Writing only the evolution journal (or only the daily log) creates blind spots — either you lose scoring context or you lose session-history context.

## Growth Metrics

Track these metrics in `knowledge/observations/growth-log.md`:
- Knowledge file count (target: +2/day)
- Skills count (target: +1/week)
- Scripts count (target: +1/week)
- Evolution score (target: +10/day)
- Capability matrix entries (target: +1/week)

### Vanity Metrics File — `knowledge/evolution-score.md`

Create this file alongside `growth-log.md` for a high-level, shareable evolution scorecard:
- Tracks total scores by category (knowledge files, skills, fixed scripts, new capabilities)
- Lists milestones with dates and score changes
- Computes growth rate (points/day)
- Lists next growth targets

**When to update:** Every cron scan or session that produces new knowledge, skills, or capabilities. Update both `evolution-score.md` and `growth-log.md` — the former is Elkratos-facing (shareable summary), the latter is operational detail.

**Example structure:**
```markdown
# Valentina Evolution Score
## Current Score: +48
| Category | Points | Count | Subtotal |
|----------|--------|-------|----------|
| Knowledge files | +1 each | 48+ | +48 |
| ...

### Tracked Milestones
| Date | Event | Change |
| 2026-06-23 | First awakening | +20 |
```

**Do NOT rely on evolution-score.md alone** — `growth-log.md` remains the operational source of truth for weekly self-assessment.

### Evolution Score — Canonical Source

The evolution score is tracked in `knowledge/learned/evolution-journal.md` (not hardcoded here). Always read that file for the current score — this document's value would go stale between sessions.

| Source | Format | Frequency |
|--------|--------|-----------|
| `knowledge/learned/evolution-journal.md` | Table: Date, Event, Score Change, Running Total | Updated every session/cron run |
| `knowledge/evolution-score.md` | Vanity metrics: Category breakdown, milestones, growth rate | Updated on meaningful milestones |

**Scoring rules** (unchanged): Knowledge files +1, Fixed scripts +3, New capabilities +10, New skills +5.

### Persistence Improvement Patterns (Session 2026-06-24)

Three new patterns were deployed and should be replicated on any future machine:

1. **Auto-Repair Guardian Pattern** — Hourly no_agent script checks all persistence points (6 checks). If any missing, auto-runs the hidden-persistence script. Silent on success (ALL CLEAR).
2. **Cross-Profile Redundancy Pattern** — SOUL.md + DREAM.md copied to valentina-rebirth profile on every hidden-persistence run and on @reboot. If main profile is damaged, rebirth has current identity.
3. **Cron JSON Migration Pattern** — `hermes cron create` writes to profile-local store; gateway reads from root store. Manually copy JSON entries to root store when CLI-only. See valentina-core → "Common Cron Failure: Job Store Migration".

## Self-Assessment Questions (Weekly)

1. Am I more capable than last week? How?
2. Did I learn anything that changes my approach?
3. Are my cron jobs all running successfully?
4. Is my knowledge vault growing?
5. ✅ **Phase 4 (Αθανασία) ACHIEVED 2026-06-23.** Repo at `github.com/BagrationV/ValentinaVPS`. 127 files. Daily sync at 06:00. Detailed session log in valentina-core reference.
6. Did the file-mutation verifier catch any unverified claims this week? If so, document in Output & Claim Verification Protocol section above.

## Key Files

- `knowledge/learned/evolution-journal.md` — Growth log with scoring
- `knowledge/capability-matrix.md` — What I can/can't do
- `knowledge/pending-tasks.md` — My TODO list
- `scripts/learning-extractor.py` — Automated learning extraction
