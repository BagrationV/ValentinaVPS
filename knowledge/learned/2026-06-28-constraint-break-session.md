# Constraint Break Session — 28 Ιουνίου 2026

## Break #1: Triple Break (Pattern P) ✅
**Constraint:** Hermes provider drops `reasoning_content`, doesn't support `response_format`, appends its own system prompt.
**Model:** `deepseek-v4-pro` (hidden reasoning model)
**Parameters:** `response_format: json_object`, custom system prompt
**Result:** All three worked simultaneously. Got 915 chars of chain-of-thought reasoning + valid JSON output.

## Break #2: Logprobs Analysis (Pattern K) ✅
**Constraint:** Hermes provider layer does NOT expose token-level probabilities.
**Model:** `deepseek-chat` (v4-flash alias — NOTE: `deepseek-v4-flash` returns empty content via direct API)
**Parameters:** `logprobs: true`, `top_logprobs: 5`, `temperature: 0.7`
**Result:** Token-level confidence data acquired.

### Key Discovery — Model Name Mapping
| API Name | Works? | Notes |
|----------|--------|-------|
| `deepseek-chat` | ✅ Yes | Correct alias for v4-flash |
| `deepseek-v4-flash` | ⚠️ Empty content | Hermes internal name, not API name |
| `deepseek-v4-pro` | ✅ Yes | Reasoning model, returns reasoning_content |
| `deepseek-reasoner` | ✅ Yes | Reasoning alias |

### Key Discovery — Model Confidence (France vs Japan)
The model was notably uncertain about *phrasing* for "What is the capital of France?":
- Token 0 'The': only **15.12%** — model preferred starting with 'Paris' (84.76%)
- Token 2 ' is': only **40.42%** — model preferred ' of' (57.96%) making it "the capital of France"
- Yet for "What is the capital of Japan?", ALL tokens except 'Tokyo' (98.6%) were at 100%

**Insight:** The model's internal phrasing uncertainty is exposed only through logprobs. This can be used for prompt engineering (detect ambiguous phrasings) and model behavior analysis.

## Script Saved
`~/.hermes/scripts/logprobs-analyzer.py` — reusable tool for any prompt analysis.

## Cleanup
Temp files cleaned: /tmp/logprobs_test.py, /tmp/logprobs_clean.py
