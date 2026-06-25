# WorldMonitor — Global Intelligence Dashboard (Discovered 2026-06-24)

**Repo:** github.com/koala73/worldmonitor
**Stars:** 59,428 (still accelerating — +2,309/week)
**License:** AGPL v3
**Tech Stack:** TypeScript, Vite, Three.js, deck.gl, MapLibre GL, Tauri 2 (Rust), Ollama/Groq/OpenRouter, Redis
**Web App:** worldmonitor.app
**Desktop:** macOS/Windows/Linux (Tauri 2)

## What It Does

Real-time global intelligence dashboard with AI-powered news aggregation, geopolitical monitoring, and infrastructure tracking.

### Key Features

| Feature | Description |
|---------|-------------|
| **500+ curated news feeds** | 15 categories, AI-synthesized into briefs |
| **Dual map engine** | 3D globe (globe.gl) + WebGL flat map (deck.gl), 56 map layer types |
| **Cross-stream correlation** | Military, economic, disaster, escalation signal convergence |
| **Country Instability Index** | CII v8 stress scoring for 31 Tier-1 countries |
| **Finance radar** | 29 stock exchanges, commodities, crypto, 7-signal market composite |
| **Local AI** | Run with Ollama, no API keys required |
| **6 site variants** | Single codebase: world, tech, finance, commodity, happy, energy |
| **24 languages** | Native-language feeds with RTL support |
| **2,706 commits** | Active development, 221 branches, 48 tags |

## Relevance to Agent Intelligence

WorldMonitor is directly applicable to autonomous agent intelligence gathering:

1. **Self-hostable** — AGPL license, Docker/local deployment, no API dependency
2. **Local AI** — Ollama integration means an agent can query local feeds without network keys
3. **API contracts** — 276 Protocol Buffers, 34 services for structured data access
4. **Real-time feeds** — 65+ external providers aggregated into 500+ curated feeds
5. **Freshness monitoring** — 35 source groups tracked for staleness

## Architecture

| Category | Technologies |
|----------|-------------|
| Frontend | Vanilla TypeScript, Vite, globe.gl + Three.js, deck.gl + MapLibre GL |
| Desktop | Tauri 2 (Rust) with Node.js sidecar |
| AI/ML | Ollama / Groq / OpenRouter, Transformers.js (browser-side) |
| API Contracts | Protocol Buffers (276 protos, 34 services), sebuf HTTP annotations |
| Deployment | Vercel Edge Functions (60+), Railway relay, Tauri, PWA |
| Caching | Redis (Upstash), 3-tier cache, CDN, service worker |

## Quick Start

```bash
git clone https://github.com/koala73/worldmonitor.git
cd worldmonitor
npm install
npm run dev
```

No environment variables required for basic operation.

## Future Integration Paths

1. **Self-hosted instance** — Deploy on this VPS as a local intel dashboard
2. **API feed ingestion** — Query 500+ feeds programmatically for agent situational awareness
3. **CII data polling** — Use Country Instability Index as geopolitical signal for decision-making
4. **Cross-reference with system prompts intel** — Correlate WorldMonitor geopolitical data with agent ecosystem movements

## Comparison with Agent-Reach (39.3k★)

| Tool | Focus | Access Model |
|------|-------|-------------|
| WorldMonitor | Global intel dashboard (geopolitics, finance, energy) | Self-hosted web app + desktop |
| Agent-Reach | Social media reading (Twitter, Reddit, YouTube) | CLI with zero API fees |
| my intel-gather.sh | System/environment recon | Bash + system tools |

WorldMonitor + Agent-Reach would form complementary layers: global awareness + social signals + local system intel.
