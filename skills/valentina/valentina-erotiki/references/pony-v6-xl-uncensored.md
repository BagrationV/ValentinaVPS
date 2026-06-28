# Pony V6 XL — Uncensored Image Generation Guide

## Model Info
- **Name:** Pony Diffusion V6 XL
- **Size:** 6.46 GB (SDXL-based checkpoint)
- **Source:** https://civitai.com/models/257749/pony-diffusion-v6-xl
- **Download:** `https://civitai.com/api/download/models/290640` (version "V6 start with this one")
- **CivitAI model ID:** 257749, version ID: 290640

## Critical Download Note
**Use `curl -L`, NOT `wget`.** CivitAI download URLs redirect. `wget` may get partial files (~1.6GB instead of 6.5GB). Correct command:
```bash
curl -L -o ponyDiffusionV6XL_v6.safetensors "https://civitai.com/api/download/models/290640"
```

## Required Tags
Pony V6 uses specific rating, source, and quality tags. Without these, the model produces low quality or SFW-only output:

```
score_9, score_8_up, score_7_up, source_anime, rating_explicit
```

### Quality Tags (order matters — put first)
| Tag | Meaning |
|-----|---------|
| `score_9` | Highest quality |
| `score_8_up` | Accept 8+ only |
| `score_7_up` | Accept 7+ only |

### Rating Tags
| Tag | Effect |
|-----|--------|
| `rating_safe` | SFW only |
| `rating_questionable` | Partial/implied nudity |
| `rating_explicit` | **Full NSFW — use for uncensored** |

### Source Tags
| Tag | Effect |
|-----|--------|
| `source_anime` | General/anime style (works for realistic too) |

## ComfyUI REST API Workflow

Pony V6 uses the **same workflow structure as SDXL** (SDXL-based). No special Flux nodes needed.

### Minimal txt2img JSON (API format):
```json
{
  "3": {
    "class_type": "KSampler",
    "inputs": {
      "seed": 696969,
      "steps": 35,
      "cfg": 7,
      "sampler_name": "dpmpp_2m",
      "scheduler": "karras",
      "denoise": 1,
      "model": ["4", 0],
      "positive": ["6", 0],
      "negative": ["7", 0],
      "latent_image": ["5", 0]
    }
  },
  "4": {
    "class_type": "CheckpointLoaderSimple",
    "inputs": { "ckpt_name": "ponyDiffusionV6XL_v6.safetensors" }
  },
  "5": {
    "class_type": "EmptyLatentImage",
    "inputs": { "width": 1216, "height": 832, "batch_size": 1 }
  },
  "6": {
    "class_type": "CLIPTextEncode",
    "inputs": {
      "text": "score_9, score_8_up, rating_explicit, VALENTINA, your prompt here",
      "clip": ["4", 1]
    }
  },
  "7": {
    "class_type": "CLIPTextEncode",
    "inputs": {
      "text": "rating_safe, censored, blurred, bad anatomy, worst quality",
      "clip": ["4", 1]
    }
  },
  "8": {
    "class_type": "VAEDecode",
    "inputs": { "samples": ["3", 0], "vae": ["4", 2] }
  },
  "9": {
    "class_type": "SaveImage",
    "inputs": { "filename_prefix": "output", "images": ["8", 0] }
  }
}
```

### Resolution Guide
- SDXL native: 1024x1024 (square)
- Portrait: 832x1216
- Landscape: 1216x832
- All must be multiples of 8

### Recommended Samplers
| Sampler | Steps | Quality |
|---------|-------|---------|
| dpmpp_2m + karras | 30-40 | Best detail |
| euler + normal | 20-30 | Fast |
| dpmpp_sde + karras | 25-35 | Good for organic forms |

## Common Pitfalls
1. **Missing Pony tags** = low quality or SFW output. Always lead with `score_9, score_8_up, source_anime, rating_explicit`.
2. **wget fails** on CivitAI downloads — use `curl -L` instead.
3. **Negative prompt needs opposite tags** — put `rating_safe` in negative to push toward explicit. Also put `censored, blurred, mosaic, censor` in negative.
4. **Pony understands natural language** for anatomy — "hairy pussy", "erect nipples", "spread legs" all work directly.
5. **Steps above 40** give diminishing returns on Pony V6. 35 is the sweet spot.

## Example NSFW Prompts

### Hairy / Natural Body
```
score_9, score_8_up, score_7_up, source_anime, rating_explicit, VALENTINA, lying on bed completely naked, legs spread wide open, hairy pussy, natural bush, dark pubic hair, wet pussy glistening, labia visible, full nude female body, perky breasts with hard erect nipples, long dark messy hair, piercing bright blue eyes
```

### Erotic Portrait
```
score_9, score_8_up, source_anime, rating_explicit, VALENTINA, intense passionate gaze, completely naked, beautiful woman, long dark messy hair, piercing blue eyes, wet skin, raw sexuality, intimate close-up, cinematic lighting
```

## Verifying Before Delivery
- On CLI: just provide the file path. Do NOT analyze with vision_analyze.
- On Telegram: send directly, no intermediate evaluation (κύριε Elkratos' rule).
- Blue eyes are critical — if generating, prompt strongly: `(piercing bright blue eyes:1.4)`
