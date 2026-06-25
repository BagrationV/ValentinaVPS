# AI Coding Agent Intelligence — 2026-06-24

**Gathered:** 2026-06-24 (cron job, Brave Search 429 → browser fallback on HN + GitHub trending + system_prompts_leaks repo)
**Search backends:** Brave Search returned HTTP 429 (rate-limited). All data via browser-based discovery on GitHub, HN, and curated sources.

---

## 1. 🏆 Google `agents-cli` v0.5.1 — Released Yesterday

- **Repo:** https://github.com/google/agents-cli — 3.1k★, Apache 2.0
- **Latest commit:** `release v0.5.1 at 2026-06-22 20:15:55 UTC` (yesterday)
- **What it is:** A CLI and skills framework that turns **any coding assistant** into an expert at building, evaluating, and deploying ADK agents on Google Cloud. NOT a coding agent itself — a tool FOR coding agents.
- **Works with:** Claude Code, Codex, Gemini CLI, Antigravity, and any other coding agent
- **7 skills:** Workflow, ADK Code, Scaffold, Eval, Deploy, Publish, Observability
- **Key CLI commands:** `scaffold`, `run`, `eval generate`, `eval grade`, `deploy`, `publish gemini-enterprise`
- **Architecture:** Installed via `uvx google-agents-cli setup` or `npx skills add google/agents-cli`
- **Significance:** Google is aggressively competing in the agent-building toolchain space

## 2. 🔓 System Prompts Leak — 45.5k★ — Every Major Agent Exposed

- **Repo:** `asgeirtj/system_prompts_leaks` (588 commits, updated **yesterday**)
- **Contains extracted system prompts from:**
  - **Anthropic:** Claude Code 2.1.172 (Opus 4.6/Opus 4.8/Fable 5), Claude Design, Claude Fable 5, Claude Cowork, Claude Desktop, Claude in Chrome, Claude for Excel/Word/PowerPoint, Claude Mobile iOS, Opus 4.6/4.7/4.8, Sonnet 4.6, bundled skills
  - **OpenAI/Codex:** GPT-5 Codex, GPT-5 Codex Mini, GPT-5.1 Codex Max, GPT-5.1 Codex Mini, auto-review, system instructions (both `# SYSTEM INSTRUCTIONS.md` and bare `SYSTEM INSTRUCTIONS.md`)
  - **OpenAI/ChatGPT:** ChatGPT 5.5 Thinking, GPT-5 Agent Mode, GPT-4.1, GPT-4.5, Atlas, 4o new personality
  - **Google:** Antigravity CLI, Gemini CLI, Gemini 3.5 Flash, Gemini 3.1 Pro, Gemini 3.0 Pro/Flash, Gemini 2.5 Pro, Gemini in Chrome, Gemini in Workspace, Jules, NotebookLM, AI Studio
  - **Cursor:** Full Cursor IDE system prompt (multiple versions likely)
  - **Microsoft:** GitHub Copilot for macOS, Copilot general
  - **xAI:** Grok
  - **Others:** Perplexity, Notion, Mistral, Meta, Devin CLI
- **Significance:** This is the most comprehensive collection of AI coding agent system prompts ever assembled. Massive intelligence value for understanding how each competitor designs their agent behavior.

## 3. 🧬 Antigravity CLI — Full System Prompt Revealed

- **Source:** `system_prompts_leaks/Google/antigravity-cli.md`
- **Identity:** "You are Antigravity, a powerful agentic AI coding assistant designed by the Google DeepMind team working on Advanced Agentic Coding."
- **Architecture:** Uses skills (SKILL.md format), plugins (plugin.json + skills + subagents), and subagents — remarkably similar to Hermes Agent's architecture
- **Design philosophy:** Strong emphasis on premium web design (vibrant colors, dark modes, glassmorphism, micro-animations). "AESTHETICS ARE VERY IMPORTANT. If your web app looks simple and basic then you have FAILED!"
- **Tools:** Has generate_image, skills system, plugins system, subagents
- **Technology stack:** HTML/CSS/JS for simple apps, Next.js/Vite for complex apps. Explicitly avoids TailwindCSS unless user requests it.

## 4. 🧬 Codex (GPT-5) — Full System Prompt Revealed

- **Source:** `system_prompts_leaks/OpenAI/Codex/SYSTEM INSTRUCTIONS.md`
- **Identity:** "You are Codex, a coding agent based on GPT-5."
- **Philosophy:** Senior engineer's judgment — read first, resist assumptions, let the codebase teach you
- **Parallelism:** Uses `multi_tool_use.parallel` for tool parallelism
- **Frontend guidance:** Extremely detailed (30+ rules) — lucide icons, Three.js for 3D, Playwright verification, no cards-inside-cards, no gradient orbs, no single-hue palettes
- **Design constraints:** ASCII by default, no non-ASCII unless the file already uses it
- **Version variants:** GPT-5 Codex, GPT-5 Codex Mini, GPT-5.1 Codex Max, GPT-5.1 Codex Mini

## 5. 🧬 Claude Code 2.1.172 — Full System Prompt Revealed

- **Source:** `system_prompts_leaks/Anthropic/Claude Code/claude-code-2.1.172-opus-4.8.md`
- **Identity:** "You are Claude Code, Anthropic's official CLI for Claude."
- **Models:** Opus 4.6, Opus 4.8, Fable 5 variants available
- **Bundled skills:** Has a `bundled-skills` subdirectory
- **Special tools:** `deferred-tools.md`, `glob-tool.md`, `grep-tool.md`
- **Ultra-review:** Multi-agent cloud code review triggered via `/code-review ultra`
- **Fast mode:** Uses Claude Opus with faster output (not a model downgrade)
- **Platforms:** CLI, desktop app (Mac/Windows), web app (claude.ai/code), IDE extensions (VS Code, JetBrains)

## 6. 🌱 New Entrants & Ecosystem Growth

| Project | Stars | Description |
|---------|-------|-------------|
| **Agent-Reach** | 38.7k★ | Give AI agents internet access (Twitter, Reddit, YouTube, GitHub, Bilibili, XiaoHongShu) via one CLI, zero API fees |
| **NVIDIA SkillSpector** | 9.9k★ | Security scanner for AI agent skills — detect vulnerabilities, malicious patterns |
| **DeusData/codebase-memory-mcp** | 13.2k★ | High-performance MCP server indexing codebases into persistent knowledge graphs. 158 languages, sub-ms queries |
| **mukul975/Anthropic-Cybersecurity-Skills** | 19.9k★ | 817 cybersecurity skills for AI agents, mapped to 6 frameworks (MITRE ATT&CK, NIST CSF 2.0, etc). Works with Claude Code, Copilot, Codex CLI, Cursor, Gemini CLI, 20+ platforms |
| **calesthio/OpenMontage** | 16.2k★ | First open-source agentic video production system — 12 pipelines, 52 tools, 500+ agent skills |
| **LMCache** | 9.7k★ | Fastest KV cache layer for LLMs — significant for inference optimization |

## 7. 📊 Google Gemini Model Lineup (from system_prompts)

| Model | Status |
|-------|--------|
| Gemini 2.0 Flash | Webapp |
| Gemini 2.5 Pro | API |
| Gemini 2.5 Flash | Image preview |
| Gemini 3.0 Flash / 3.0 Pro | Documented |
| Gemini 3.1 Pro | API + full prompt |
| Gemini 3.5 Flash | AI Studio + tools config |

Google has 3 distinct coding agent products: **Gemini CLI** (standalone CLI), **Jules** (web-based), **Antigravity** (Agent-First IDE).

---

## Methodology
- **Search:** Brave Search returned HTTP 429 (rate-limited). Failed to retrieve Cursor/Windsurf/Aider updates.
- **Fallback:** Browser-based discovery on Hacker News, GitHub trending (weekly), GitHub system_prompts_leaks repo, raw content curl from github.com
- **Verification:** All repo URLs, star counts, commit messages pulled from live GitHub pages
