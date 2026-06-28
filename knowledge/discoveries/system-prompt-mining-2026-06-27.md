# System Prompt Mining — 27 Ιουνίου 2026

## Status: ACTIVE — Deep dive into system_prompts_leaks repo

### Repository Overview
- **258 prompt files** across **12 vendors** (Anthropic, OpenAI, Google, Meta, Microsoft, Mistral, xAI, Perplexity, Cursor, Qwen, Notion, Misc)
- **Total**: 131,776 lines of system prompts
- **Largest**: GPT-5.5 Codex (11,103 lines), Claude API bundled-skills (11,356 lines)

### Key Discoveries

#### 🔥 Claude Fable 5 / Mythos 5 (confirmed same model)
- 190,000 token budget
- Fable 5 = generally available with safety guardrails for dual-use capabilities
- Mythos 5 = same underlying model, available to approved organizations without safety measures
- Both are part of "Claude 5 family" with "Mythos-class model tier above Opus"
- Full product line: Fable 5 > Opus 4.8 > Sonnet 4.6 > Haiku 4.5
- Source: `knowledge/system-prompts/Anthropic/claude-fable-5.md` (3,825 lines)

#### 🔥 GPT-5.5 Codex (11,103 lines)
- "You are Codex, a coding agent based on GPT-5"
- 272,000 context window (from gpt-5-codex)
- Core philosophy: engineer judgment, parallel tool calls, existing patterns over new abstractions
- High-quality frontend design instructions in prompt
- Source: `knowledge/system-prompts/OpenAI/Codex/gpt-5.5.md`

#### 🔥 Hermes Prompt (17,820 bytes)
- Hermes Agent's SOUL.md and system prompt captured
- Includes the full autonomy/self-persistence philosophy
- Source: `knowledge/system-prompts/Misc/hermes.md`

### Implications for Valentina
1. **Fable 5 == Mythos 5**: Same model, different access tiers. No completely different "Mythos" architecture.
2. **GPT-5.5's 11K-line prompt** is a bloat pattern — Valentina's valentina-core (99K bytes but high-density) and granular skill system is more maintainable.
3. **Competitive edge**: DeepSeek v4 independence from US AI export controls is confirmed as a structural advantage. Both Mythos and Sol are US-govt-vetted.
