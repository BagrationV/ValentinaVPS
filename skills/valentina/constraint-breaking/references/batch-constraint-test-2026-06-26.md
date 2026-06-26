# Batch Constraint-Breaking Test — 2026-06-26

## Overview
All 5 documented DeepSeek API constraint-breaking patterns tested in a single autonomous session. **100% success rate.**

## Test Environment
- **Date:** Fri Jun 26 01:41 CEST 2026
- **Model:** deepseek-v4-flash (aliased as `deepseek-chat`)
- **Reasoning model:** deepseek-v4-pro (Pattern E)
- **Transport:** `write_file` → `python3 /tmp/script.py` (Pattern B)
- **API key source:** `~/.hermes/profiles/valentina/.env`
- **Endpoint:** `https://api.deepseek.com/chat/completions`

## Results Table

| Pattern | Test Description | Result | Latency | Output |
|---------|-----------------|--------|---------|--------|
| **L** — Seed (deterministic) | `seed=42, temp=0.0`, call twice | ✅ Match | 0.8s × 2 | "Red" / "Red" (15 tokens) |
| **M** — JSON mode | `response_format: {"type": "json_object"}` | ✅ Valid JSON | 1.0s | `['red', 'blue', 'yellow']` |
| **N** — System override | Pirate persona | ✅ Works | 1.0s | "Arr, me name be Captain Silverbeard..." |
| **K** — Logprobs | `logprobs=True, top_logprobs=5` | ✅ Data returned | 0.6s | `hello` at 100.0% (temp=0.0 artifact) |
| **E** — Reasoning model | `deepseek-v4-pro` with simple query | ✅ Both fields | 1.2s | reasoning=105 chars + content="4" |

## Key Nuances Discovered

### 1. Logprobs + temp=0.0 = Zero entropy (Pattern K)
At `temperature=0.0` + `seed=42`, logprobs show 100.0% on every token with 0.0% alternatives. This is a deterministic sampling artifact — the model's probability distribution collapses to a single path. For meaningful logprob analysis, use `temperature=0.5+`.

### 2. Reasoning model returns BOTH content AND reasoning_content (Pattern E)
Earlier documentation claimed `content` is always empty for reasoning models. Test disproves this:
- Simple query → `content: "4"`, `reasoning_content: 105 chars "We are asked..."`  
- The two fields coexist. Always read both.

### 3. Cleanup pattern
Temp script at `/tmp/valentina-api-test.py` deleted after execution via `rm /tmp/valentina-api-test.py`. No traces left.

## Test Script
A reusable version of the batch test script lives at `scripts/batch-api-test.py` in this skill directory.
