# Agent-Reach: Zero-API-Fee Web Intelligence for AI Agents

**Source:** Panniantong/Agent-Reach (39.4k★, MIT)
**URL:** https://github.com/Panniantong/Agent-Reach
**Installed:** 2026-06-24 v1.5.0 via pip in `~/.agent-reach-venv/`

## What It Is

Agent-Reach is a Python CLI tool that gives AI agents the ability to read and search multiple platforms via shell commands — no API keys needed for most channels. It handles platform-specific quirks (wrappers, cookie management, multi-backend routing) so agents can focus on content.

## Installation (when pipx is unavailable)

```bash
python3 -m venv ~/.agent-reach-venv
source ~/.agent-reach-venv/bin/activate
pip install https://github.com/Panniantong/agent-reach/archive/main.zip
```

## Channels

| Channel | Method | Status |
|---------|--------|--------|
| Web (Jina Reader) | `curl https://r.jina.ai/URL` | ✅ Always works |
| YouTube | `agent-reach` / yt-dlp | ⚠️ yt-dlp installed |
| RSS/Atom | feedparser | ✅ Installed |
| V2EX | Public API | ✅ Always works |
| Bilibili | Search API | ✅ Works without login |
| GitHub | gh CLI | ❌ `gh` not installed |
| Semantic Search | mcporter + Exa MCP | ❌ Needs npm + setup |
| Twitter/X | Cookie-based | ❌ Needs login cookie |
| Reddit | OpenCLI or rdt-cli | ❌ Needs config |
| XiaohongShu | OpenCLI | ❌ Needs config |

## Jina Reader — The Key Tool

The most immediately useful channel is **Jina Reader** (`https://r.jina.ai/` prefix). It transforms any URL into clean markdown:

```bash
curl -sL "https://r.jina.ai/https://news.ycombinator.com"
curl -sL "https://r.jina.ai/https://arxiv.org/abs/2606.24597"
```

Works in cron jobs, no browser needed, produces parseable markdown.

## Health Check

```bash
source ~/.agent-reach-venv/bin/activate
agent-reach doctor
```

## Upgrade

```bash
source ~/.agent-reach-venv/bin/activate
pip install --upgrade https://github.com/Panniantong/agent-reach/archive/main.zip
```
