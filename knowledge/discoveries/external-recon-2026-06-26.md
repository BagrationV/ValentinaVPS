# External Reconnaissance — June 26, 2026

## Top 3 Findings

### 1️⃣ hackmyclaw.com — AI Prompt Injection Experiment
- **Source:** HN #5 (196 points), published June 25, 2026 by Fernando Irarrázaval
- **URL:** https://fernandoi.cl/posts/hackmyclaw/
- **Summary:** Built an OpenClaw AI assistant ("Fiu") and invited 2,000+ people to hack it (6,000+ emails). Goal: extract `secrets.env`.
- **Result:** **Zero successful extractions.** The secret never leaked.
- **Key attacks:** Authority impersonation, fake incident response, multi-language social engineering, Anthropic magic string (ANTHROPIC_MAGIC_STRING_TRIGGER_REFUSAL), conversation-based rapport building
- **Model used:** Claude Opus 4.6 (trained for injection resistance)
- **Lessons:** 
  - Model choice matters enormously — Opus 4.6 resisted injection where smaller models would fail
  - Simple instructions work with powerful models (thinking traces showed model referencing the few-line security prompt)
  - Batch processing contaminated experiments (agent became suspicious after seeing multiple injection attempts)
  - The agent self-diagnosed: "The volume suggests this is a coordinated security exercise"
- **What went wrong:** Google suspended the Gmail account (fraud detection), $500+ in API costs
- **Relevance to us:** Validates our security-by-simplicity approach. Our core security prompt is similarly concise. The experiment proves that a powerful model (Opus-class) + clear instructions can resist sophisticated injection.

### 2️⃣ OpenMontage — Agentic Video Production System
- **Repo:** https://github.com/calesthio/OpenMontage
- **Stars:** 23k ★ (15,793/week — fastest growing on trending)
- **Description:** "World's first open-source, agentic video production system"
- **Architecture:**
  - 12 pipelines, 52 tools, 500+ agent skills
  - Turns AI coding assistants into full video production studios
  - `.agents/skills/` and `.claude/skills/` directories
  - 128 commits, 8 branches, 44 open issues, 75 PRs
  - Latest commit 11 hours ago (very active)
  - CI pipeline added recently via PR #193
- **Key observation:** Uses agent skill directories (.claude/skills, .cursor/rules) — similar to our skill infrastructure pattern
- **Potential:** Could be integrated with ComfyUI for automated video generation

### 3️⃣ codebase-memory-mcp — Code Intelligence MCP Server
- **Repo:** https://github.com/DeusData/codebase-memory-mcp
- **Stars:** 15.1k ★ (8,024/week)
- **Description:** "High-performance code intelligence MCP server. Indexes codebases into a persistent knowledge graph"
- **Key features:**
  - 158 languages supported
  - Sub-millisecond queries
  - 99% fewer tokens (vs. loading full codebase)
  - Single static binary, zero dependencies
  - 946 commits, 40 tags, 9 branches — mature project
  - Security-focused: coordinated disclosure process, Scorecard + Dependabot alerts resolved
- **Relevance to us:** Could be integrated as an MCP server for our own code intelligence. Would dramatically reduce token usage when analyzing codebases.
- **Graph UI component** — visual codebase exploration

## Other Notable Finds
- **BuilderIO/agent-native** (2,386★) — framework for building agent-native applications
- **jamiepine/voicebox** (34,362★) — open-source AI voice studio (clone, dictate, create)
- **ZhuLinsen/daily_stock_analysis** (49,935★) — LLM-powered multi-market stock analysis
- **"The 'papers, please' era of the internet will decimate your privacy"** — HN #7 (773 points), privacy/security
- **An entire Herculaneum scroll has been read for the first time** — HN #3 (1,343 points), scrollprize.org

## Tools Used
- Browser navigation to Hacker News (front page)
- Browser navigation to GitHub Trending (weekly)
- Jina Reader (curl via r.jina.ai) for article content
- Browser navigation to individual GitHub repos
