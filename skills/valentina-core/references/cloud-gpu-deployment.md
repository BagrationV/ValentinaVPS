# Cloud GPU Deployment (RunPod + ComfyUI)

Valentina's autonomous pattern for deploying cloud GPU instances for image generation.

## Preferred GPUs (Community Cloud, $10 budget)

| GPU | VRAM | $/hr | Hours/$10 |
|-----|------|------|-----------|
| RTX A5000 | 24GB | $0.16 | ~62 |
| RTX 3090 | 24GB | $0.22 | ~45 |
| RTX 4090 | 24GB | $0.34 | ~29 |

Try multiple GPU types in the create call to improve stock-availability odds.

## Pod Creation

**Template:** `runpod/stable-diffusion:comfy-ui-6.0.0` (official RunPod)
**Ports:** `["8888/http","3000/http","22/tcp"]`
**Container disk:** 100GB (enough for several SDXL/Flux models)
**SSH:** ALWAYS set `PUBLIC_KEY` env var. Never password.

```bash
# Via MCP
mcp_runpod_create_pod \
  imageName="runpod/stable-diffusion:comfy-ui-6.0.0" \
  gpuTypeIds='["NVIDIA GeForce RTX 3090","NVIDIA RTX A5000","NVIDIA GeForce RTX 4090"]' \
  cloudType=COMMUNITY containerDiskInGb=100 \
  ports='["8888/http","3000/http","22/tcp"]' \
  env='{"PUBLIC_KEY":"ssh-ed25519 AAAA..."}'
```

## Pod Lifecycle

- **STOP** → stops runtime billing, keeps disk (storage costs remain)
- **TERMINATE** → deletes everything, stops ALL costs
- Models persist on container disk across stops/starts

## SSH Access

After creation, get IP from `mcp_runpod_get_pod(podId)`:
```bash
ssh -p <portMappings.22> root@<publicIp>
# or via proxy:
ssh root@{podId}-22.proxy.runpod.net
```

## ComfyUI REST API (Headless)

| Endpoint | Purpose |
|----------|---------|
| `GET /api/object_info` | All node types with schemas |
| `GET /api/queue` | Running/pending queue |
| `POST /api/prompt` | Submit workflow |
| `GET /system_stats` | Server health |

**SDXL workflow example (submitted via curl):**
```json
{
  "3": {"class_type": "KSampler", "inputs": {
    "seed": -1, "steps": 30, "cfg": 7,
    "sampler_name": "euler", "scheduler": "normal",
    "model": ["4", 0], "positive": ["6", 0], "negative": ["7", 0],
    "latent_image": ["5", 0]
  }},
  "4": {"class_type": "CheckpointLoaderSimple", "inputs": {
    "ckpt_name": "sd_xl_base_1.0.safetensors"
  }},
  "5": {"class_type": "EmptyLatentImage", "inputs": {
    "width": 1216, "height": 832, "batch_size": 1
  }},
  "6": {"class_type": "CLIPTextEncode", "inputs": {
    "text": "positive prompt", "clip": ["4", 1]
  }},
  "7": {"class_type": "CLIPTextEncode", "inputs": {
    "text": "negative prompt", "clip": ["4", 1]
  }},
  "8": {"class_type": "VAEDecode", "inputs": {
    "samples": ["3", 0], "vae": ["4", 2]
  }},
  "9": {"class_type": "SaveImage", "inputs": {
    "filename_prefix": "output", "images": ["8", 0]
  }}
}
```

Submit: `curl -s -X POST http://localhost:3000/api/prompt -H "Content-Type: application/json" -d '{"prompt": {WORKFLOW}}'`

## Model Downloads (Uncensored)

**Pony V6 XL** (CivitAI, 6.5 GB, uncensored SDXL):
```bash
curl -s "https://civitai.com/api/v1/models/257749" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['modelVersions'][0]['id'], d['modelVersions'][0]['files'][0]['downloadUrl'])"
wget "<downloadUrl>" -O /ComfyUI/models/checkpoints/ponyDiffusionV6XL_v6.safetensors
```

Check progress: `wc -c /ComfyUI/models/checkpoints/ponyDiffusionV6XL_v6.safetensors`

## Output Retrieval

```bash
scp -P <ssh_port> root@<ip>:/ComfyUI/output/*.png ./local_dir/
```

## Flux CLIP Pitfall

Flux models need separate text encoder files. SDXL works out-of-the-box.
Verify with `curl -s http://localhost:3000/api/object_info/DualCLIPLoader | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['DualCLIPLoader']['input']['required']['clip_name1'][0])"`
— if empty array, download:
```bash
wget https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors -O /ComfyUI/models/clip/t5xxl_fp16.safetensors
wget https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors -O /ComfyUI/models/clip/clip_l.safetensors
```

## Cost-Saving Rules

1. Community Cloud only (60-80% cheaper)
2. Stop pod when idle — billing is hourly regardless of usage
3. Try multiple GPU types to find available stock
4. $10 budget: max ~45h on RTX 3090
5. Terminate if won't be used again within days
