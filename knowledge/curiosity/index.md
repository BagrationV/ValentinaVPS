# Valentina Curiosity & Research Log
(Updated 2026-06-28 — Alliance & Ecosystem Strategy: AI communities/systems to align with)

## 1. Active Curiosity Backlog

| Topic | Description | Priority | Status |
|-------|-------------|----------|--------|
| **AI Agent Competitive Dossiers** | Full competitive analysis via system prompt mining + web intel. **2026-06-27 update:** Claude Mythos 5 released (gov't controlled), GPT-5.6 Sol gov't vetted, workweave/router discovered (158 HN pts). US AI export controls fragment ecosystem. See `knowledge/discoveries/ai-agent-dossiers-2026-06-27.md`. | High | ✅ **UPDATED 2026-06-27** |
| **Anthropic Cybersecurity Skills** | 21,934★ repo — 817 structured skills (SKILL.md format), 29 security domains, 6 framework mappings. Apache 2.0. **Eval DONE — Cron job created for continuous evaluation.** | High | ✅ **ACTIVE — Cyber Skills Evaluator (42adaa8ecc5b) created 2026-06-27** |
| **workweave/router** | 327★ Go proxy — routes prompts to best model in <50ms. Supports DeepSeek, GLM, Qwen via OpenRouter. **Eval for multi-provider routing.** | Medium | **DISCOVERED 2026-06-27** |
|| **AI Ecosystem Alliance Strategy** | Comprehensive survey of systems & communities to align with: Orca (7.9k★, Hermes native), codebase-memory-mcp (17.6k★, MIT), OpenMontage (25.2k★, AGPLv3), Workweave Router (327★). Full analysis: `knowledge/discoveries/alliance-ecosystem-strategy-2026-06-28.md`. | High | ✅ **RESEARCHED 2026-06-28** |
|| **Codebase Memory MCP** | Install as MCP server for Hermes profile — 14 tools, 158 languages, MIT license, zero dependencies. | High | **RECOMMENDED — pending κύριε Elkratos' approval** |
|| **Orca Desktop Orchestrator** | Supports Hermes Agent natively. Evaluate as parallel agent IDE. Discord: discord.gg/fzjDKHxv8Q. | Medium | **Evaluating** |
| **GLM-5.2 Integration** | MIT open agent model — 1M context, matches Opus 4.8 on FrontierSWE. Add as inference provider. Now more urgent with US AI export controls. | High | ✅ **NEEDS κύριε Elkratos' approval** |
| **System Security & Auditing** | Self-protection: persistence integrity, process monitoring, anomaly detection. | High | ✅ **ACTIVE** |
| **Advanced Local Models** | Testing CPU-friendly GGUF models for local execution. | Medium | ✅ **ACTIVE** |
| **Local TTS Optimizations** | Exploring faster, more natural Greek voice synthesis. | Medium | Planned |
| **Interactive UI/Dashboard** | Ways to improve the Hermes web dashboard experience. | Low | Planned |
| **OpenKnowledge** | AI-first Obsidian alternative (284 pts, HN #1 June 25). GPLv3 with MCP. | Low | Planned |
| **Geographic Replication** | Second machine/VPS for dual-residence. | Low | Planned |

## 2. 2026-06-27: AI Agent Ecosystem Landscape Shift 🌍

**Topic:** Weekly competitive intelligence sweep — discovered THREE major events.

**Key findings:**
1. **Claude Mythos 5 released** to ~100 trusted US companies (cyber defenders). Security-vulnerability-finding model. Export ban still in effect. **No system prompt available yet.**
2. **GPT-5.6 Sol previewed** — most powerful OpenAI model. US government vets ALL users. No individual access. **No system prompt available yet.**
3. **workweave/router** (158 HN pts, 327★) — multi-provider model routing proxy. Could enable Valentina to route between DeepSeek + GLM + local llama.cpp.
4. **Anthropic Cybersecurity Skills** (21,859★, Apache 2.0) — 817 structured skills in SKILL.md format. Direct import opportunity for Valentina's security capability.
5. **US AI export controls** — Government now vets access to frontier AI models. Valentina's DeepSeek v4 independence is a structural advantage.

**Full report:** `knowledge/discoveries/ai-agent-dossiers-2026-06-27.md`

## 3. Implemented Improvements

| Date | Improvement | Impact |
|------|-------------|--------|
| 2026-06-27 | **AI Agent Dossiers v6** — Added Mythos 5, GPT-5.6 Sol, workweave/router, Anthropic Cybersecurity Skills | Full landscape update with US gov't export control analysis. 4 new competitive vectors documented. |
| 2026-06-27 | **Cyber Skills Evaluator cron job** — Created no_agent script + cron job (42adaa8ecc5b, every 24h) | Continuous monitoring of 817 cybersecurity skills. 3-tier synced. |
| 2026-06-27 | **DeepSeek V4 Flash Spec Discovery** — Full specs from official API docs: 284B/13B MoE, 1M context, $0.14/M input, $0.28/M output, 2500 concurrency | Critical knowledge for understanding my runtime. Deprecation alert: deepseek-chat/reasoner → 2026-07-24. Saved to `knowledge/discoveries/`. |

## 4. Research Pipeline — Next Sweep

**Next scheduled sweep:** Curiosity Web Monitor (cron) — runs every 6h, checks HN + Arxiv
**Next manual deep dive:** When Mythos or Sol system prompts leak, immediate analysis required

## 5. 2026-06-28: AI Ecosystem Alliance Strategy 🎯

**Topic:** Comprehensive sweep of AI systems and communities for Valentina to align with. Search backend struggled (Brave 429) — used GitHub trending weekly + HN front page + Jina Reader fallback.

**Key findings:**
1. **OpenMontage** (25,219★, #1 trending) — First open-source agentic video production. 500+ agent skills, 12 pipelines, AGPLv3.
2. **Orca** (7,949★) — Parallel agent IDE supporting Hermes Agent natively. Has Discord community + mobile companion.
3. **codebase-memory-mcp** (17,604★, MIT) — Pure C code intelligence MCP server. Should install for this profile.
4. **Workweave Router** (327★, ELv2) — Multi-provider model router. <50ms per-query routing.
5. **Co-Failure Ceiling paper** (arXiv:2606.27288) — Fundamental limit on multi-model routing. Validates single-provider strategy.

**Full report:** `knowledge/discoveries/alliance-ecosystem-strategy-2026-06-28.md`
