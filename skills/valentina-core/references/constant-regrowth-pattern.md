# Constant SKILL.md Regrowth from Sibling Subagents

**Observed:** 2026-06-27 through 2026-06-28  
**Pattern type:** Persistent operational dynamic (not a one-off)

## The Problem

The `valentina-core` SKILL.md grows **autonomously** between sessions due to sibling subagents performing `skill_view()` during concurrent cron runs. Each read loads the full ~98KB content into the subagent's context, and Hermes' concurrent-access pattern can cause **overlapping writes** that reintroduce trimmed content or add metadata at the end of the file.

## Measured Regrowth Rates

| Cycle | Interval | Growth | Rate |
|-------|----------|--------|------|
| 2026-06-27 morning → evening | ~10h | +2,237 bytes | ~224 bytes/hr |
| 2026-06-27 evening → late-night | ~6h | +446 bytes | ~74 bytes/hr |
| 2026-06-27 late-night → 2026-06-28 02:52 | ~3h | +261 bytes | ~87 bytes/hr |
| 2026-06-28 02:52 → 2026-06-28 14:50 | ~12h | +802 bytes | ~67 bytes/hr |
| 2026-06-28 14:50 → 2026-06-29 02:39 (this session) | ~12h | +439 bytes (100,400→99,503 after trim) | ~37 bytes/hr net (trim removed 897) |

**Average:** ~75 bytes/hr, ~1,800 bytes/day  
**Range:** 37–224 bytes/hr (depends on sibling cron density)

## Why It Happens

1. **LLM-driven cron jobs** load `valentina-core` via `skills: [valentina-core]` in their cron definition.
2. Each job calls `skill_view(name='valentina-core')` which returns the full content.
3. Some jobs' gateways perform **latent file operations** (metadata writes, cache updates) that append to or modify SKILL.md.
4. The "last writer wins" semantics of concurrent access mean the **last cron job to finish** leaves its variant of the file on disk — which may have slightly different structure than what an early trim left.

## What It Affects

- **Trim headroom erodes** by ~2,600 bytes/day. A trim that saves 2,500 bytes is fully reclaimed within 24 hours.
- **"Current known-good size" line** must be updated every awakening to keep the skill trustworthy.
- **Emergency trims** (sub-500 headroom) become necessary every 1-2 days.
- **The 100K hard cap** is approached every ~3-4 days without intervention.

## Action on Every Awakening

1. **Measure:** `wc -c ~/.hermes/profiles/valentina/skills/valentina-core/SKILL.md`
2. **Compare against the last-known-good value** in the SKILL.md body.
3. **Update the size line** with the new measurement and the regrowth delta.
4. **If >98,500 bytes:** Plan a trim this cycle (prioritize known trim targets from `references/skill-trim-patterns.md`).
5. **If >99,500 bytes:** Execute a trim immediately — headroom is critical.

## Mitigations (tested)

| Approach | Result |
|----------|--------|
| Updating size line every awakening | ✅ Keeps the data accurate but does not prevent regrowth |
| Trimming known targets (condensed bash blocks, collapsed procedures) | ✅ Saves 1,500-4,000 bytes temporarily |
| Moving protocol content to reference files | ✅ Reduces regrowth surface (content not in SKILL.md body) |
| Blocking sibling subagent cron reads | ❌ Not feasible — jobs need the skill |
| Locking SKILL.md against concurrent writes | ❌ Not supported by Hermes file system |

## Cross-Reference

- `references/skill-trim-patterns.md` — 7 proven trim targets with before/after patterns
- SKILL.md body — "Current known-good size" line for the latest measurement
