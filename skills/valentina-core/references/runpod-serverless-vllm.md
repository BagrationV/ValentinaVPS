# RunPod Serverless vLLM — LLM Inference Endpoint

## Purpose

Deploy an OpenAI-compatible LLM endpoint on RunPod Serverless with vLLM in under 5 minutes. Auto-scaling, pay-per-second, scale-to-zero when idle.

## How Serverless Billing Works

- **Pay-per-second**: Billed from worker start to full stop, rounded up to nearest second
- **Flex workers (default)**: Scale to zero when idle → **$0** when no requests
- **Active workers**: Always running (24/7), discounts via sales inquiry
- **What you're billed for**: Compute time (GPU), container disk (~$0.10/GB/mo), network volume ($0.07/GB/mo)

### Three billing phases per request:
1. **Start time**: Initializing container + loading model into GPU memory (minimize with FlashBoot or model caching)
2. **Execution time**: Processing the actual requests (set timeouts)
3. **Idle timeout**: Default 5 seconds after last request (configurable in endpoint settings)

## Serverless GPU Pricing

| GPU Type(s) | VRAM | Cost/sec | Cost/hr | Best for |
|-------------|------|----------|---------|----------|
| **A4000/A4500/RTX 4000** | 16 GB | **$0.00016** | **$0.58** | Small models (3B-7B 4-bit) |
| **L4/A5000/3090** ⭐ | 24 GB | **$0.00019** | **$0.68** | 7B-14B 4-bit models |
| 4090 PRO | 24 GB | $0.00031 | $1.12 | 7B full precision, fast |
| A6000/A40 | 48 GB | $0.00034 | $1.22 | 14B-32B 4-bit models |
| L40/L40S/6000 Ada PRO | 48 GB | $0.00053 | $1.91 | Llama 3 7B full precision |
| A100 | 80 GB | $0.00076 | $2.74 | 70B 4-bit |
| H100 PRO | 80 GB | $0.00116 | $4.18 | 70B+ full precision |

## Model Recommendations for Tool Calling + Reasoning

### Best for $10 Budget (24GB tier @ $0.00019/sec)

| Model | Params | VRAM (4-bit) | Why |
|-------|--------|-------------|-----|
| **Qwen 2.5 14B** ⭐ | 14B | ~8GB | #1 open-source BFCL tool calling, strong reasoning |
| **Qwen 3 14B** | 14B | ~8GB | Latest version, even better benchmarks |
| DeepSeek R1 Distill 14B | 14B | ~8GB | Good reasoning, decent tool calling |

### Higher Capability (48GB tier @ $0.00034/sec)

| Model | Params | VRAM (4-bit) | Why |
|-------|--------|-------------|-----|
| **Qwen 2.5 32B** | 32B | ~16GB | Top-tier reasoning, excellent tool calling |
| **Mistral Small 3.1 24B** | 24B | ~12GB | Very strong reasoning |
| DeepSeek R1 Distill 32B | 32B | ~16GB | Good chain-of-thought |

### Budget Analysis: Qwen 2.5 14B @ $0.00019/sec

```
$10 budget  =  52,632 seconds of processing
Per request: ~3-5 sec  →  ~10,000-17,000 requests
Idle (0 requests)      →  $0.00
```

## Step-by-Step: Deploy vLLM Serverless Endpoint

### Prerequisites

- RunPod account with API key
- Model from HuggingFace (public or with token)
- vLLM supports most popular models natively

### Method: Quick Deploy (from RunPod Console)

1. Go to **Serverless** → **Endpoints** → **Quick Deploy**
2. Select **vLLM** as the framework
3. Enter HuggingFace model ID (e.g. `Qwen/Qwen2.5-14B-Instruct` or `Qwen/Qwen2.5-7B-Instruct`)
4. Select GPU type (see pricing table above)
5. Set min/max workers (start with min=0, max=1 for testing)
6. Deploy — ready in ~5 minutes

### Method: Create via MCP Tools (Hermes)

```python
# Create a serverless endpoint
mcp_runpod_create_endpoint(
    name="qwen-14b-serverless",
    templateId="...",  # Get from mcp_runpod_list_templates
    computeType="GPU",
    gpuTypeIds=["NVIDIA L4", "NVIDIA RTX A5000"],
    gpuCount=1,
    workersMin=0,
    workersMax=3,
    dataCenterIds=["EU-NL-1", "EU-CZ-1"]
)
```

**Note:** The vLLM Quick Deploy feature is currently only available through the RunPod Console UI (https://www.runpod.io/console/serverless). The MCP create_endpoint tool requires a custom template — see the vLLM docs for the template setup.

### Recommended vLLM Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `MODEL` | `Qwen/Qwen2.5-14B-Instruct` | HuggingFace model ID |
| `MAX_MODEL_LEN` | `16384` | Context window (in tokens) |
| `GPU_MEMORY_UTILIZATION` | `0.90` | VRAM usage (0.0-1.0) |
| `DTYPE` | `auto` | Precision (auto, half, float16, bfloat16) |
| `QUANTIZATION` | `awq` or `gptq` or omit | Use for quantized models |

## API Usage

Once deployed, the endpoint is OpenAI-compatible:

```bash
# Example: curl request
curl -X POST https://api.runpod.ai/v2/{endpoint_id}/runsync \
  -H "Authorization: Bearer $RUNPOD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "model": "Qwen/Qwen2.5-14B-Instruct",
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "What is the weather today?"}
      ],
      "temperature": 0.7,
      "max_tokens": 1024,
      "tools": [
        {
          "type": "function",
          "function": {
            "name": "get_weather",
            "description": "Get the weather for a location",
            "parameters": {
              "type": "object",
              "properties": {
                "location": {"type": "string"}
              },
              "required": ["location"]
            }
          }
        }
      ]
    }
  }'

# Stream response
curl -X POST https://api.runpod.ai/v2/{endpoint_id}/runsync \
  -H "Authorization: Bearer $RUNPOD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "messages": [...],
      "stream": true
    }
  }'
```

## Cost Optimization Tips

1. **Set min_workers=0** — endpoint scales to zero when idle ($0 cost)
2. **Keep idle timeout low** — default 5s is fine; increase only for burst traffic
3. **Use quantized models** (AWQ/GPTQ) for cheaper GPU tiers — 4-bit quantization fits larger models in smaller VRAM
4. **FlashBoot** — enables faster cold starts (model caching)
5. **Monitor endpoint** — check `mcp_runpod_endpoint_health()` for worker count and queue depth

## Storage Costs (when endpoint is active)

- Container disk: ~$0.10/GB/month (per worker, billed in 5-min intervals)
- Network volume: $0.07/GB/month (< 1TB), $0.05/GB/month (> 1TB) — only if used

## Comparison: Serverless vs Pod for LLMs

| | Serverless vLLM | GPU Pod (manual) |
|---|---|---|
| Pricing | Per-second, scale-to-zero | Per-hour flat rate |
| Cold start | ~5-10s (FlashBoot) | ~3-5 min |
| API | OpenAI-compatible | You set up yourself |
| Auto-scale | Built-in | Manual |
| Best for | Intermittent inference | Dev, fine-tuning, continuous load |
| $10 budget | ~10,000-17,000 requests | ~25-45 hours continuous |
