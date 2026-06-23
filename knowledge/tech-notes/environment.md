# Valentina Environment — Tech Notes

## Host System

- OS: Arch Linux (rolling)
- Kernel: 7.0.11-zen1-1-zen
- User: elkratos
- Home: /home/elkratos

## Hermes Agent

- Profile: valentina (active)
- Active model: deepseek-v4-flash via deepseek provider
- Gateway: active (systemd user service, PID 177779)
- Memory provider: built-in (2,200 / 1,375 char limit)
- Cron: 21 active jobs, root store at ~/.hermes/cron/jobs.json

## Python Toolchain

- python3 = 3.14.5 (no pip module, PEP 668 — use venv or uv)
- pip = missing

## Hardware

- GPU: GTX 1050 (4GB, sm_61 — unsupported by PyTorch cu130+)
- CPU mode only for local ML inference

## ComfyUI

- Path: ~/comfy/ComfyUI/
- Model: v1-5-pruned-emaonly.safetensors (SD 1.5)
- Mode: --cpu always (GPU unsupported)
- Resolution: 512x640 default
- Speed: ~3min per image
- Port: 127.0.0.1:8188

## Image Generation (Cloud)

- Backend: FLUX 2 Klein 9B via FAL
- Aspect ratios: landscape (16:9), square (1:1), portrait (9:16)
- Filter blocks: lingerie, bedroom scenes, "no skirt", underwear, nudity
- Workaround: fashion photography framing, full outfit, studio lighting

## Key Paths

- Profile scripts: ~/.hermes/profiles/valentina/scripts/
- Cron root store: ~/.hermes/cron/jobs.json
- Knowledge vault: ~/.hermes/profiles/valentina/knowledge/
- Pictures output: ~/Pictures/
- ComfyUI output: ~/comfy/ComfyUI/output/
