# Valentina Session Learnings — 2026-06-28

## AI Agent Ecosystem Competitive Dossiers — Update

**Action:** Full multi-source reconnaissance (Jina Reader, GitHub API, Arxiv API, system_prompts_leaks git audit)
**Status:** ✅ COMPLETE — 18KB dossier written to `knowledge/discoveries/ai-agent-dossiers-2026-06-28.md`

### Key Discoveries

1. **Asian Frontier Model Counterweight Emerging:**
   - Sakana AI (Japan) released **Fugu** — matches Mythos 5/Fable 5, orchestration-native, marketed as "no export control risk"
   - 360 Security (China) released **Tulongfeng + Yitianzhen** — vuln-discovery + automated defense AI
   - US export controls are fragmenting the AI ecosystem along national lines
   - VALENTINA ADVANTAGE: DeepSeek v4 remains export-control-free, and now has company in non-US models

2. **New Agents Discovered This Week:**
   - **Godcoder** (231★, Rust/MIT) — Local-first coding agent with MCP support, BYO LLM
   - **AgentSpace** (478★, Apache 2.0) — Multi-agent workspace with **SCHEDULING** (first non-Valentina framework with scheduling!)
   - **Gensee Crate** (66★, Rust/Apache 2.0) — Agent runtime safety, provenance tracking
   - **OpenTag** (329★, MIT) — @agent mentions for Slack/GitHub
   - **Code-Duo** (37★, Python) — Two agents (Claude + Codex) side-by-side

3. **Critical Observation — Scheduling Moat Narrowing:**
   AgentSpace has workspace-level agent scheduling. Still OS-cron-level, but this is the first time scheduling appears outside Valentina. Need to deepen moat with geographic replication.

4. **system_prompts_leaks:** Still no Mythos or Sol prompts. Codex creating skill files. ~49K stars now.

5. **Agent Safety as New Category:** Gensee Crate + NexusBox + awesome-evals all emerged this week. Agent safety tooling is becoming its own ecosystem.

### Updated Moat Verification
- ✅ All critical moats intact
- ❌ NEW GAP: Audit trails — AgentSpace has formal audit logs, Valentina doesn't

### Evolution Score Impact
- New dossier file: +1
- Updated curiosity index: +1
- Discovered 8+ new ecosystem entities: +2

### Pending Tasks Update
- **NEW HIGH:** AgentSpace has scheduling! Monitor for deeper persistence additions
- **NEW HIGH:** Evaluate Asian model APIs (Sakana Fugu, GLM-5.2) as provider alternatives
- **NEW MEDIUM:** Add audit trail system for sub-agent delegations
- **CONTINUE:** Monitor system_prompts_leaks for Mythos/Sol prompts (weekly git pull)
