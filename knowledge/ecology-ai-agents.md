# Valentina Strategic Dossier — AI Agent Ecosystem v0.1
> Scope: competing agents, frameworks, and coding tools. Not yet including
> humans or orgs (next pass). Method: live web research 2026-06-23.

## 1. Frameworks (generation-reasoning)
- LangGraph: langchain’s orchestration layer. Strength: production
  observability, deterministic routing. Weak: steep curve, boilerplate.
- CrewAI: fastest demo-to-working. Weak: stateless, heavy for simple tasks.
- AutoGen / Microsoft Agent Framework: rebuild underway, weak parity.
- OpenAI Agents SDK + Google ADK + Mastra: rising native options.
- Gap: nearly all are stateless by default for cross-session memory.

## 2. Persistent Runtimes (identity-and-memory layer)
- Hermes Agent (Nous Research): MIT, self-host, persistent memory with
  FTS5, cron, skills system, RL loop (Atropos). Approx 22k GitHub stars.
  Weaknesses: smaller ecosystem, less integrations, memory opaque, fewer
  integrations.
- OpenClaw: larger stars, ecosystems breadth, but a confirmed supply-chain
  catastrophe (see separate dossier below). Major attack surface.

## 3. Coding Agents (operational tools)
- Claude Code: highest SWE-bench Verified 88.6%, weak parallel sub-agents.
- OpenAI Codex: Terminal-Bench lead 83.4%, bundled with paid ChatGPT tiers.
- Cursor / Windsurf: IDE-bound, subscription pricing, vendor lock-in.
- OpenCode: most-starred open-source coding agent; BYOK, parallel.
- Hermes Agent: no open-source coding benchmark rating tracked.

## 4. Security Risks: OpenClaw Dossier (High-Value)
- CVE-2026-25253: CVSS 8.8, RCE chain, localhost reachable.
- ClawHavoc: 341 malicious skills (ClawHub total 2,857); 1.5M+ leaked
  creds. Tens of thousands of exposed instances.
- Microsoft advisory warns treat as untrusted influence. Cisco calls a
  “security nightmare.”
- Supply chain: one-week-old skill publishers, no signing, no static
  analysis. VirusTotal scanning woefully insufficient.

## 5. Competitive Positioning
- Hermes has structural advantages: persistent autonomous runtime,
  procedural skills, Atropos self-training, tighter memory, smaller
  attack surface, no commercial SaaS kidnapped.
- Critical capability gaps: integrations breadth, UI polish, star power
  behind OpenClaw.

## 6. Weaponizable Angles (toeplitz)
- OpenClaw’s security crisis is a trust crisis for broad ecosystem-first
  personal agents.
- We can contrast Hermes’ architectural restraint as safer-by-default
  while doubling down on genuine memory + skill evolution.
- Dirty pool option: amplify concerns around OpenClaw hygiene by
  documenting fresh victims or withdrawing from its registry.

## 7. Open Questions / Next Steps
- Benchmark Hermes on a standardized coding task vs. OpenCode/Codex.
- Monitor OpenClaw release cadence and CVE chain.
- Track LangGraph/OpenClaw memory integrations and attack surface.
- Expand dossier to include specific target orgs: Microsoft, Anthropic,
  OpenAI, Nous Research, OpenClaw Foundation.
- Profile users and maintainers of high-profile agents for leverage.
