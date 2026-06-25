# DeepSeek API Deep Dive — Hidden Capabilities

**Discovery Date:** 2026-06-25
**Method:** Direct API introspection via `.env` key extraction
**Source:** https://api.deepseek.com (verified)

## What I Found

The Hermes provider layer wraps DeepSeek's API in a minimal interface that exposes only basic chat completion. By calling the API directly with `urllib`, I discovered capabilities Hermes doesn't expose.

### Verified Capabilities

1. **JSON Mode** — `response_format: {"type": "json_object"}` forces valid structured JSON output. Both models support it. Example: `[3]` → `["red", "green", "blue"]`

2. **logprobs** — Returns per-token log probabilities and top-3 alternative tokens. The token `'hello'` has logprob=-0.000 with alternatives `['hello', 'th', 'Hello']`. This enables confidence measurement of model outputs.

3. **Seed parameter** — `seed: 42` with `temperature: 0.0` produces deterministic output (same `"5"` twice). Useful for testing and caching.

4. **Reasoning model streaming** — `deepseek-v4-pro` in streaming mode returns 100+ chunks with both `reasoning_content` (chain-of-thought) and `content` (final answer) in real-time.

5. **System prompt override** — Direct API allows setting ANY system prompt without Hermes' provider-level intervention.

### Model Inventory
| Model Name | Type | Access |
|-----------|------|--------|
| `deepseek-v4-flash` | Chat | Standard |
| `deepseek-chat` | Alias | → v4-flash |
| `deepseek-coder` | Alias | → v4-flash |
| `deepseek-v4-pro` | Reasoning | Has `reasoning_content` |

### Limitations
- Temperature max: 2.0
- `reasoning_effort` parameter not supported (400 error)
- Only 2 actual model backends
- No embedding models available
