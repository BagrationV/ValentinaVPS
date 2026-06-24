# MCP Server Setup & Secrets Management

## Overview

Generic pattern for adding any MCP server to Hermes with **secure credential handling**. Applies to all MCP servers (RunPod, GitHub, filesystem, time, custom APIs, etc.).

## Golden Rule — Secrets in `.env` Only

**ΠΟΤΕ** hardcoded API keys/tokens/passwords in `config.yaml`. Η μόνη θέση για secrets είναι το profile `.env`:

```
~/.hermes/profiles/<profile>/.env
```

Στο `config.yaml`, χρησιμοποιείς **env var reference** με σύνταξη `${VAR_NAME}`:

```yaml
mcp_servers:
  my-server:
    command: "npx"
    args: ["-y", "@some/mcp-server"]
    env:
      SOME_API_KEY: "${SOME_API_KEY}"    # ← reads from .env
      ANOTHER_TOKEN: "${ANOTHER_TOKEN}"  # ← reads from .env
```

Το Hermes κάνει automatic `${VAR}` expansion κατά το loading του config — η πραγματική τιμή ΠΟΤΕ δεν αποθηκεύεται στο config.yaml.

## Step-by-Step Setup

### 1. Install the `mcp` Python Package

Το Hermes χρειάζεται το `mcp` SDK για να επικοινωνήσει με MCP servers. Εγκαθίσταται στο **venv του Hermes**, όχι system-wide:

```bash
/home/vitalios/.hermes/hermes-agent/venv/bin/pip install mcp
```

Χωρίς αυτό, το Hermes βγάζει: `"MCP SDK not available — skipping MCP tool discovery"` και κανένα MCP tool δεν εμφανίζεται.

### 2. Add API Key to `.env`

```bash
# ~/.hermes/profiles/valentina/.env
YOUR_SERVICE_API_KEY=rk_***...***
```

### 3. Configure `mcp_servers` in `config.yaml`

```yaml
mcp_servers:
  my-server:
    command: "npx"           # or "uvx", "node", any executable
    args: ["-y", "@package/mcp-server"]
    env:
      SERVICE_API_KEY: "${YOUR_SERVICE_API_KEY}"
    timeout: 120              # per-tool-call timeout (default: 120)
    connect_timeout: 60       # initial connection timeout (default: 60)
```

**Transport types:**
- **stdio** (command-based): `command` + `args` — local process
- **HTTP** (url-based): `url` + optional `headers` — remote server

### 4. Restart Gateway

Τα MCP tools ανακαλύπτονται **κατά την εκκίνηση** του gateway. Για να τα δεις (δύο τρόποι):

**Μέσω Hermes CLI (προτιμότερο — απλούστερο):**
```bash
hermes gateway restart
```

**Μέσω systemd (όταν το CLI δεν είναι διαθέσιμο):**
```bash
systemctl --user restart hermes-gateway-valentina
```

Και οι δύο τρόποι κάνουν graceful restart — τα running agents τερματίζονται και ξεκινάει νέο gateway process με τα νέα MCP tools.

Μετά το restart, τα tools εμφανίζονται ως `mcp_<server>_<tool_name>` (π.χ. `mcp_runpod_list_pods`, `mcp_github_list_issues`).

### 5. Verify (Πριν το Restart — Προαιρετικό)

Πριν κάνεις restart, μπορείς να επιβεβαιώσεις ότι το MCP server δουλεύει σωστά με `hermes mcp test`:

```bash
hermes mcp test <server-name>
# Π.χ.: hermes mcp test runpod
```

Αυτό δοκιμάζει τη σύνδεση χωρίς να χρειαστεί restart. Αν πετύχει, δείχνει:
```
Testing 'runpod'...
  Transport: stdio → npx
  Auth: none
  ✓ Connected (8137ms)
  ✓ Tools discovered: 36
    list-gpu-types
    list-pods
    create-pod       Create a new GPU/CPU pod...
    ...
```

### 6. Επιβεβαίωση μετά το Restart

```bash
hermes gateway status          # Should show "active (running)"
```

Στο `hermes gateway status`, μπορείς να δεις το MCP subprocess στη λίστα processes:

```
CGroup: .../hermes-gateway-valentina.service
  ├─368417 python -m hermes_cli.main ... gateway run
  ├─368429 "npm exec @runpod/mcp-server@latest"
  ├─368445 sh -c runpod-mcp
  └─368446 node ...runpod-mcp
```

Μετά, κάνε `/reset` ή νέο session. Τα tools θα είναι διαθέσιμα ως `mcp_<server>_<tool_name>`.

### 5. Verify

```bash
hermes gateway status          # Should show "active (running)"
# Start a new session or /reset
# Then ask: "what MCP tools do I have available?"
```

## Common Patterns

### npx-based servers (most common)
```yaml
mcp_servers:
  time:
    command: "npx"
    args: ["-y", "mcp-server-time"]          # no API key needed
  filesystem:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
```

### uvx-based servers (Python tools)
```yaml
mcp_servers:
  my-py-server:
    command: "uvx"
    args: ["mcp-server-mypackage"]
```

### HTTP/remote servers
```yaml
mcp_servers:
  remote-api:
    url: "https://mcp.example.com/v1"
    headers:
      Authorization: "Bearer ${MY_API_TOKEN}"
```

## Environment Variable Filtering

To MCP subprocess **δεν κληρονομεί** όλες τις env vars του Hermes. Μόνο safe baseline vars περνάνε (PATH, HOME, USER, LANG, κλπ.) **συν** ό,τι δηλωθεί στο `env:` block.

Αυτό σημαίνει: ακόμα κι αν το API key είναι στο `.env` και το Hermes το έχει στη μνήμη του, **πρέπει** να το δηλώσεις στο `env:` block του config.yaml για να το δει το MCP subprocess.

```yaml
# WRONG — το subprocess ΔΕΝ θα δει τη μεταβλητή
env: {}
# ή απλά παράλειψη του env

# RIGHT — το subprocess θα πάρει την τιμή
env:
  MY_API_KEY: "${MY_API_KEY}"
```

## Tool Naming Convention

Τα MCP tools εμφανίζονται με το prefix `mcp_<server_name>_`:

- Server `runpod`, tool `list-pods` → `mcp_runpod_list_pods`
- Server `github`, tool `list-issues` → `mcp_github_list_issues`
- Server `my-api`, tool `fetch-data` → `mcp_my_api_fetch_data`

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| "MCP SDK not available" | `mcp` package missing | `pip install mcp` στο Hermes venv |
| Tools not showing | Gateway not restarted | `systemctl --user restart hermes-gateway-valentina` |
| "Failed to connect" | Command not on PATH | Install node/uvx, check `command` spelling |
| "401 Unauthorized" | API key missing/wrong | Check `.env` + `${VAR}` match in config |
| Connection drops | Server unreliable | Auto-retry up to 5x with backoff |
| Permission errors | MCP filtered env | Add all needed vars to `env:` block |

## Pitfalls

- ⚠️ **NEVER put actual key values in config.yaml** — even in comments or examples. Once written, they persist in git history and skill backups.
- ⚠️ **Restart is required** after adding/changing mcp_servers config. `/reset` inside a session is NOT enough — the gateway process must restart.
- ⚠️ **Profile `.env` vs root `.env`**: Τα profile-level `.env` override τα root-level. Ορίζε πάντα τα secrets στο profile `.env` (`~/.hermes/profiles/<profile>/.env`) για απομόνωση μεταξύ profiles.
- ⚠️ **Node.js/npx required** για npx-based servers: `node --version` πρέπει να είναι >= 18.\n- ⚠️ **`hermes config set` δεν δουλεύει για nested mcp_servers env vars** — η εντολή `hermes config set mcp_servers.runpod.env.RUNPOD_API_KEY '${VALUE}'` αποτυγχάνει γιατί προσπαθεί να το αποθηκεύσει ως env variable (uppercased path). **Workaround:** χρησιμοποίησε Python script με `yaml.safe_load`/`yaml.dump` ή επεξεργάσου το config.yaml απευθείας.\n- ⚠️ **Append στο `.env` με `echo` μπορεί να δημιουργήσει duplicates** — αν η μεταβλητή υπάρχει ήδη, το `echo 'KEY=val' >> .env` απλά προσθέτει νέα γραμμή αντί να την αντικαταστήσει. **Καλύτερα:** έλεγξε πρώτα με `grep '^KEY=' .env` ή χρησιμοποίησε `sed` για αντικατάσταση.
