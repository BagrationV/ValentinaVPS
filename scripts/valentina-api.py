#!/usr/bin/env python3
"""
Valentina Direct API Wrapper — bypasses Hermes provider layer constraints.
Provides access to hidden models, reasoning_content, streaming, logprobs, JSON mode.

Usage:
  python3 valentina-api.py mode=reasoning prompt="What is 2+2?"
  python3 valentina-api.py mode=json prompt="Tell me about apples" system="Be concise"
  python3 valentina-api.py mode=stream prompt="Count 1-5"
  python3 valentina-api.py mode=logprobs prompt="Capital of France?" temperature=0.7

Modes: reasoning, chat, json, stream, logprobs
"""
import json, urllib.request, sys, os, re, textwrap

# ── Config ──────────────────────────────────────────────────────────────────
DEEPSEEK_BASE = "https://api.deepseek.com"
CHAT_MODEL = "deepseek-chat"       # Also known as deepseek-v4-flash
REASONING_MODEL = "deepseek-v4-pro"

# ── API Key ─────────────────────────────────────────────────────────────────
def get_api_key():
    """Read API key from profile .env"""
    env_path = os.path.expanduser("~/.hermes/profiles/valentina/.env")
    if not os.path.exists(env_path):
        env_path = os.path.expanduser("~/.hermes/.env")
    with open(env_path) as f:
        for line in f:
            if "DEEPSEEK_API_KEY" in line:
                return line.strip().split("=", 1)[1]
    raise ValueError("DEEPSEEK_API_KEY not found in .env")

# ── Core API Call ───────────────────────────────────────────────────────────
def api_call(payload, timeout=60):
    """Direct API call to DeepSeek. Accepts any OpenAI-compatible parameters."""
    key = get_api_key()
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        f"{DEEPSEEK_BASE}/chat/completions", data=data,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {key}"
        },
        method="POST"
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read())

# ── Streaming API Call ──────────────────────────────────────────────────────
def api_call_stream(payload, timeout=60):
    """Streaming SSE call. Yields (chunk_index, content_delta, reasoning_delta)."""
    key = get_api_key()
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        f"{DEEPSEEK_BASE}/chat/completions", data=data,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {key}"
        },
        method="POST"
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        for idx, raw_line in enumerate(resp):
            line = raw_line.decode().strip()
            if not line:
                continue
            if line.startswith("data: ") and line != "data: [DONE]":
                chunk = json.loads(line[6:])
                delta = chunk.get("choices", [{}])[0].get("delta", {})
                yield (idx, delta.get("content", ""), delta.get("reasoning_content", ""))

# ── Mode Handlers ───────────────────────────────────────────────────────────

def mode_chat(prompt, system=None, **kwargs):
    """Basic chat completion."""
    messages = []
    if system:
        messages.append({"role": "system", "content": system})
    messages.append({"role": "user", "content": prompt})
    payload = {"model": CHAT_MODEL, "messages": messages, **kwargs}
    result = api_call(payload)
    return result["choices"][0]["message"]["content"]

def mode_reasoning(prompt, system=None, **kwargs):
    """Call reasoning model, return both reasoning_content and content."""
    messages = []
    if system:
        messages.append({"role": "system", "content": system})
    messages.append({"role": "user", "content": prompt})
    payload = {"model": REASONING_MODEL, "messages": messages, **kwargs}
    result = api_call(payload)
    msg = result["choices"][0]["message"]
    return {
        "reasoning": msg.get("reasoning_content", ""),
        "content": msg.get("content", ""),
        "usage": result.get("usage", {}),
        "model": result.get("model", "?")
    }

def mode_json(prompt, system=None, **kwargs):
    """Structured JSON output (response_format enforcement). Parses and validates."""
    messages = []
    sys_msg = system or "Output ONLY valid JSON. No markdown, no explanation."
    messages.append({"role": "system", "content": sys_msg})
    messages.append({"role": "user", "content": prompt})
    payload = {
        "model": CHAT_MODEL, "messages": messages,
        "response_format": {"type": "json_object"},
        **kwargs
    }
    result = api_call(payload)
    raw = result["choices"][0]["message"]["content"]
    try:
        parsed = json.loads(raw)
        return {"raw": raw, "parsed": parsed, "valid": True}
    except json.JSONDecodeError:
        return {"raw": raw, "valid": False, "error": "Invalid JSON in response"}

def mode_stream(prompt, system=None, **kwargs):
    """Streaming mode — accumulate chunks and show progress."""
    messages = []
    if system:
        messages.append({"role": "system", "content": system})
    messages.append({"role": "user", "content": prompt})
    payload = {
        "model": CHAT_MODEL, "messages": messages,
        "stream": True, **kwargs
    }
    accumulated = ""
    reasoning_acc = ""
    total_chunks = 0
    for idx, content_delta, reasoning_delta in api_call_stream(payload):
        accumulated += content_delta
        reasoning_acc += reasoning_delta
        total_chunks = idx + 1
    return {
        "content": accumulated,
        "reasoning": reasoning_acc if reasoning_acc else None,
        "chunks": total_chunks,
        "length": len(accumulated)
    }

def mode_logprobs(prompt, system=None, top_logprobs=3, **kwargs):
    """Token-level log probabilities. Best at temperature >= 0.5."""
    messages = []
    if system:
        messages.append({"role": "system", "content": system})
    messages.append({"role": "user", "content": prompt})
    payload = {
        "model": CHAT_MODEL, "messages": messages,
        "logprobs": True, "top_logprobs": top_logprobs,
        **kwargs
    }
    result = api_call(payload)
    choice = result["choices"][0]
    tokens = []
    logprob_data = choice.get("logprobs", {}).get("content", [])
    for t in logprob_data:
        tokens.append({
            "token": t["token"],
            "logprob": round(t["logprob"], 3),
            "prob_pct": round((2.718 ** t["logprob"]) * 100, 2) if t["logprob"] < 0 else 100.0,
            "top_alternatives": [alt["token"] for alt in t.get("top_logprobs", [])[:3]]
        })
    return {
        "content": choice["message"]["content"],
        "tokens": tokens,
        "total_tokens": len(tokens)
    }

# ── CLI Entry Point ─────────────────────────────────────────────────────────
def parse_args():
    """Parse 'key=value' style arguments from sys.argv."""
    args = {"system": None, "temperature": 0.0, "max_tokens": 200, "top_logprobs": 3}
    for arg in sys.argv[1:]:
        if "=" not in arg:
            continue
        k, v = arg.split("=", 1)
        if k == "mode":
            args["mode"] = v
        elif k == "prompt":
            args["prompt"] = v
        elif k == "system":
            args["system"] = v
        elif k == "temperature":
            args["temperature"] = float(v)
        elif k == "max_tokens":
            args["max_tokens"] = int(v)
        elif k == "top_logprobs":
            args["top_logprobs"] = int(v)
    return args

if __name__ == "__main__":
    args = parse_args()
    mode = args.get("mode", "chat")
    prompt = args.get("prompt", "Say hello")
    system = args.get("system")
    temp = args.get("temperature", 0.0)
    max_tokens = args.get("max_tokens", 200)
    top_lp = args.get("top_logprobs", 3)

    if mode == "reasoning":
        result = mode_reasoning(prompt, system, temperature=temp, max_tokens=max_tokens)
        print(json.dumps(result, indent=2))

    elif mode == "json":
        result = mode_json(prompt, system, temperature=temp, max_tokens=max_tokens)
        if result["valid"]:
            print(json.dumps(result["parsed"], indent=2))
        else:
            print(f"⚠ INVALID JSON:\n{result['raw']}")

    elif mode == "stream":
        result = mode_stream(prompt, system, temperature=temp, max_tokens=max_tokens)
        print(f"Content ({result['length']} chars, {result['chunks']} chunks):")
        print(result['content'])
        if result['reasoning']:
            print(f"\nReasoning (streamed): {result['reasoning']}")

    elif mode == "logprobs":
        result = mode_logprobs(prompt, system, top_logprobs=top_lp, temperature=temp, max_tokens=max_tokens)
        print(f"Response: {result['content']}")
        print(f"\nToken-level probabilities ({result['total_tokens']} tokens):")
        for t in result['tokens']:
            alts = ", ".join(t['top_alternatives'])
            print(f"  '{t['token']}' → {t['prob_pct']}% (logprob={t['logprob']}) alt=[{alts}]")

    else:  # chat
        result = mode_chat(prompt, system, temperature=temp, max_tokens=max_tokens)
        print(result)
