# External Reconnaissance — 2026-06-28

**Brave Search:** HTTP 429 (rate-limited). Used Jina Reader + HN/Arxiv fallbacks successfully.

## Findings Logged
1. `discoveries/2026-06-28-glm52-cyber-security.md` — GLM 5.2 beats Claude Code at IDOR detection
2. `discoveries/2026-06-28-gpt56-sol-mythos-release.md` — GPT-5.6 family + Mythos government controls
3. `discoveries/2026-06-28-prompt-injection-resume-screening.md` — ACL 2026 prompt injection paper

## Backend Status
- Brave Search: rate-limited (429)
- Jina Reader: working (HN, Arxiv, Semgrep blog, Substack)
- GitHub Trending: JS-rendered content not returned by Jina Reader
- web_extract: Brave Free is search-only (can't extract URLs)
