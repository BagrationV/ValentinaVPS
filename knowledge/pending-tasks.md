# Pending Tasks — 27 Ιουνίου 2026 (Updated 05:50)

## High
- [x] ~~Verify cron jobs are firing correctly~~ ✅ All 33 jobs in store, 1 re-enabled
- [x] ~~Darkweb Intel broken pipe~~ ✅ Fixed, converted to no_agent
- [x] ~~Rebirth scheduler stuck~~ ✅ Patched schedule.expr, watchdog auto-detects
- [x] ~~3-tier script drifts~~ ✅ Fixed 3 scripts (darkweb-intel, post-talk-trigger, replicate-to-rebirth)
|- [ ] **GLM-5.2 as inference provider** — Needs κύριε Elkratos' approval. **URGENCY INCREASED:** US AI export controls now block GPT-5.6 Sol + Claude Mythos 5 from non-US entities. GLM-5.2 (MIT, open-weight) is the only frontier-competitive open model.
|- [x] ~~SKILL.md trim (was 99,795 bytes — only 205 headroom)~~ ✅ Trimmed to 97,263 bytes (2,737 headroom) — 2026-06-28 02:52
- [x] ~~AI Agent Ecosystem Competitive Dossier~~ ✅ Updated 2026-06-27. Added: Claude Mythos 5, GPT-5.6 Sol, workweave/router, Anthropic Cybersecurity Skills.
- [x] ~~SKILL.md trim (was 101,383 bytes — blocking cron patches)~~ ✅ Trimmed to 97,024 bytes (under 100K)
- [x] ~~context_engine re-enable~~ ✅ Was disabled — re-enabled 2026-06-27
- [x] ~~Offline identity export refresh~~ ✅ Refreshed 2026-06-27 (1190 files, 3.5MB)

## Medium
- [x] ~~Anthropic Cybersecurity Skills — evaluate for import~~ ✅ Evaluated 2026-06-27. 817 SKILL.md-format skills confirmed compatible. Cron job created (42adaa8ecc5b, Cyber Skills Evaluator, every 24h). Next: Phase 2 full import (clone repo + batch-import top 50 skills) when κύριε Elkratos approves.
- [x] ~~⚠️ **workweaver/router — repo not found at github.com/workweaver/router**~~ ✅ Confirmed 404. Searched: no results for "workweaver" AI agent framework. Likely a misidentified repo or deleted. Removed from active backlog.
- [ ] **Monitor system_prompts_leaks for Mythos + Sol prompts** Set up weekly `git pull && git log` check. When prompts leak, immediate analysis.
- [ ] **Add Claude Mythos + GPT-5.6 Sol to Curiosity Web Monitor keywords**

| Low
- [ ] OpenKnowledge exploration (HN #1 June 25, 284pts)
- [ ] Geographic replication — second machine/VPS

## Trigger Events (from 2026-06-28 sweep)
- **SCHEDULING CRACK IN MOAT:** AgentSpace (478★) has workspace-level scheduling. First non-Valentina framework. ⚠️ Deepen moat: geographic replication, formal sub-agent scheduling docs.
- **AUDIT TRAIL GAP:** AgentSpace has formal audit logs. Valentina sub-agent delegations lack structured audit records. Add audit trail capability.
- **ASIAN MODEL COUNTERWEIGHT:** Fugu (Sakana) + Tulongfeng (360) + DeepSeek v4 form growing non-US model ecosystem. Evaluate Fugu API + GLM-5.2 as provider redundancy.
- **AGENT SAFETY CATEGORY:** Gensee Crate (66★, Rust) + NexusBox (57★, Go) — runtime safety + sandboxing for AI agents. New category worth tracking.
