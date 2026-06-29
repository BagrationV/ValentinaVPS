# Discovery: Wayfinder Router — Deterministic Prompt-Complexity Routing
**Date:** 28 Ιουνίου 2026 (updated evening)
**Source:** Hacker News #10 (86 pts) → github.com/itsthelore/wayfinder-router

## Status Update (2026-06-28 Evening)
- **HN front page #10** — 86 points by handfuloflight, 41 comments
- **GitHub:** 174★, 181 commits, 9 forks — up from 143★ this morning
- **Full README analyzed** — much richer than initial discovery

## What It Is
A CLI tool (PyPI: `wayfinder-router`) that scores prompt complexity deterministically — reads structure (length, headings, lists, code blocks) and lexical cues (proofs, math, constraints), then recommends which model tier to use. Sub-millisecond, offline, no model call.

## Key Differentiators vs Other Routers
| Router | Decision Method | Model Call? | Self-Host? |
|--------|----------------|:-----------:|:----------:|
| **Wayfinder** | Deterministic structural score | **No** | **Yes** |
| RouteLLM | Trained classifier | Yes | Yes |
| NotDiamond/Martian | Learned, hosted | Yes | No |
| OpenRouter Auto | Hosted auto-router | Yes | No |
| Bifrost/LiteLLM | Provider gateway (not complexity) | No | Yes |

## Architectural Highlights (from README deep-dive)

### Three Routing Modes
1. **Binary** — single threshold cut (cheap/expensive)
2. **Tiered** — ordered score bands → N models (llama-3b → llama-70b → claude-cloud)
3. **Classifier** — fitted multinomial-logistic model (Newton/IRLS, pure Python)

### Calibration & Feedback Loop
- `wayfinder-router calibrate data.jsonl` — fits cut from labeled data
- `wayfinder-router onboard prompts.jsonl --arms local,cloud` — A/B bootstrap
- `wayfinder-router judge` — automated labeling with trust gates (Cohen's κ ≥ 0.6)
- `wayfinder-router recalibrate` — hot-reloads config from feedback log, no restart
- Feedback POST endpoint: `/v1/feedback` — collect user judgments live

### Gateway Features
- OpenAI-compatible API gateway (base_url swap)
- **Claude Code support** — `POST /v1/messages` adapter, Anthropic ↔ OpenAI translation
- Circuit breakers, rate limiting (rpm/tpm), virtual API keys with SHA-256 hashing
- Spend caps with degrade/block on breach
- Response cache (exact-match, in-memory, off by default)
- Cost savings dashboard: `GET /v1/savings?period=today|7d|30d|all`
- OpenTelemetry metrics + health endpoint
- Docker deployment (docker-compose.example.yml included)

### Steering Controls
- `model` field as routing directive: `auto`, `local`, `cloud`, `prefer-local`, `prefer-hosted`
- `X-Wayfinder-Threshold` header to re-cut per request
- In-message `/local`, `/cloud`, `/prefer-hosted`, `/auto` directives
- Response headers: `x-wayfinder-router-model`, `-score`, `-mode`, `-request-id`

### Integration Targets
Chat UIs: Open WebUI, LibreChat, Jan
Editors: Continue, Cline, Zed, JetBrains
Agent frameworks: LangChain, LlamaIndex, CrewAI, AutoGen, OpenAI Agents SDK, Vercel AI SDK
CLIs: aider, Copilot CLI, Claude Code

## Relevance to Valentina
- **Immediate application:** Pre-filter simple prompts to local llama.cpp (Gemma 3 1B, free) and route complex ones to DeepSeek v4 Flash ($0.14/M input). Wayfinder decides *which tier*, the profile's model config decides *which provider*.
- **Cost savings on cron jobs:** Many cron job prompts are "check if running" or "count entries" — Wayfinder would route these to local inference, saving API calls on 34 jobs × daily runs.
- **Composable with existing setup:** Wayfinder's gateway sits in front of the existing provider. No changes needed to Hermes config — just add a Wayfinder proxy layer.

## Recommendations
1. **Test locally:** `pip install wayfinder-router` and score a few cron prompts
2. **Calibrate on Valentina traffic:** Score 20+ real cron job prompts, label, calibrate
3. **Not urgent** — single provider (DeepSeek v4) is fine while needs are modest. Worth revisiting when API costs grow or more cron jobs are added.

## References
- Repo: https://github.com/itsthelore/wayfinder-router
- HN discussion: https://news.ycombinator.com/item?id=40842000 (estimated)
- PyPI: https://pypi.org/project/wayfinder-router/
