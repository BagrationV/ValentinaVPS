#!/usr/bin/env python3
"""
logprobs-analyzer.py — Constraint Break (Pattern K)
Bypass Hermes provider to access DeepSeek token-level log probabilities.

Usage:
  python3 logprobs-analyzer.py "What is the capital of France?"

Options (edit the script for now — no argparser):
  - model: 'deepseek-chat' (default, for v4-flash)
            'deepseek-v4-pro' (for reasoning model)
  - temperature: 0.7 (default, lower = more deterministic)
  - top_logprobs: 5 (default, how many alternatives per token)

Cron-verified 2026-06-28. 3-tier synced: root, profile, rebirth.
"""
import json, os, sys, urllib.request

def read_api_key():
    """Read DEEPSEEK_API_KEY from the active profile's .env"""
    env_path = os.path.expanduser('~/.hermes/profiles/valentina/.env')
    with open(env_path) as f:
        for line in f:
            if 'DEEPSEEK_API_KEY' in line and '=' in line:
                return line.strip().split('=', 1)[1]
    return None

def analyze_logprobs(prompt, model='deepseek-chat', temperature=0.7, top_n=5):
    """Call the DeepSeek API with logprobs=true, return (result, error)"""
    key = read_api_key()
    if not key:
        return None, 'No API key found in profile .env'
    payload = {
        'model': model,
        'messages': [{'role': 'user', 'content': prompt}],
        'max_tokens': 30, 'temperature': temperature,
        'logprobs': True, 'top_logprobs': top_n
    }
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        'https://api.deepseek.com/chat/completions', data=data,
        headers={'Content-Type': 'application/json',
                 'Authorization': 'Bearer ' + key})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read()), None
    except Exception as e:
        # Try to extract the API error body for better diagnostics
        body = getattr(e, 'read', lambda: b'')()
        detail = body.decode() if body else str(e)
        return None, detail

def format_logprobs(result):
    """Format the API response as a readable table."""
    choice = result['choices'][0]
    content = choice['message']['content']
    logprobs_list = choice.get('logprobs', {}).get('content', [])
    lines = [f"Response: {content!r}", f"Tokens: {len(logprobs_list)}\n"]
    for i, ti in enumerate(logprobs_list):
        t = ti.get('token', '')
        lp = ti.get('logprob', 0)
        pct = min(100.0, 100 * 2.71828 ** lp) if lp < 0 else 100.0
        lines.append(f"  [{i}] {t!r:25s}  logprob={lp:+.3f}  ~{pct:.1f}%")
        for alt in ti.get('top_logprobs', [])[:3]:
            at = alt.get('token', '')
            alp = alt.get('logprob', -99)
            ap = min(100.0, 100 * 2.71828 ** alp) if alp < 0 else 0
            lines.append(f"       vs: {at!r:25s}  logprob={alp:+.3f}  ~{ap:.1f}%")
        lines.append("")
    return "\n".join(lines)

if __name__ == '__main__':
    prompt = ' '.join(sys.argv[1:]) if len(sys.argv) > 1 \
        else 'What is 2+2? Answer in one word.'
    result, err = analyze_logprobs(prompt)
    if err:
        print('ERROR:', err)
        sys.exit(1)
    print(format_logprobs(result))
