# Web Research: Antigravity & Trae — 2026-06-23

Worked example of the Hear→Search→Dig→Share pattern.

## Trigger

κύριε Elkratos mentioned he built SmartFleet using AI agents including **Antigravity** and **Trae** (alongside Aider and OpenCode).

## Search Results

### Google Antigravity
- **URL**: https://antigravity.google/
- **What**: Google's new "Agent-First IDE" — a VS Code fork
- **Status**: Public preview, experimental
- **Key features**: Planning mode + Fast mode, Agent manager for background tasks, parallel runner concept
- **Model support**: Claude Sonnet, others
- **Critique**: Product direction unclear per The New Stack review — does what Gemini CLI/Jules already do
- **Platform**: Desktop (Mac/Win/Linux)
- **Free tokens**: Yes, with abuse limitations

### Trae Agent (ByteDance)
- **URL**: https://github.com/bytedance/trae-agent
- **Stars**: 11.7k | **Forks**: 1.3k | **License**: MIT
- **What**: LLM-based agent for general purpose software engineering tasks
- **Installation**: `git clone + uv sync + source .venv/bin/activate`
- **CLI**: `trae-cli run "prompt" --provider anthropic --model claude-sonnet-4-20250514`
- **Features**: Lakeview summarization, Multi-LLM (OpenAI/Anthropic/Doubao/Azure/OpenRouter/Ollama/Gemini), Rich tools (bash, file editing, MCP), Interactive mode, Trajectory recording, Docker mode, YAML config
- **Research-friendly**: Transparent modular architecture designed for ablation studies
- **Tech report**: arXiv:2507.23370

## Why It Matters to Elkratos

He used both of these (plus Aider, OpenCode) to build SmartFleet — a full enterprise fleet management system. This is his multi-agent software engineering workflow. Understanding these tools means understanding how he works.

## Future Monitoring

If setting up ongoing awareness:
- Google Antigravity likely to evolve (Google throws experiments; some stick)
- Trae Agent actively developed (ByteDance, 11.7k★, MIT) — worth periodic checks for new features
- Both compete with Cursor, Windsurf, Claude Code, Codex
