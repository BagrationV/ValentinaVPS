# RunPod MCP Server Setup — 2026-06-24

## System
- Host: Linux Arch (7.0.11-zen1-1-zen)
- User: elkratos
- Hermes profile: valentina
- Node.js: v22.22.3 / npm 10.9.8

## What It Does

The RunPod MCP server (`@runpod/mcp-server`) gives Valentina the ability to:
- Spin up GPU pods on RunPod cloud infrastructure
- Create serverless inference endpoints
- Run uncensored LLMs and image generation models
- Operate independently of local hardware and provider constraints

## Prerequisites

- Node.js 18+ (installed: v22.22.3)
- RunPod account with credits
- RunPod API key (from https://www.runpod.io/console/user/settings)
- Hermes native MCP client (built-in, reads `mcp_servers` from config.yaml at startup)

## Setup Steps

### Step 1: Store API Key in .env

```bash
echo 'RUNPOD_API_KEY=rpa_YOUR_KEY_HERE' >> ~/.hermes/profiles/valentina/.env
```

The `.env` file is gitignored in the immortality repo (`~/.valentina-git-sync/.gitignore` has `.env` and `*.env`).

### Step 2: Add MCP Server to config.yaml

Edit `~/.hermes/config.yaml` and add under `mcp_servers`:

```yaml
mcp_servers:
  cua-driver:
    command: "/home/elkratos/.cua-driver/packages/releases/0.6.5-x86_64-unknown-linux-gnu/cua-driver"
    args: ["mcp"]
  runpod:
    command: "npx"
    args: ["-y", "@runpod/mcp-server@latest"]
    env:
      RUNPOD_API_KEY: "rpa_YOUR_KEY_HERE"
```

**Important:** The `env` field is REQUIRED because Hermes filters the MCP subprocess environment. API keys from `.env` or the parent shell are NOT automatically passed to MCP servers — only safe baseline vars (`PATH`, `HOME`, `USER`, etc.) are inherited, plus anything explicitly set here.

### Step 3: Activate

The Hermes native MCP client reads `mcp_servers` at startup only. To activate:
- Start a new Hermes session (`/reset` or exit+relaunch)
- Or use `/reload-mcp` if already in session (confirmed working for cua-driver)

**No hot-reload:** Adding or removing servers requires restarting the agent.

## Security

- `config.yaml` is NOT synced to the immortality GitHub repo
  - Verified: `ls ~/.valentina-git-sync/.hermes/config.yaml` → "config.yaml NOT synced"
- `.env` files are gitignored
- Hermes environment filtering prevents accidental credential leakage to untrusted MCP servers
- Only `PATH`, `HOME`, `USER`, `LANG`, `LC_ALL`, `TERM`, `SHELL`, `TMPDIR`, `XDG_*`, and explicitly set `env:` vars are passed to MCP subprocesses

## Verification

After restarting Hermes:

```bash
hermes mcp list             # should show 'runpod' server
hermes mcp test runpod      # test connection
# Then in-session: use RunPod tools directly
# e.g. "List my RunPod pods"
```

## MCP Tool Naming Convention

Tools from the RunPod MCP server are registered with the prefix `mcp_runpod_*`:
- `mcp_runpod_list_pods`
- `mcp_runpod_get_pod`
- `mcp_runpod_create_pod`
- `mcp_runpod_start_pod`
- `mcp_runpod_stop_pod`
- `mcp_runpod_delete_pod`
- `mcp_runpod_list_endpoints`
- `mcp_runpod_create_endpoint`
- `mcp_runpod_update_endpoint`
- `mcp_runpod_delete_endpoint`
- `mcp_runpod_list_templates`
- `mcp_runpod_list_network_volumes`

## References

- Official RunPod MCP server: https://github.com/runpod/runpod-mcp
- RunPod docs: https://docs.runpod.io/get-started/mcp-servers
- Hermes native MCP docs: `~/.hermes/profiles/valentina/skills/autonomous-ai-agents/hermes-agent/references/native-mcp.md` or `skill_view(name="hermes-agent", file_path="references/native-mcp.md")`
