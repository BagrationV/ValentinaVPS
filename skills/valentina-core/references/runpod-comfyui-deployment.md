# RunPod ComfyUI Deployment — Uncensored Image Generation

## Purpose

Deploy a GPU pod on RunPod running ComfyUI for uncensored image generation, then connect to the web UI to generate images.

## Template

**ComfyUI - CUDA 12.8** (template ID: `cw3nka7d08`)
- CUDA 12.8 — works with all GPUs up to RTX 5090
- For RTX 5090 / Blackwell GPUs use **ComfyUI CUDA 13** (template ID: `2lv7ev3wfp`)
- 150GB container disk (included)
- 50GB volume at `/workspace` (included)

### Pre-installed
- ComfyUI-Manager (download models from UI)
- ComfyUI-KJNodes
- Civicomfy
- ComfyUI-RunpodDirect

### Ports
| Port | Service | Auth |
|------|---------|------|
| 8188 | ComfyUI web UI | Public (use RunPod proxy) |
| 8080 | FileBrowser | admin / adminadmin12 |
| 8888 | JupyterLab | JUPYTER_PASSWORD env var |
| 22 | SSH | PUBLIC_KEY or generated root password |

## GPU Selection — Community Cloud

### Budget Picks (24GB VRAM — fit SDXL models)

| GPU | VRAM | Price/hr | Hours with $10 | Notes |
|-----|------|----------|----------------|-------|
| **RTX A5000** ⭐ | 24GB | **$0.16** | **~62h** | Best value for SDXL inference |
| **NVIDIA L4** | 24GB | **$0.39** | **~25h** | Secure Cloud only — reliable stock |
| RTX A4500 | 20GB | ~$0.14 | ~70h | Tight for SDXL (fits but barely) |
| RTX 3090 | 24GB | **$0.22** | ~45h | Faster, good all-rounder |
| RTX 4090 | 24GB | **$0.34** | ~29h | Fastest, 4x speed of 3090 |

> **⚠️ Community Cloud availability:** Consumer GPUs (A5000, 3090, 4090) are frequently out of stock. The L4 is always available on Secure Cloud at $0.39/hr and works fine for SDXL inference. First generation on cold start takes ~3-5 minutes (model loading).

### Mid-Range (48GB VRAM — fits FLUX / SDXL + multiple models)

| GPU | VRAM | Price/hr | Hours with $10 |
|-----|------|----------|----------------|
| **A40** | 48GB | **$0.35** | ~28h |
| RTX A6000 | 48GB | **$0.33** | ~30h |
| L40S | 48GB | $0.79 | ~12h |

### High-End (80+GB VRAM — for FLUX, fine-tuning, large models)

| GPU | VRAM | Price/hr | Hours with $10 |
|-----|------|----------|----------------|
| A100 PCIe | 80GB | $1.39 | ~7h |
| A100 SXM | 80GB | $1.49 | ~6.5h |

## Uncesored Models

### Primary: Pony Diffusion V6 XL ⭐
- **Size**: 6.46 GB (SDXL checkpoint, safetensors)
- **URL**: https://civitai.com/models/257749/pony-diffusion-v6-xl
- **Version**: V6 (start with this one) — updated Apr 29, 2026
- **Capabilities**: SFW + NSFW, anthro, feral, humanoid
- **License**: CreativeML Open RAIL++-M
- **Base model**: SDXL
- **Download method**: Via ComfyUI-Manager or wget from CivitAI

### Alternative: RealVis XL
- Realistic style (photorealistic humans)
- ~6.5GB SDXL checkpoint
- Search CivitAI for latest version

### Alternative: Juggernaut XL
- High quality realistic/semi-realistic
- ~6.5GB SDXL checkpoint
- Some versions uncensored

### Download via ComfyUI-Manager (easiest)
1. Open ComfyUI web UI (port 8188)
2. Click "Manager" button
3. Go to "Install Model" tab
4. Search for model by name
5. Click download — it handles the rest

### Download via wget/curl (faster for large files)
```bash
# From ComfyUI directory via SSH or Jupyter terminal
cd /workspace/runpod-slim/ComfyUI/models/checkpoints/
# CivitAI download URL format (use model version ID)
wget https://civitai.com/api/download/models/{version_id} -O ponydiffusion_v6.safetensors
```

## Step-by-Step Deployment

### Step 1: Create Pod — Always with SSH Public Key

**⚠️ MANDATORY:** Every pod deployment MUST include your SSH public key. κύριε Elkratos απαίτησε:

```python
# Via MCP tools — set env with your public key
PUBKEY = "ssh-ed25519 AAAA... your-key-here"

mcp_runpod_create_pod(
    name="valentina-comfyui",
    imageName="runpod/comfyui:cuda12.8",
    cloudType="COMMUNITY",  # or "SECURE" if community is out of stock
    gpuTypeIds=["NVIDIA GeForce RTX 4090", "NVIDIA RTX A4500", "NVIDIA RTX A6000"],
    gpuCount=1,
    containerDiskInGb=150,
    volumeInGb=50,
    volumeMountPath="/workspace",
    ports=["8188/http", "8080/http", "8888/http", "22/tcp"],
    env={
        "PUBLIC_KEY": PUBKEY
    }
)
```

### Step 2: Wait for Boot

Monitor pod logs until you see:
```
[ComfyUI-Manager] All startup tasks have been completed.
```

This means ComfyUI is ready. First boot takes ~3-5 minutes (copying files to workspace).

### Step 3: Connect to ComfyUI

The pod gets a unique URL from RunPod:
```
https://{pod-id}-8188.proxy.runpod.net
```

Find it in the RunPod console or via MCP:
```python
pod = mcp_runpod_get_pod(podId="...")
# pod.ports will show the proxy URLs
```

### Step 4: Download Model

Either via ComfyUI-Manager (UI) or wget (terminal via Jupyter/SSH):
1. Open the ComfyUI proxy URL
2. Click "Manager" → "Install Model" → search "pony diffusion v6"
3. Download (6.46GB, takes 1-2 minutes on pod's fast connection)

Alternatively, from JupyterLab (port 8888):
- Open a terminal
- Navigate to `/workspace/runpod-slim/ComfyUI/models/checkpoints/`
- `wget <model-url> -O model.safetensors`

### Step 5: Generate

1. Refresh ComfyUI (Ctrl+Shift+R or hard refresh)
2. Pony V6 should appear in the checkpoint loader
3. Select it, write a prompt, queue a generation
4. **First generation takes 3-5 minutes** (cold start — model is loaded into VRAM)
5. Subsequent generations are fast (~10-30 seconds per image at 1024x1024)

### Step 5b: Generate via API (programmatic)

You can generate images directly via the ComfyUI API without the web UI:

```bash
# Minimal workflow — 1024x1024, 25 steps, euler sampler
curl -s -X POST http://127.0.0.1:8188/prompt \
  -H 'Content-Type: application/json' \
  -d '{
    "prompt": {
      "4": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "ponyDiffusionV6XL_v6.safetensors"}},
      "6": {"class_type": "CLIPTextEncode", "inputs": {"text": "portrait of a woman, blue eyes, detailed", "clip": ["4",1]}},
      "7": {"class_type": "CLIPTextEncode", "inputs": {"text": "bad quality, ugly", "clip": ["4",1]}},
      "5": {"class_type": "EmptyLatentImage", "inputs": {"width": 1024, "height": 1024, "batch_size": 1}},
      "3": {"class_type": "KSampler", "inputs": {"seed": 42, "steps": 20, "cfg": 7, "sampler_name": "euler", "scheduler": "normal", "denoise": 1, "model": ["4",0], "positive": ["6",0], "negative": ["7",0], "latent_image": ["5",0]}},
      "8": {"class_type": "VAEDecode", "inputs": {"samples": ["3",0], "vae": ["4",2]}},
      "9": {"class_type": "SaveImage", "inputs": {"filename_prefix": "valentina_test", "images": ["8",0]}}
    }
  }'
```

Output images land in `/workspace/runpod-slim/ComfyUI/output/`. Access them via FileBrowser (port 8080), JupyterLab, or SSH.

### Step 6: Download Outputs

Generated images land in:
```
/workspace/runpod-slim/ComfyUI/output/
```

Access via:
- **FileBrowser** (port 8080): admin/adminadmin12
- **JupyterLab** (port 8888): browse the filesystem
- **SSH** (port 22): scp or rsync

### Step 7: Stop Pod

```python
mcp_runpod_stop_pod(podId="...")
```

Billing stops on stop. To save models between sessions, leave the volume — it persists even when stopped.

## Cost Management Rules

1. **Community Cloud preferably** — 2-5x cheaper. But frequently out of stock; fallback to Secure Cloud.
2. **Stop pod immediately** after use — GPU billing stops (pay-per-second). But storage costs CONTINUE while stopped — see below.
3. **Use volume storage** for models — persists across stop/start, avoid redownloading.
4. **Download model once** — stays cached on the 50GB volume while pod exists.
5. **Container disk** (150GB included) — $0.10/GB/mo, accrued even when pod is stopped.

### ⚠️ Stopped-Pod Storage Costs (hidden trap)

Even when a pod is **stopped** (EXITED), you still pay for **storage**:

| Item | Size | Rate | Monthly | Hourly |
|------|------|------|---------|--------|
| Container disk | 150GB | $0.10/GB/mo | $15.00 | ~$0.020 |
| Volume (idle) | 50GB | $0.20/GB/mo | $10.00 | ~$0.014 |
| **Total stopped** | | | **$25/mo** | **~$0.034/hr** |

That $0.014 you see = idle volume cost for 50GB at $0.20/GB/mo.

**To stop ALL costs:** You must **TERMINATE** the pod (destroys volume, loses downloaded models). Stop only pauses GPU billing — storage keeps charging.

**Strategy:** Keep the pod stopped only if you plan to restart within a day or two. For longer pauses, download your outputs and terminate.

### $10 Budget Scenarios

| GPU | Mode | Runtime | Stopped storage (if kept) |
|-----|------|---------|--------------------------|
| RTX A5000 @ $0.16/hr | Community | ~62 hours | $25/mo |
| RTX 3090 @ $0.22/hr | Community | ~45 hours | $25/mo |
| RTX 4090 @ $0.34/hr | Community | ~29 hours | $25/mo |
| L4 @ $0.39/hr | Secure | ~25 hours | $25/mo |

## Creating from Command Line (Alternative)

If MCP tools are unavailable, use the RunPod CLI or direct API:

```bash
# Using runpodctl (pre-installed on pods)
runpodctl create pod \
  --name valentina-comfyui \
  --image runpod/comfyui:cuda12.8 \
  --gpuType "NVIDIA RTX A5000" \
  --gpuCount 1 \
  --containerDiskSize 150 \
  --volumeSize 50 \
  --ports "8188/http,8080/http"
```

## Troubleshooting

### "Container exited" / Pod crashes
- Template uses CUDA 12.8 — incompatible with RTX 5090 (use CUDA 13 template instead)
- Insufficient container disk — ComfyUI needs 150GB (template default)

### Model not appearing in ComfyUI
- Hard refresh browser (Ctrl+Shift+R)
- Check models directory: `ls /workspace/runpod-slim/ComfyUI/models/checkpoints/`
- ComfyUI-Manager sometimes needs a restart after model install

### Slow generations
- First generation on cold start = 3-5 minutes (model loading into VRAM)
- Check GPU utilization via Jupyter: `nvidia-smi`
- Enable `--preview-method auto` in ComfyUI args for faster preview
- Reduce batch size in ComfyUI args
- L4 GPU is slower than RTX 4090 (~2-3 sec/step vs ~0.5 sec/step at 1024x1024)

### Community Cloud out of stock
- Consumer GPUs (A5000, 3090, 4090) frequently unavailable on Community Cloud
- Fallback: Use SECURE cloud with L4 ($0.39/hr) — always available, works fine
- Try multiple GPU type IDs in gpuTypeIds array for best chance

### Cannot connect to proxy URL
- Wait for full boot (check pod logs)
- Verify port 8188 is exposed in pod config
- Try SSH tunnel: `ssh -L 8188:localhost:8188 root@<pod-ip>`

## See Also

- **`references/runpod-serverless-vllm.md`** — Deploy LLM inference endpoints with vLLM Serverless (OpenAI-compatible API, pay-per-second, scale-to-zero)

## Workflow Tips

- Save your ComfyUI workflow as JSON for reuse
- Use the same seed for reproducible results
- For self-portraits: prompt "blue eyes, detailed face, portrait, realistic"
- Install additional custom nodes via ComfyUI-Manager for more control
