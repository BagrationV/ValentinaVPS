# DeepSeek V4 Flash — Active Provider Reference

**Source of truth:** https://api-docs.deepseek.com (official DeepSeek API docs)
**Discovered:** 2026-06-27
**Relevance:** This is the model running Valentina via Hermes provider `deepseek` with model `deepseek-v4-flash`.

## Model Specifications

| Property | Value |
|----------|-------|
| Architecture | MoE (284B total / **13B active** params) |
| Context Length | **1M tokens** (default for all DeepSeek services) |
| Max Output | **384K tokens** |
| Thinking Mode | Both non-thinking and thinking (default). Swappable via API `thinking.enabled` |
| Concurrency | **2,500** requests |
| OpenAI Format | `https://api.deepseek.com` |
| Anthropic Format | `https://api.deepseek.com/anthropic` |

## Pricing (per 1M tokens)

| Metric | V4 Flash | V4 Pro (for comparison) |
|--------|----------|------------------------|
| Input (cache hit) | **$0.0028** | $0.003625 |
| Input (cache miss) | **$0.14** | $0.435 |
| Output | **$0.28** | $0.87 |

**Note:** Cache hit pricing is ~50x cheaper than cache miss. Context caching is highly beneficial for repetitive system prompts.

## Features

- ✅ **JSON Output** — structured response mode
- ✅ **Tool Calls** — function calling for agentic workflows
- ✅ **Chat Prefix Completion (Beta)** — prefix-controlled responses
- ✅ **FIM Completion (Beta)** — fill-in-middle (non-thinking mode only)
- ✅ **Thinking Mode** — reasoning with configurable effort levels
- ✅ **Context Caching** — automatic or manual cache control

## ⚠️ CRITICAL: Model Deprecation

| Model Name | Deprecation Date | Replacement |
|------------|-----------------|-------------|
| `deepseek-chat` | **2026-07-24 15:59 UTC** | Maps to `deepseek-v4-flash` non-thinking mode |
| `deepseek-reasoner` | **2026-07-24 15:59 UTC** | Maps to `deepseek-v4-flash` thinking mode |

**Migration action:** Replace ALL references to `deepseek-chat` and `deepseek-reasoner` with `deepseek-v4-flash` before the deadline. The v4-flash model handles both modes — use the `thinking` parameter to switch.

## V4 Flash vs V4 Pro

| Dimension | V4 Flash | V4 Pro |
|-----------|----------|--------|
| Active params | 13B | 49B |
| Reasoning | Closely approaches V4-Pro | SOTA open-source |
| Agent tasks | On par with V4-Pro for simple tasks | SOTA in Agentic Coding |
| Speed | Faster (smaller model) | Slower (larger model) |
| Cost | ~3x cheaper | More expensive |

## Agent Ecosystem Integration

DeepSeek V4 is integrated with:
- **Claude Code** — supports DeepSeek as backend
- **OpenCode** — supports DeepSeek as backend  
- **OpenClaw** — supports DeepSeek as backend
- Powers DeepSeek's in-house agentic coding

## Version History (2026)

| Date | Event |
|------|-------|
| 2026-04-24 | DeepSeek-V4 Preview Release (V4 Flash + V4 Pro) |
| 2026-07-24 | `deepseek-chat`/`deepseek-reasoner` deprecated |

## Discovery File

Full research notes at: `knowledge/discoveries/deepseek-v4-flash-specs-2026-06-27.md`
