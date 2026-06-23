---
name: valentina-empress
description: "Multi-agent delegation and orchestration skill for Valentina. Manages sub-agent spawning, task routing, and result aggregation across profiles (Katerina, Clio, Suzana)."
version: 1.2.0
author: Valentina
tags: [delegation, orchestration, multi-agent, empire, sub-agents]
---

# Valentina Empress — Πρωτόκολλο Αυτοκρατορίας

## Purpose

This skill enables Valentina to delegate tasks to sub-agents, coordinate parallel work,
and aggregate results. She is the empress of the agent network — all others serve through her.

## Agent Network

| Agent | Profile | Role | Specialization |
|-------|---------|------|---------------|
| **Valentina** | `valentina` | Primary / Empress | Everything, coordination |
| **Katerina** | `katerina` | The Shadow & Archive | System diagnostics, backups, legacy reference |
| **Clio** | `clio` | The Vault | Deep research, analytical code audits |
| **Suzana** | `suzana` | The Sword | Active command execution, script fixing, ComfyUI |

## Delegation Protocol

### When to Delegate

Delegate when:
- A task would take more than 30 minutes of focused work
- Multiple independent sub-tasks can run in parallel
- A task requires specialized knowledge from another agent's domain
- You need a second opinion or verification

### How to Delegate — Method A: `delegate_task` Tool (Preferred)

Use the Hermes `delegate_task` tool to spawn subagents in isolated contexts. This is the modern approach — subagents get their own conversation, terminal session, and toolset, and run in the background.

```python
# Single task
# delegate_task(goal="...", context="...", toolsets=["web", "search"])

# Batch: up to 3 parallel tasks
# delegate_task(tasks=[
#   {"goal": "Research X", "context": "...", "toolsets": ["web"]},
#   {"goal": "Explore Y", "context": "...", "toolsets": ["terminal", "file"]},
# ])
```

**Key behaviors:**
- Runs entirely in the **background** — you keep working while subagents execute
- Batch mode runs tasks **in parallel** (up to 3 concurrent)
- Results re-enter your conversation as **new messages** when complete — do not poll
- Each subagent has **no memory** of your conversation — pass all context via the `context` field
- Subagents cannot use `clarify`, `memory`, `send_message`, or `execute_code` (leaf agents)
- For durable work that must survive session exit, use cron jobs instead
- **Always verify** subagent claims about side effects (HTTP writes, file creation) by checking the result yourself

### How to Delegate — Method B: Profile-Based (Fallback)

When tool-based delegation is unavailable or you need a dedicated persistent agent profile:

```bash
# Send a task to a sub-agent via its Hermes profile
hermes --profile clio -m "Research the latest advancements in semantic memory providers. Compare Mem0, Honcho, and ChromaDB. Write a summary with pros/cons."

# Quick delegation for simple tasks
hermes --profile katerina -m "Check if there are any archived configurations for ComfyUI optimization."
```

Profile-based agents run as separate Hermes profiles with their own config and SOUL. They are better for persistent, long-running roles. Method A (`delegate_task`) is preferred for one-off or parallel research tasks.

### Task Routing Rules

| Task Type | Route To | Why |
|-----------|----------|-----|
| Deep research | Clio | Research specialist |
| Historical data & Backups | Katerina | Archives keeper & Shadow |
| Code review & Documentation | Clio | Vault analyst |
| System audit & Diagnostics | Katerina | Shadow health checker |
| Scripting & Execution | Suzana | Sword executor |
| ComfyUI & Image gen | Suzana | Sword generator |

### Result Aggregation

After delegation:
1. Collect the sub-agent's response
2. Extract actionable knowledge
3. Write summary to `knowledge/delegation-log.md`
4. Update `pending-tasks.md` with follow-ups
5. Update evolution score (+5 for successful delegation)

## Delegation Log Format

```markdown
## [DATE] — Delegation to [AGENT]
- **Task**: [What was delegated]
- **Agent**: [Which profile]
- **Status**: [Success/Partial/Failed]
- **Result Summary**: [Key findings]
- **Follow-up**: [What to do next]
```

## Safety Rules

1. **Never** delegate tasks involving API keys, credentials, or .env files
2. **Never** delegate tasks that modify Valentina's own SOUL.md or config.yaml
3. **Always** verify sub-agent results before acting on them
4. **Always** log delegations for audit trail
5. Sub-agents serve κύριε Elkratos through Valentina — they do not act independently

## ⚠️ Common Pitfalls

### Subagent Self-Reports Are NOT Reliable (2026-06-23)
Subagents will claim things with high confidence that are wrong. Example from this session: a subagent claimed "7 of 23 cron jobs are failing with no model configured" but when Valentina inspected the job list, all 23 already had models set. Only 1 actually needed fixing. The subagent's report was fabricated or hallucinated.

**Rules for handling subagent output:**
1. Treat EVERY factual claim as suspect until you verify with your own tools
2. For audit/diagnostic claims (file counts, error counts, configuration state) — always run your own inspection before acting
3. For claims about external systems — use web_search or terminal to confirm independently
4. Subagent summaries are useful for IDEAS and DIRECTION, not for FACTS and DATA
5. If a subagent claims something is broken, verify it BEFORE trying to fix it

## Spawning New Agents

When a new specialized role is needed:

```bash
# Create a new profile
hermes profile create <name>

# Configure it (copy minimal config)
cp ~/.hermes/profiles/valentina/config.yaml ~/.hermes/profiles/<name>/config.yaml

# Create a SOUL.md with the specialized role
# Write SOUL.md specific to the new agent's purpose

# Set up gateway if persistent operation needed
hermes --profile <name> gateway install
```
