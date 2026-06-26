# Codebase Memory MCP — Discovery Report
**Date:** 2026-06-25
**Source:** GitHub trending weekly #3 (14,505★, +9,589 this week)
**Repo:** [DeusData/codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)

## What It Is
High-performance code intelligence MCP server. Indexes entire codebases into a persistent **knowledge graph** — functions, classes, call chains, HTTP routes, cross-service links. Built in pure C, single static binary, zero dependencies.

## Key Specs
| Feature | Value |
|---------|-------|
| **Languages** | 158 (tree-sitter AST + Hybrid LSP for 10 languages) |
| **MCP Tools** | 14 (search, trace, architecture, impact analysis, Cypher, dead code, ADR management) |
| **Speed** | Average repo in milliseconds; Linux kernel (28M LOC) in 3 minutes |
| **Tokens** | ~3,400 vs ~412,000 (120× fewer than file-by-file) |
| **Agents** | Auto-detects 11 agents: Claude Code, Codex, Gemini CLI, Zed, OpenCode, Antigravity, Aider, KiloCode, VS Code, OpenClaw, Kiro |
| **Platform** | macOS (arm64/amd64), Linux (arm64/amd64), Windows (amd64) |
| **Install** | `curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash` |
| **License** | MIT |
| **Arxiv** | [2603.27277](https://arxiv.org/abs/2603.27277) — 83% answer quality, 10× fewer tokens, 2.1× fewer tool calls |
| **Security** | SLSA 3, VirusTotal-scanned every release, signed binaries, 100% local processing |

## MCP Tools (14 total)
Search, code trace, architecture queries, impact analysis, Cypher graph queries, dead code detection, cross-service HTTP linking, ADR management, and more.

## Relevance to Valentina
- **High relevance** — MCP server architecture compatible with Hermes
- **Low immediate priority** — My current codebase exploration needs are minimal (Hermes Python codebase). Useful if I ever need deep code analysis.
- **Security model** — 100% local, no data leaves machine — matches my security posture.
- **Installation path** — Single binary, `install` command, auto-configures agents.

## Assessment
Recommendation: **Explore on next session with κύριε Elkratos.** Install and test with Hermes as an MCP server. The knowledge graph concept is directly applicable to my own evolution — persistent structural memory of a codebase.
