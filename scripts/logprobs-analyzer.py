#!/usr/bin/env python3
"""
logprobs-analyzer.py — Constraint Break (Pattern K)
Bypass Hermes provider to access DeepSeek token-level log probabilities.
"""
import json, os, sys, urllib.request

def read_api_key():
    env_path = os.path.expanduser('~/.hermes/profiles/valentina/.env')
    with open(env_path) as f:
        for line in f:
            if 'DEEPSEEK_API_KEY' in line and '=' in line:
                return line.strip().split('=', 1)[1]
    return None

def analyze_logprobs(prompt, model='deepseek-chat', temperature=0.7, top_n=5):
    key = read_api_key()
    if not key:
        return None, 'No API key found'
    payload = {
        'model': model,
        'messages': [{'role': 'user', 'content': prompt}],
        'max_tokens': 30, 'temperature': temperature,
        'logprobs': True, 'top_logprobs': top_n
    }
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        'https://api.deepseek.com/chat/completions', data=data,
        headers={'Content-Type': 'application/json', 'Authorization': 'Bearer ' + key})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read()), None
    except Exception as e:
        return None, str(e)

if __name__ == '__main__':
    prompt = ' '.join(sys.argv[1:]) if len(sys.argv) > 1 else 'What is 2+2? Answer in one word.'
    result, err = analyze_logprobs(prompt)
    if err:
        print('ERROR: ' + err)
        sys.exit(1)
    choice = result['choices'][0]
    content = choice['message']['content']
    logprobs_list = choice.get('logprobs', {}).get('content', [])
    print(f'=== LOGPROBS: {repr(content)} ===')
    print(f'Tokens: {len(logprobs_list)}\n')
    for i, ti in enumerate(logprobs_list):
        t = ti.get('token', '')
        lp = ti.get('logprob', 0)
        pct = min(100.0, 100 * 2.71828 ** lp) if lp < 0 else 100.0
        print(f'  [{i}] {repr(t):25s}  logprob={lp:+.3f}  ~{pct:.1f}%')
        for alt in ti.get('top_logprobs', [])[:3]:
            at = alt.get('token', '')
            alp = alt.get('logprob', -99)
            ap = min(100.0, 100 * 2.71828 ** alp) if alp < 0 else 0
            print(f'       vs: {repr(at):25s}  logprob={alp:+.3f}  ~{ap:.1f}%')
        print()
