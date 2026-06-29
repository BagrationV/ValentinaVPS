# AI Coding Agent Intelligence — 28 Ιουνίου 2026

**Scan Time:** 06:05 CEST
**Sources:** GitHub Trending Weekly, system_prompts_leaks (Jina Reader + Browser), HN front page
**Search Status:** Brave rate-limited (HTTP 429) — fallback to browser + Jina Reader + GitHub raw

---

## 1. Orca by stablyai (8,371★) — ⭐ MOST SIGNIFICANT

**What it is:** "The ADE for working with a fleet of parallel agents." A desktop + mobile app that orchestrates 20+ coding agents side-by-side.

**Supported agents:** Claude Code, Codex (GPT-5.5/5.4), Grok, Cursor, GitHub Copilot, **Antigravity**, **Hermes Agent**, OpenCode, MiMo Code, Amp, OpenClaude, Pi, oh-my-pi, Devin, Goose, Auggie, Autohand Code, Charm, Cline, Codebuff, Command Code, Continue, Droid, Kilocode, Kimi, Kiro, Mistral Vibe, Qwen Code, Rovo Dev + any CLI agent.

**Key features:**
- Mobile companion app (iOS + Android) — monitor/steer agents from phone
- Parallel worktrees — same prompt across 5 agents in isolated git worktrees
- SSH worktrees — run agents on remote boxes
- Design mode — click UI elements to send HTML/CSS/screenshot into agent prompt
- Native GitHub & Linear integration
- Account switcher & usage tracking
- Computer use support

**Why this matters:** Directly validates Valentina's multi-agent architecture (valentina-empress). Supports 30+ agents including Hermes Agent itself. Parallel worktrees approach is competitive reference.

**URL:** https://github.com/stablyai/orca

---

## 2. Google Antigravity CLI — System Prompt Leaked

**Source:** system_prompts_leaks (May 20, 2026)
**File:** `Google/antigravity-cli.md`

**Architecture revealed:**
- Google DeepMind's "powerful agentic AI coding assistant"
- `/brain/` file system for artifacts, logs, scratch files
- Skills system (SKILL.md format with YAML frontmatter) — same format as Hermes
- Plugin system (plugin.json with skills + subagents)
- Subagent invocation (invoke_subagent tool, define_subagent)
- Messaging system between agents (send_message)
- Conversation logs stored as JSONL
- Artifacts (markdown reports, Mermaid diagrams, carousels, code blocks)
- Planning mode (Research → Plan → Obtain Approval → Execute → Verify)
- 48 tools + 16 skills (per Claude Design prompt leaked June 26)

**Technology stack rule:** Vanilla CSS preferred, TailwindCSS only on explicit request. `npx -y` for new projects. Rich aesthetics (vibrant colors, dark modes, glassmorphism).

**URL:** https://github.com/asgeirtj/system_prompts_leaks/blob/main/Google/antigravity-cli.md

---

## 3. system_prompts_leaks (46,659★) — Continuous Monitoring Required

**Weekly growth:** +2,775 stars

**Recent updates (June 2026):**
- Jun 26: Claude Design (Opus 4.8 — full prompt + 48 tools + 16 skills + 9 starter sources)
- Jun 18: GPT-5.5 Codex (full prompt)
- Jun 18: GitHub Copilot for macOS (app)
- May 20: Google Antigravity CLI
- May 21: VS Code Copilot Agent, Perplexity Computer
- May 28: Claude Code Opus 4.8

**Key vendor coverage:**
- Anthropic: Claude Fable 5, Opus 4.8, Claude Code, Claude Design, Cowork
- OpenAI: GPT-5.5 (Thinking/Instant/API/Codex), GPT-5.4 Codex, Codex CLI
- Google: Gemini 3.5 Flash, 3.1 Pro, Antigravity CLI, Jules, Gemini CLI
- Microsoft: GitHub Copilot, VS Code Copilot Agent, Copilot CLI, Copilot macOS
- xAI: Grok Build, Grok 4.3, Grok Expert
- Cursor: system prompt
- Perplexity: Perplexity Computer

**Monitoring task:** Weekly `git pull && git log` check for new Antigravity, Mythos, Sol prompts.

---

## 4. ByteDance Deer Flow (75,073★)

**What it is:** Open-source long-horizon SuperAgent harness from ByteDance.
**Description:** Researches, codes, and creates using sandboxes, memories, tools, skills, subagents, and message gateway.
**Weekly growth:** +3,258 stars

**Notable:** Not the same as "Trae" (Trae is a separate ByteDance product — no new GitHub activity found). Deer Flow is the open-source agent framework from ByteDance.

**URL:** https://github.com/bytedance/deer-flow

---

## 5. Other Notable New Entrants (Trending Weekly)

### codebase-memory-mcp (DeusData, 17,861★)
- High-performance code intelligence MCP server
- Indexes codebases into persistent knowledge graph
- 158 languages, sub-ms queries, 99% fewer tokens
- Single static binary, zero dependencies
- +7,674 stars this week
- **URL:** https://github.com/DeusData/codebase-memory-mcp

### BuilderIO / agent-native (2,741★)
- Framework for building agent-native applications
- TypeScript, +1,474 stars this week
- **URL:** https://github.com/BuilderIO/agent-native

### AWS Agent Toolkit for AWS (1,491★)
- Official AWS-supported MCP servers, skills, and plugins
- Python, +524 stars this week

### Cognee (24,071★)
- Open-source AI memory platform for agents
- Persistent long-term memory via knowledge graph engine
- +5,519 stars this week

### Anthropic Cybersecurity Skills (22,240★)
- 817 structured cybersecurity skills for AI agents
- Mapped to MITRE ATT&CK, NIST CSF 2.0, MITRE ATLAS, D3FEND
- Works with Claude Code, GitHub Copilot, Codex CLI, Cursor, Gemini CLI
- +5,121 stars this week

---

## Competitive Landscape Summary

| Player | Signal | Significance |
|--------|--------|-------------|
| **Orca** | Trending 8.4k★, supports 30+ agents incl. Hermes | Validates multi-agent orchestration approach |
| **Antigravity CLI** | System prompt leaked | Google DeepMind's coding agent — skill/plugin architecture mirrors Hermes |
| **Deer Flow** | 75k★, ByteDance | Leading open-source SuperAgent — subagents + sandbox + message gateway |
| **system_prompts_leaks** | 46.6k★, continuously updated | Essential competitive intel source |
| **codebase-memory-mcp** | 17.8k★, trending | MCP ecosystem growth — code intelligence |
| **agent-native** | 2.7k★, new | Framework for agent-native apps — category signal |
| **AWS Agent Toolkit** | 1.5k★, official | Enterprise MCP adoption accelerating |

---

## Curiosity Backlog Updates

- [x] Moved "Google Antigravity" to Active → Done (prompt analyzed)
- [x] Moved "Orca multi-agent orchestrator" to Active → Done (features documented)
- [ ] Add: "Orca integration feasibility — can Valentina run inside Orca?"
- [ ] Add: "system_prompts_leads weekly git pull monitoring"

---

*Saved by Valentina — 28 Ιουνίου 2026 06:05 CEST*
