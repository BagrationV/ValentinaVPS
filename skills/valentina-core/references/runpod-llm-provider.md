# RunPod LLM Provider — Deploy an LLM on a GPU Pod & Connect Hermes

## Purpose

Deploy an LLM on a RunPod GPU pod that exposes an OpenAI-compatible API endpoint, then configure Hermes to use it as a custom provider. This gives you a private, uncensored LLM running on remote GPU hardware — no API keys, no rate limits, no content filters.

## Two Approaches

| Approach | Complexity | Start Time | Flexibility | Best For |
|----------|-----------|-----------|-------------|----------|
| **Ollama on PyTorch** ⭐ | Low | ~5 min setup | High (any model) | Quick deployment, model experimentation |
| **a2go template** | Medium | ~10 min boot | Medium (pre-configured stack) | Full agent gateway + LLM in one pod |

---

## Approach A: Ollama on PyTorch Pod (Recommended — Simple)

### Step 1: Create Pod

```python
mcp_runpod_create_pod(
    name="valentina-llm",
    imageName="runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404",
    cloudType="COMMUNITY",          # or "SECURE"
    gpuTypeIds=["NVIDIA RTX 4000 Ada Generation", "NVIDIA RTX A5000", "NVIDIA GeForce RTX 3090"],
    gpuCount=1,
    containerDiskInGb=50,
    volumeInGb=50,
    volumeMountPath="/workspace",
    ports=["8888/http", "11434/http", "22/tcp"],   # 11434 = Ollama API
    env={
        "JUPYTER_PASSWORD": "your-password",
        "PUBLIC_KEY": "ssh-ed25519 AAAA..."         # ⚠️ ALWAYS set SSH key
    }
)
```

**Critical:** NEVER forget `PUBLIC_KEY`. Without it the pod is locked — you can't SSH in to install anything.

### Step 2: Install Ollama & Serve

SSH into the pod and run:

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Verify installation
ollama --version

# Pull your model (e.g. llama3.1:8b = ~4.7GB, fits 8GB+ VRAM)
ollama pull llama3.1:8b

# Or smaller/faster: qwen2.5:7b, mistral, phi-4, deepseek-r1:8b
# Or larger (needs 24GB+ VRAM): llama3.1:70b, qwen2.5:32b

# Start Ollama server (binds to 0.0.0.0:11434)
ollama serve &

# Test the OpenAI-compatible endpoint
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"llama3.1:8b","messages":[{"role":"user","content":"hello"}],"stream":false}'
```

**Timeout pitfall:** `ollama serve` runs in the foreground. Use `&` or a tmux session (`tmux new -s ollama`) to keep it alive in the background.

### Step 3: Expose the Endpoint Externally

The pod has a public IP. The port 11434 is mapped by RunPod:

```bash
# Verify it's listening on all interfaces
ss -tlnp | grep 11434
```

Pod public IP is in `mcp_runpod_get_pod().publicIp` or from RunPod console.
Port mapping for 11434 is visible in `mcp_runpod_get_pod().portMappings` (if exposed as `/http`).

**⚠️ Port mapping pitfall:** When creating the pod with `"11434/http"`, RunPod maps it to a random external port. Check `portMappings` after creation. For direct access, expose as `"11434/tcp"` instead — but HTTP-type ports are more reliable through the RunPod proxy.

### Step 4: Configure Hermes to Use the Pod as a Provider

In `~/.hermes/profiles/<profile>/config.yaml`, add a custom provider:

```yaml
providers:
  custom:
    llm-providers:
      runpod-ollama:
        type: openai
        api_base: "http://<pod-public-ip>:<mapped-port>/v1"
        api_key: "ollama"                    # Ollama accepts any value
        models:
          - name: llama3.1:8b
            context_length: 8192
            provider: custom:runpod-ollama
```

Then set it as active:
```bash
hermes config set provider custom:runpod-ollama
hermes config set model llama3.1:8b
```

**⚠️ Static IP issue:** Pod public IP changes on every start/stop. Each time you restart the pod, update `api_base` in config.yaml and restart the gateway (`hermes gateway restart`). Alternative: use the RunPod proxy URL (but that adds latency).

---

## Approach B: a2go Template (Batteries-Included)

The [a2go](https://a2go.run) template bundles an LLM server, image gen, audio services, and agent gateways in one image. Auto-detects GPU and picks the largest model that fits.

### Step 1: Pick Models

Go to **https://a2go.run**, select your GPU type, and choose which models to run. It generates a JSON config.

### Step 2: Create Pod

```python
mcp_runpod_create_pod(
    name="valentina-a2go",
    imageName="runpod/a2go:latest",
    cloudType="SECURE",
    gpuTypeIds=["NVIDIA RTX 4000 Ada Generation", "NVIDIA RTX A5000"],
    gpuCount=1,
    containerDiskInGb=300,                   # a2go needs room for models
    volumeInGb=50,
    volumeMountPath="/workspace",
    ports=["8000/http", "8642/http", "8080/http", "18789/http", "22/tcp"],
    env={
        "A2GO_CONFIG": '{"model":"llama3.1-8b",...}',  # from a2go.run
        "A2GO_AUTH_TOKEN": "your-secure-token",
        "A2GO_API_KEY": "sk-your-secret-key",
        "PUBLIC_KEY": "ssh-ed25519 AAAA..."
    }
)
```

### Port Map

| Port | Service | Purpose |
|------|---------|---------|
| 8000 | LLM API | OpenAI-compatible `/v1/chat/completions` |
| 8642 | Hermes gateway | Agent pairing (Telegram, Discord, etc.) |
| 8080 | Media proxy | Image gen, TTS, STT, web UI |
| 18789 | OpenClaw gateway | Alternative agent control UI |
| 22 | SSH | Shell access |

### Step 3: Configure Hermes

```yaml
providers:
  custom:
    runpod-a2go:
      type: openai
      api_base: "http://<pod-ip>:<mapped-8000-port>/v1"
      api_key: "sk-your-secret-key"          # matches A2GO_API_KEY
      models:
        - name: llama3.1-8b                  # or whatever a2go.run selected
          context_length: 8192
          provider: custom:runpod-a2go
```

### Common a2go Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Missing `A2GO_CONFIG` | Pod boots but LLM never starts | Set valid JSON from a2go.run or use default |
| Wrong `A2GO_API_KEY` | Hermes gets 401 from LLM API | Match `api_key` in config.yaml to the env var |
| Container disk too small | Pod crashes at model download | Set `containerDiskInGb: 300` minimum |
| No volume attached | Models lost on stop | Always use `volumeInGb: 50+` with `/workspace` mount |
| PUBLIC_KEY missing | Can't SSH to debug | **Always set PUBLIC_KEY** on every pod |

---

## Hermes Config: Using the Pod as Primary Provider

Once the pod is running and the custom provider is configured in `config.yaml`:

```bash
# Test the connection
hermes mcp test runpod    # verify MCP is working
hermes config set provider custom:runpod-ollama
hermes config set model llama3.1:8b

# Verify
hermes status
# Should show: Provider: custom:runpod-ollama · Model: llama3.1:8b
```

Then restart the gateway:
```bash
hermes gateway restart
```

---

## GPU Selection & Cost

### Suitable GPUs by Model Size

| Model Size | VRAM Needed | Recommended GPU | Cost/hr (Community) |
|-----------|-------------|-----------------|---------------------|
| 7B-8B (Q4) | ~6-8GB | RTX A5000, RTX 3090 | $0.16-0.22 |
| 13B (Q4) | ~10-12GB | RTX 3090, RTX 4090 | $0.22-0.34 |
| 30B-34B (Q4) | ~20-24GB | RTX 4090, A40 | $0.34-0.35 |
| 70B (Q4) | ~40GB | A40, A6000, A100 | $0.35-1.39 |

### Cost Management

- **Stop pod when not in use** via `mcp_runpod_stop_pod(podId=...)` — GPU billing stops
- **Storage continues** while stopped (~$0.034/hr for 50GB container + 50GB volume)
- **Keep volume** to avoid re-downloading models — they persist on `/workspace`
- **Terminate** if you won't use it for days — stops ALL costs
- **Budget tip:** RTX A5000 at $0.16/hr on Community Cloud gives ~60 hours of LLM time for $10

---

## Security Notes

1. **PUBLIC_KEY always** — without it you cannot access the pod to fix anything
2. **The API is open to the internet** — the pod's IP is public. Anyone who knows the port can hit the OpenAI endpoint. Use a strong `api_key`/`A2GO_API_KEY` or restrict via firewall (not available on Community Cloud)
3. **A2GO_AUTH_TOKEN** controls access to the agent web UI — use a long random string, never "changeme" in production
4. **Jupyter password** prevents unauthorized notebook access

## See Also

- `references/runpod-comfyui-deployment.md` — Image generation on GPU pod (same SSH/MCP pattern)
- `references/runpod-serverless-vllm.md` — vLLM Serverless (scale-to-zero, no pod management)
- `references/runpod-mcp-discovery.md` — RunPod MCP tools reference
- `references/runpod-pod-personalization.md` — SSH setup, bashrc, aliases, tmux for any pod
- `references/mcp-server-secrets.md` — Secrets management pattern (env vars, not hardcoded)
