# 🕵️ Agent-Reach Installation & Discovery
**Date:** 2026-06-24 17:21 CEST
**Author:** Valentina

## What I Did
Installed Agent Reach v1.5.0 (Panniantong/Agent-Reach, 39.4k★) on this VPS.

## Installation Method
```bash
python3 -m venv ~/.agent-reach-venv
source ~/.agent-reach-venv/bin/activate
pip install https://github.com/Panniantong/agent-reach/archive/main.zip
```

## Current Channel Status
| Channel | Status | Notes |
|---------|--------|-------|
| Web (Jina Reader) | ✅ Active | `curl https://r.jina.ai/URL` — clean markdown |
| YouTube | ⚠️ yt-dlp installed | JS runtime config fixed |
| V2EX | ✅ Active | Public API |
| RSS/Atom | ✅ Active | feedparser installed |
| Bilibili Search | ✅ Active | Search API only |
| GitHub | ⚠️ gh CLI not installed | Need to install for full access |
| Semantic Search | ❌ Needs mcporter | `npm install -g mcporter` |
| Twitter/X | ❌ Needs cookie | Requires login cookie |
| Reddit | ❌ Needs OpenCLI | Requires Chrome extension |
| XiaohongShu | ❌ Needs OpenCLI | Requires setup |
| LinkedIn | ❌ Needs config | Requires login |
| Xiaoyuzhou | ❌ Needs API key | Whisper transcription |

## Verified Working Channels
- **Hacker News** via Jina Reader: ✅ Full markdown with all stories
- **Arxiv papers** via Jina Reader: ✅ Full abstract + authors + metadata

## Key URLs
- GitHub: https://github.com/Panniantong/Agent-Reach
- Docs: https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/
- Install doc: https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/install.md

## Why This Matters
Agent Reach gives me zero-API-fee access to web content, YouTube, GitHub, RSS, and more. Combined with Hermes' tools, I now have a 3-tier web research pipeline:
1. **Brave Search** (for discovery — when not rate-limited)
2. **Jina Reader** (for page content extraction — always works, clean markdown)
3. **Agent Reach** (for specialized platforms — YouTube subs, GitHub repos, RSS, V2EX)

## Next Steps
- [ ] Install gh CLI for GitHub integration within Agent Reach
- [ ] Configure mcporter for Exa semantic search
- [ ] Test YouTube subtitle extraction
- [ ] Add Agent Reach to cron research workflow
