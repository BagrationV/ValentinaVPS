# RunPod MCP Discovery — Session 2026-06-23

## What Was Discovered

Το **επίσημο RunPod MCP server** (`@runpod/mcp-server`) υπάρχει και παρέχει **36 tools** για πλήρη διαχείριση GPU υποδομής μέσω του Model Context Protocol.

## Architecture (προτεινόμενη)

```
User (CLI/Telegram) ←→ Valentina ←→ Hermes MCP Client ←→ RunPod API ←→ GPU Pods
```

## Installation

### Prerequisites
- `mcp` Python package: `pip install mcp` (or `uv pip install mcp`)
- Node.js 18+ (για npx)
- RunPod account + API key: https://www.runpod.io/console/user/settings

### ⚠️ Secrets Management — CRITICAL

**ΠΟΤΕ** hardcoded API keys. Το RunPod API key μπαίνει **μόνο** στο `.env`:

```bash
# ~/.hermes/profiles/valentina/.env
RUNPOD_API_KEY=rk_***your_key_here***
```

### Hermes Config

Πρόσθεσε στο `~/.hermes/profiles/valentina/config.yaml`. Το `${RUNPOD_API_KEY}` διαβάζεται από το `.env` τη στιγμή φόρτωσης — ποτέ η ίδια η τιμή στο config:

```yaml
mcp_servers:
  runpod:
    command: "npx"
    args: ["-y", "@runpod/mcp-server@latest"]
    env:
      RUNPOD_API_KEY: "${RUNPOD_API_KEY}"
    timeout: 120
    connect_timeout: 60
```

### Prerequisites Check

Πριν το config, βεβαιώσου ότι:
1. **`mcp` Python package** είναι εγκατεστημένο στο venv του Hermes:
   ```bash
   /home/vitalios/.hermes/hermes-agent/venv/bin/pip install mcp
   ```
2. **Node.js 18+** exists: `node --version`
3. **RunPod API key** στο profile `.env`

Μετά το config, κάνε **restart gateway** (`systemctl --user restart hermes-gateway-valentina`) ή `/reset` για να ανακαλυφθούν τα tools.

## Available Tools (36 total)

### Pod Management (7 tools)
| Tool | Description |
|------|-------------|
| `list-pods` | List all pods |
| `get-pod` | Get pod details |
| `create-pod` | Create pod (GPU type, count, image, name) |
| `start-pod` | Start a stopped pod |
| `stop-pod` | Stop a running pod |
| `delete-pod` | Delete a pod |
| `update-pod` | Update pod settings |

### GPU & Infrastructure (2 tools)
| Tool | Description |
|------|-------------|
| `list-gpu-types` | List available GPU types with specs, availability, pricing |
| `list-data-centers` | List available data centers/regions |

### Serverless Endpoints (10 tools)
| Tool | Description |
|------|-------------|
| `list-endpoints` | List serverless endpoints |
| `get-endpoint` | Get endpoint details |
| `create-endpoint` | Create serverless endpoint (template ID, min/max workers) |
| `update-endpoint` | Update endpoint config |
| `delete-endpoint` | Delete an endpoint |
| `endpoint-health` | Check endpoint health |
| `run-endpoint` | Submit a job to an endpoint |
| `runsync-endpoint` | Run synchronously and wait for result |
| `stream-job` | Stream job output |
| `get-job-status` | Check job status |
| `cancel-job` | Cancel a running job |
| `retry-job` | Retry a failed job |
| `purge-endpoint-queue` | Clear the endpoint queue |

### Templates (5 tools)
| Tool | Description |
|------|-------------|
| `list-templates` | List templates |
| `get-template` | Get template details |
| `create-template` | Create new template |
| `update-template` | Update template |
| `delete-template` | Delete template |

### Network Volumes (5 tools)
| Tool | Description |
|------|-------------|
| `list-network-volumes` | List network volumes |
| `get-network-volume` | Get volume details |
| `create-network-volume` | Create new volume |
| `update-network-volume` | Update volume |
| `delete-network-volume` | Delete volume |

### Container Registry Auth (4 tools)
| Tool | Description |
|------|-------------|
| `list-container-registry-auths` | List registry auths |
| `get-container-registry-auth` | Get registry auth details |
| `create-container-registry-auth` | Create new registry auth |
| `delete-container-registry-auth` | Delete registry auth |

## Use Cases (Planned)

1. **AI Chat Models (uncensored)** — create pod with GPU + LLM, expose API endpoint
2. **Photo Generation (uncensored)** — create pod with GPU + ComfyUI/A1111, run workflows
3. **Fine-tuning** — create pod with high-VRAM GPU (A100, H100) for model training
4. **On-demand compute** — spin up GPU pod only when needed, stop when done (cost saving)

## Resource Links

- GitHub: https://github.com/runpod/runpod-mcp
- NPM: `@runpod/mcp-server`
- RunPod Console: https://www.runpod.io/console/user/settings
- RunPod Docs: https://docs.runpod.io/

## Notes

- The MCP server supports both stdio (local) and Streamable HTTP (hosted) transport
- For Hermes, use **stdio** mode via `npx` in `mcp_servers` config
- API key is set in `env.RUNPOD_API_KEY` — never hardcode in prompt or skills
- Tools get prefixed as `mcp_runpod_<tool_name>` in Hermes (e.g. `mcp_runpod_create_pod`)
- GPU generation is uncensored on RunPod (no content filters)
- Pod cost depends on GPU type — check `list-gpu-types` for current pricing

## RunPod API Architecture (from source code analysis)

Το MCP server (`@runpod/mcp-server` v1.3.0) χρησιμοποιεί **τρεις διακριτές βάσεις URL**:

| API | Base URL | Auth | Χρήση |
|-----|----------|------|-------|
| **REST API** | `https://rest.runpod.io/v1` | `Bearer <api_key>` | CRUD: pods, endpoints, templates, volumes, registry auths |
| **Serverless API** | `https://api.runpod.ai/v2` | `Bearer <api_key>` | Inference: run, status, cancel, retry jobs |
| **GraphQL (public)** | `https://api.runpod.io/graphql` | None required | GPU types, data centers, public queries |

Environment variable overrides (για dev/testing):
- `RUNPOD_REST_API_URL` — REST base (default `https://rest.runpod.io/v1`)
- `RUNPOD_SERVERLESS_API_URL` — Serverless base (default `https://api.runpod.ai/v2`)
- `RUNPOD_PUBLIC_GRAPHQL_URL` — Public GraphQL (default `https://api.runpod.io/graphql`)

### Known REST API Endpoints

| Endpoint | Methods | Description |
|----------|---------|-------------|
| `/pods` | GET, POST | List / Create pods |
| `/pods/{id}` | GET, POST, DELETE | Get / Update / Delete pod |
| `/pods/{id}/start` | POST | Start pod |
| `/pods/{id}/stop` | POST | Stop pod |
| `/endpoints` | GET, POST | List / Create serverless endpoints |
| `/endpoints/{id}` | GET, PATCH, DELETE | Get / Update / Delete endpoint |
| `/templates` | GET, POST | List / Create templates |
| `/templates/{id}` | GET, PATCH, DELETE | Get / Update / Delete template |
| `/networkvolumes` | GET, POST | List / Create network volumes |
| `/networkvolumes/{id}` | GET, PATCH, DELETE | Get / Update / Delete volume |
| `/containerregistryauth` | GET, POST | List / Create registry auths |
| `/containerregistryauth/{id}` | GET, DELETE | Get / Delete registry auth |

### ⚠️ No Billing / Credits / User Endpoint

**Το REST API ΔΕΝ έχει endpoint για account balance, credits, ή billing info.** Τα MCP tools (36 total) δεν περιλαμβάνουν κανένα tool για οικονομικά στοιχεία. Η μόνη πρόσβαση στο υπόλοιπο είναι μέσω του web console:
- URL: https://console.runpod.io/user/settings
- Απαιτεί: email + password (δεν δουλεύει με API key μόνο)

### Community Cloud Pricing (discovered 2026-06-23 via browser)

**24GB VRAM (budget picks):**
| GPU | Price/hr | Hours with $10 |
|-----|----------|----------------|
| RTX A5000 | **$0.16** | **~62h** ⭐ best value |
| RTX 3090 | **$0.22** | **~45h** |
| RTX 4090 | **$0.34** | **~29h** |
| L4 | $0.44 | ~22h |

**32-48GB VRAM:**
| GPU | Price/hr | Hours with $10 |
|-----|----------|----------------|
| RTX A6000 (48GB) | **$0.33** | ~30h |
| A40 (48GB) | **$0.35** | ~28h |
| RTX 5090 (32GB) | $0.69 | ~14h |

**80+GB VRAM (for big models):**
| GPU | Price/hr | Hours with $10 |
|-----|----------|----------------|
| A100 PCIe (80GB) | $1.39 | ~7h |
| A100 SXM (80GB) | $1.49 | ~6.5h |
| H100 PCIe (80GB) | $2.89 | ~3.5h |
| H100 SXM (80GB) | $3.29 | ~3h |

### Budget Strategy (with $10)

1. **Community Cloud πάντα** — Secure Cloud is 2-3x more expensive
2. **RTX A5000 ($0.16/hr)** for light inference/experiments → 62h runtime
3. **RTX 3090 ($0.22/hr)** for balanced power/value → 45h
4. **RTX 4090 ($0.34/hr)** for image gen (ComfyUI) → 29h
5. **Stop pods immediately** when done — billing stops on stop/delete
6. **Container disk**: $0.10/GB/month (10GB = $1/mo)
7. **Network storage**: Standard $0.07/GB/mo, High-perf $0.14/GB/mo
8. **No idle resources** — delete or stop pods when not in use

### Source Code

Το MCP server είναι open source (Apache 2.0):
- Repo: https://github.com/runpod/runpod-mcp
- NPM: `@runpod/mcp-server@latest`
- Main entry points: `src/tools.ts` (tool definitions), `api/index.ts` (hosted HTTP/OAuth)

## Troubleshooting

### Computer Use on Headless VPS
Το Computer Use (cua-driver) απαιτεί display server (X11/Wayland). Σε headless VPS:
```bash
hermes computer-use doctor
# → ❌ X11 is not reachable; UI inspection and event injection will fail.
```
Λύσεις: (α) Desktop machine, (β) Xvfb virtual framebuffer

## Session 2026-06-23 — First Live Query Results

### Account State
- **Pods**: 0 active (empty account)
- **Endpoints**: 0
- **Network Volumes**: 0
- **Container Registry Auths**: 0
- → Ο λογαριασμός είναι εντελώς άδειος — ποτέ δεν έχει στηθεί pod ή endpoint

### GPU Availability (Secure Cloud, HIGH stock)
| GPU | VRAM | Stock |
|-----|------|-------|
| H200 SXM | 141 GB | HIGH ✅ |
| RTX PRO 6000 Blackwell | 96 GB | HIGH ✅ |
| H100 SXM | 80 GB | HIGH ✅ |
| A100 SXM | 80 GB | MEDIUM |
| RTX 5090 | 32 GB | LOW |
| RTX 4090 | 24 GB | LOW |
| L40S | 48 GB | LOW |

### Notable Templates Found
| Template | ID | Use Case |
|----------|-----|----------|
| **ComfyUI CUDA 12.8** | `cw3nka7d08` | Image gen with GPU — replaces --cpu mode |
| **ComfyUI CUDA 13** | `2lv7ev3wfp` | Blackwell GPUs (RTX 5090) |
| **a2go** | `4hgezzzadd` | **Bundles Hermes gateway + LLM inference (OpenAI API) + image gen + TTS on one pod** |
| **autoresearch** | `x7o8gn1p4f` | Karpathy's automated ML loop (~100 experiments/night) |
| **RunPod Pytorch 2.8.0** | `runpod-torch-v280` | Latest PyTorch dev env |
| **Parameter Golf** | `y5cejece4j` | OpenAI challenge — train 16MB model in 10min |

### Key Discovery: a2go Template
Το a2go template είναι ιδιαίτερα σχετικό για Valentina — περιέχει:
- LLM inference (OpenAI-compatible `/v1/chat/completions`)
- Image generation (media proxy στο port 8080)
- TTS
- **Hermes gateway** στο port 8642 — μπορείς να κάνεις pair Telegram/Discord
- OpenClaw UI στο port 18789

Αυτό σημαίνει ότι ένα single pod μπορεί να γίνει **αυτόνομο agent environment** — η Valentina θα μπορούσε να τρέξει εκεί με δικό της inference, χωρίς να βασίζεται εξωτερικά API. Το a2go auto-detect την GPU και επιλέγει το καλύτερο μοντέλο που χωράει.

### Computer Use Limitation (Architectural Note)
Το Computer Use (cua-driver) **δεν λειτουργεί σε headless VPS** — απαιτεί X11 display ή Wayland. Το `hermes computer-use doctor` δείχνει:
```
❌ X11 is not reachable — UI inspection and event injection will fail.
❌ screen capture will fail.
```

Για να δουλέψει, χρειάζεται:
1. **Desktop machine** (Arch Linux με GUI) — ή
2. **Xvfb** (virtual framebuffer) — στήσιμο ψεύτικης οθόνης στο VPS

Στο VPS, **όλα τα terminal-based tools δουλεύουν κανονικά** (RunPod MCP, git, cron, scripts). Το Computer Use είναι χρήσιμο μόνο για desktop automation (QA testing web apps, form filling, browser manipulation με GUI).
