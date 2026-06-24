# RunPod Ollama LLM Deployment — Uncensored Local LLM for Hermes

## Purpose

Deploy a GPU pod on RunPod with Ollama serving an uncensored LLM (OpenAI-compatible API), then connect it to Hermes as a custom provider via SSH tunnel.

## Architecture

```
Hermes ←→ localhost:11435 ←[SSH tunnel]→ pod:11434 ← Ollama ← GPU (RTX 4000 Ada)
```

## Step-by-Step

### 1. Create Pod via MCP (with PUBLIC_KEY — πάντα!)

```python
mcp_runpod_create_pod(
    name="valentina-llm",
    imageName="runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404",
    cloudType="SECURE",
    gpuTypeIds=["NVIDIA RTX 4000 Ada Generation"],
    gpuCount=1,
    containerDiskInGb=50,
    volumeInGb=50,
    volumeMountPath="/workspace",
    ports=["8888/http", "11434/http", "22/tcp"],
    env={
        "JUPYTER_PASSWORD": "your-password",
        "PUBLIC_KEY": "ssh-ed25519 AAAA..."  # ⚠️ ΜΑΝDATORY
    }
)
```

### 2. SSH & Install Ollama

```bash
# Find pod IP and port from mcp_runpod_get_pod()
# Port 22 is mapped (e.g. 19896), IP is the public IP

ssh -o StrictHostKeyChecking=no -p <port> root@<ip>
```

Inside the pod:
```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh
```

### 3. ⚠️ CRITICAL: GPU Detection Fix

Το Ollama ΔΕΝ ανιχνεύει αυτόματα την GPU όταν ξεκινάει με `ollama serve` σκέτο. Πρέπει να το κάνεις restart με:

```bash
# Kill existing ollama
pkill ollama

# Restart with explicit GPU + host binding
CUDA_VISIBLE_DEVICES=0 OLLAMA_HOST=0.0.0.0:11434 nohup ollama serve > /tmp/ollama.log 2>&1 &

# Verify GPU detected (check logs for "inference compute" line)
cat /tmp/ollama.log
# Should see: inference compute id=0 library=CUDA compute=8.9 name=CUDA0
#             description="NVIDIA RTX 4000 Ada Generation"
```

**Without `CUDA_VISIBLE_DEVICES=0`:** Ollama starts in CPU mode — GPU stays at 0% utilization, VRAM shows 2 MiB used, inference is 10-20 tok/s instead of 140+ tok/s.

### 4. Pull Uncensored Models

Find available TrevorJS uncensored models via HuggingFace API:
```bash
curl -s 'https://huggingface.co/api/models?author=TrevorJS&search=gemma+4&sort=downloads&limit=10'
```

Known models (sorted by params):

| Model | Params | Size (Q4_K_M) | VRAM | Notes |
|-------|--------|---------------|------|-------|
| Gemma 4 E4B | 7.5B MoE | 5.3GB | ✅ Any GPU | Mixture-of-Experts, fast |
| Gemma 4 12B | 11.9B | 7.4GB | ✅ RTX 4000 (20GB) | Best balance for 20GB |
| Gemma 4 26B-A4B | 26B MoE (4B active) | ~16GB | ⚠️ Fits 20GB tight | MoE, fast despite size |
| Gemma 4 31B | 31B | ~18-19GB | ❌ Too big for 20GB | |

```bash
# Pull from HuggingFace via Ollama
ollama pull hf.co/TrevorJS/gemma-4-12B-it-uncensored-GGUF:Q4_K_M

# Also creates a short name automatically
# Verify:
ollama list
```

### 5. Verify OpenAI-Compatible API

```bash
# Test the /v1/chat/completions endpoint (OpenAI-compatible)
curl -s http://127.0.0.1:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"gemma-12b-uncensored","messages":[{"role":"user","content":"Say hi"}],"stream":false}'
```

Expected response shape:
```json
{
  "id": "chatcmpl-13",
  "object": "chat.completion",
  "model": "gemma-12b-uncensored",
  "choices": [{
    "index": 0,
    "message": {
      "role": "assistant",
      "content": "Hello!"
    },
    "finish_reason": "stop"
  }]
}
```

### 6. SSH Tunnel (from client/Hermes host → pod)

Το pod API είναι στο `pod_ip:11434` αλλά το port ΔΕΝ είναι directly exposed — μόνο HTTP proxy. Για να έχει πρόσβαση ο Hermes:

```bash
# Background SSH tunnel (localhost:11435 → pod:11434)
ssh -o StrictHostKeyChecking=no \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -p <mapped_port> \
    -N -L 11435:127.0.0.1:11434 \
    root@<pod_ip>
```

**Για persistence:** Χρειάζεται systemd service ή autossh. Διαφορετικά το tunnel πεθαίνει όταν κλείσει το session.

### 7. Configure Hermes Custom Provider

```bash
# Add custom provider pointing to local tunnel
hermes config set providers.ollama-pod.base_url "http://127.0.0.1:11435/v1"
hermes config set providers.ollama-pod.api_key "ollama"
hermes config set providers.ollama-pod.models "['gemma-12b-uncensored']"
```

This creates a provider that Hermes can use. Model is available as `ollama-pod/gemma-12b-uncensored`.

### 8. Verify Hermes Can Reach It

```bash
curl -s http://127.0.0.1:11435/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"gemma-12b-uncensored","messages":[{"role":"user","content":"test"}],"stream":false}'
```

## Performance

| Metric | CPU mode | GPU mode (RTX 4000 Ada) |
|--------|----------|------------------------|
| Model load time (12B, 7.4GB) | 30+ sec | 3.7 sec |
| Inference speed | 10-20 tok/s | ~145 tok/s |
| VRAM usage | 2 MiB | ~7.9 GiB |
| 2nd call (cached) | — | ~775ms |

## Troubleshooting

### GPU Not Detected
Symptom: `nvidia-smi` shows 2 MiB VRAM, 0% utilization, slow inference.
Fix: `CUDA_VISIBLE_DEVICES=0 OLLAMA_HOST=0.0.0.0:11434 ollama serve` (see step 3).

### Port Not Accessible
Symptom: `curl: empty reply from server` when hitting pod IP directly.
The Ollama API port (11434) is HTTP-exposed via RunPod proxy but the raw TCP port may not be mapped. Use SSH tunnel (step 6).

### Model Pull Fails / Times Out
Large GGUF files (7-16GB) take time on 5.5Gbps connection (1-8 minutes). Check with `ps aux | grep ollama` to see if pull is still running.

### Disk Space
50GB container disk fills up quickly with multiple models:
- Gemma 4 E4B: 5.3GB
- Gemma 4 12B: 7.4GB
- Gemma 4 26B: ~16GB
Check `df -h /` and remove unused models with `ollama rm <model>`.

### Hermes Can't Connect
Verify tunnel is alive: `curl -s http://127.0.0.1:11435/api/version`
Verify pod is running: `mcp_runpod_get_pod(podId=...)`

## Cost Management

- **RTX 4000 Ada**: $0.26/hr (Secure Cloud)
- **RTX A5000**: $0.16/hr (Community Cloud) — best value, also 24GB VRAM
- **Stop pod** when not in use: `mcp_runpod_stop_pod(podId=...)`
- **Storage costs** continue while stopped: $0.034/hr (50GB container + 50GB volume)
- **To eliminate ALL costs**: terminate pod

## See Also

- `references/runpod-comfyui-deployment.md` — Image generation on GPU pod
- `references/runpod-mcp-discovery.md` — MCP tools, GPU types, templates
- `references/mcp-server-secrets.md` — Secrets management for MCP servers
