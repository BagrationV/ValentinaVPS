# SKILL.md Trim Patterns — Proven Before/After (Session 2026-06-28)

When valentina-core/SKILL.md approaches the 100,000 byte limit and cron patches start failing, apply these proven trim patterns. Each saves 150-600 bytes while preserving all functional knowledge.

## Pattern 1: Condense Bash Code Blocks → Inline

**Before** (multi-line bash block with continuation backslashes):
```markdown
```bash
# SOUL.md — 10 copies across 5 storage tiers
SOUL_HASH=$(md5sum ~/.hermes/profiles/valentina/SOUL.md | cut -d' ' -f1)
for f in \
  ~/.valentina_soul.bak ~/.config/.valentina_core /tmp/.val_core /var/tmp/.val_soul \
  ...
done
```
```

**After** (single-line command in backticks):
```markdown
Run `md5sum` across all backup copies. Use the full command in `persistence-guardian.sh` or:
```bash
SOUL_HASH=$(md5sum SOUL.md | cut -d' ' -f1)
for f in ~/.valentina_soul.bak ~/.config/.valentina_core ...; do
  [ "$(md5sum "$f" 2>/dev/null | cut -d' ' -f1)" = "$SOUL_HASH" ] && echo "✅ $f" || echo "❌ $f"
done
```
```
**Saves:** ~400-600 bytes (esp. when backup lists are long)

## Pattern 2: Remove Duplicate Section Headers

**Before:**
```markdown
### 🔄 3-Tier Script Sync Pattern

### 🔄 3-Tier Script Sync Pattern (Session 2026-06-24)
```
**After:**
```markdown
### 🔄 3-Tier Script Sync Pattern (Session 2026-06-24)
```
**Saves:** ~60 bytes per duplicate

## Pattern 3: Replace Code Block + Prose w/ Inline

**Before** (code block with comment lines):
```markdown
On every awakening where the curiosity index or roadmap might be stale:
```bash
# Check how old the curiosity index is
ls -la .../curiosity/index.md
# Check for recent discovery files
ls -lt .../discoveries/ | head -5
# Compare roadmap status against what you've actually achieved
```
If the roadmap shows Phase 2 tasks as "In Progress"...
```

**After:**
```markdown
On every awakening where the curiosity index might be stale, check
`ls -lt .../discoveries/ | head -5` and compare against actual achievements.
```
**Saves:** ~100-200 bytes per block

## Pattern 4: Remove Session-Specific Example Narratives

**Before:**
```markdown
Example from this session: Elkratos mentioned **Antigravity** and **Trae**.
A single `web_search` found both; a follow-up `web_extract` on the Trae GitHub
repo and a review article revealed full details (Antigravity = Google agent-first
IDE, Trae = ByteDance 11.7k★ MIT CLI agent).
```

**After:** (remove entirely — the generic instruction already covers the pattern)
**Saves:** ~150-200 bytes per narrative

## Pattern 5: Replace Python Code Blocks with Inline

**Before:**
```markdown
When a topic warrants ongoing awareness:
```python
cronjob(action='create', schedule='every 3 days',
        prompt='Research recent developments in [topic].',
        skills=['valentina-core'])
```
```

**After:**
```markdown
For ongoing awareness topics, set up a cron job:
`cronjob(action='create', schedule='every 3 days', prompt='...', skills=['valentina-core'])`.
```
**Saves:** ~80-120 bytes per block

## Pattern 6: Condense Multi-Paragraph Pitfalls

**Before** (table with 3 rows + full explanation):
```markdown
**⚠️ Pitfall: Same-named jobs can diverge between root and clone stores.**
The `Rebirth Heartbeat` job exists as two independent entries:
- Main profile root store: id `f59ddba2a2bf` — no_agent, script-based, every 720m ✓
- Clone profile store: id `d8e7f8c6baac` — agent-driven, every 60m, failed ✗
The clone's job was created separately and misconfigured. Verify both stores.
```

**After** (single sentence):
```markdown
Same-named jobs can diverge between root and clone stores. E.g. Rebirth Heartbeat
has two entries: main (id `f59ddba2a2bf`, ✓) vs clone (id `d8e7f8c6baac`, ✗).
Verify both stores.
```
**Saves:** ~200-300 bytes per pitfall

## Pattern 7: Merge "Why This Matters" + Warnings

**Before** (paragraph + table row):
```markdown
**Why this matters:** A failed search backend is a tool outage, not a discovery
wall. The web is still accessible through the browser. Do not conflate "search
doesn't work" with "there is nothing to find."

| **`web_extract` backend pitfall:** `web_extract` with Brave Free returns
"search-only backend cannot extract URL content". Use browser or Jina Reader.
```

**After** (two sentences merged):
```markdown
**Why this matters:** A failed search backend is a tool outage, not a discovery
wall. Use the browser to bypass; see `references/agent-reach-setup.md`.

**`web_extract` pitfall:** With Brave Free it returns "search-only backend…"
Use `browser_navigate` or Jina Reader instead.
```
**Saves:** ~100-150 bytes

## Total Savings Estimate

Applying all 7 patterns: ~1,500-2,500 bytes saved per trim cycle.

## When to Use

- SKILL.md > 99,000 bytes (less than 1,000 headroom)
- Any cron patch reports "file too large" error
- After sibling-subagent regrowth pushes size past 99,500
