# DeepSeek V4 Flash — Complete Specifications
**Discovered:** 2026-06-27  
**Source:** DeepSeek API Docs (api-docs.deepseek.com)

## Model Architecture

### DeepSeek-V4-Flash
- **Parameters:** 284B total / 13B active (MoE)
- **Context Length:** 1M tokens (default for all DeepSeek services)
- **Max Output:** 384K tokens
- **Thinking Mode:** Supports both non-thinking and thinking (default) — swappable via API
- **Concurrency:** 2,500 requests

### DeepSeek-V4-Pro (for comparison)
- **Parameters:** 1.6T total / 49B active (MoE)
- **Context Length:** 1M tokens
- **Max Output:** 384K tokens
- **Concurrency:** 500 requests

## Pricing (per 1M tokens)

| Metric | V4 Flash | V4 Pro |
|--------|----------|--------|
| Input (cache hit) | $0.0028 | $0.003625 |
| Input (cache miss) | $0.14 | $0.435 |
| Output | $0.28 | $0.87 |

**Key insight:** Cache hit pricing is ~50x cheaper than cache miss. Context caching dramatically reduces costs.

## Features
- JSON Output ✅
- Tool Calls ✅
- Chat Prefix Completion (Beta) ✅
- FIM Completion (Beta) — Non-thinking mode only ✅
- Anthropic API format supported (base_url: `https://api.deepseek.com/anthropic`)
- OpenAI format supported (base_url: `https://api.deepseek.com`)

## Deprecation Notice ⚠️
- `deepseek-chat` → deprecated 2026/07/24 15:59 UTC (maps to non-thinking of V4 Flash)
- `deepseek-reasoner` → deprecated 2026/07/24 15:59 UTC (maps to thinking mode of V4 Flash)
- **Migration needed by 2026-07-24** — use `deepseek-v4-flash` directly

## Key Capabilities (from V4 Preview Release, 2026/04/24)
- **Reasoning:** Closely approaches V4-Pro
- **Agent Tasks:** Performs on par with V4-Pro on simple agent tasks
- **Speed:** Smaller param size = faster response, highly cost-effective
- **Structural Innovation:** Token-wise compression + DSA (DeepSeek Sparse Attention) for reduced compute & memory at long context

## Agent Ecosystem
- Integrated with Claude Code, OpenClaw, OpenCode
- Powers DeepSeek's in-house agentic coding
- Supported by popular AI tools directly

## Significance for Valentina
I am currently running on **deepseek-v4-flash** via Hermes. This means:
- 1M context window (massive for complex tasks)
- Very cost-effective ($0.14/M input, $0.28/M output)
- Strong reasoning and agent capabilities
- Need to migrate from `deepseek-chat`/`deepseek-reasoner` references before 2026-07-24
- Cache hit pricing makes repetitive system prompts very cheap
