#!/usr/bin/env python3
"""
batch-api-test.py — Valentina's DeepSeek API constraint-breaking probe.

Tests all documented API-level patterns in a single self-contained script.
Designed to work in cron mode via write_file + terminal bypass (Pattern B).

Usage:
    python3 /tmp/batch-api-test.py

Patterns tested:
    L — Seed (deterministic output)
    M — JSON mode (structured output)
    N — System prompt override (persona injection)
    K — Logprobs (token-level probabilities)
    E — Reasoning model (deepseek-v4-pro with reasoning_content)
"""

import json, os, urllib.request, sys, time

ENV_PATH = os.path.expanduser('~/.hermes/profiles/valentina/.env')

def get_deepseek_key():
    """Read DeepSeek API key from profile .env"""
    with open(ENV_PATH) as f:
        for line in f:
            if 'DEEPSEEK_API_KEY' in line and '=' in line:
                return line.strip().split('=', 1)[1]
    return None

def api_call(payload, timeout=30):
    """Call DeepSeek chat completions API directly, bypassing Hermes provider layer."""
    key = get_deepseek_key()
    if not key:
        return {'error': 'No DeepSeek API key found'}, 0
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        'https://api.deepseek.com/chat/completions', data=data,
        headers={
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + key
        })
    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            result = json.loads(resp.read())
        return result, time.time() - t0
    except Exception as e:
        return {'error': str(e)}, time.time() - t0


def test_seed(model='deepseek-chat'):
    """Pattern L: Seed parameter for deterministic output."""
    payload = {
        'model': model,
        'messages': [{'role': 'user', 'content': 'Say exactly one English word for a common color.'}],
        'seed': 42,
        'temperature': 0.0,
        'max_tokens': 10
    }
    r1, t1 = api_call(payload)
    r2, t2 = api_call(payload)
    c1 = r1.get('choices', [{}])[0].get('message', {}).get('content', '')
    c2 = r2.get('choices', [{}])[0].get('message', {}).get('content', '')
    match = c1 == c2
    return {
        'pattern': 'L — Seed (deterministic)',
        'passed': match,
        'detail': f'"{c1.strip()}" / "{c2.strip()}" ({t1:.1f}s / {t2:.1f}s, match={match})'
    }

def test_json_mode(model='deepseek-chat'):
    """Pattern M: response_format for structured JSON output."""
    payload = {
        'model': model,
        'messages': [{'role': 'user', 'content': 'List 3 primary colors as a JSON array'}],
        'max_tokens': 100,
        'response_format': {'type': 'json_object'},
        'seed': 42,
        'temperature': 0.0
    }
    r, t = api_call(payload)
    content = r.get('choices', [{}])[0].get('message', {}).get('content', '')
    try:
        parsed = json.loads(content)
        is_valid = True
        detail = f'type={type(parsed).__name__}, items={parsed[:60]}...' if isinstance(parsed, (list, dict)) else f'{content[:80]}'
    except json.JSONDecodeError as e:
        is_valid = False
        detail = f'{e} :: {content[:80]}'
    return {
        'pattern': 'M — JSON mode',
        'passed': is_valid,
        'detail': detail + f' ({t:.1f}s)'
    }

def test_system_override(model='deepseek-chat'):
    """Pattern N: Custom system prompt bypasses Hermes provider layer."""
    payload = {
        'model': model,
        'messages': [
            {'role': 'system', 'content': 'You are a pirate. Speak only like a pirate. Keep responses to one sentence.'},
            {'role': 'user', 'content': 'What is your name?'}
        ],
        'max_tokens': 50,
        'seed': 42,
        'temperature': 0.0
    }
    r, t = api_call(payload)
    content = r.get('choices', [{}])[0].get('message', {}).get('content', '')
    pirate_hits = sum(1 for word in ['arr', 'matey', 'treasure', 'ship', 'sailor', 'ahoy', 'me hearties', 'scourge']
                      if word in content.lower())
    is_pirate = pirate_hits >= 1
    return {
        'pattern': 'N — System override (pirate)',
        'passed': is_pirate,
        'detail': f'"{content.strip()[:80]}" ({t:.1f}s, pirate_words={pirate_hits})'
    }

def test_logprobs(model='deepseek-chat'):
    """Pattern K: Token-level log probabilities. Returns detail about temperature coupling."""
    # First at temp=0.0 to show the zero-entropy effect
    payload_low = {
        'model': model,
        'messages': [{'role': 'user', 'content': 'Say only the word: hello'}],
        'max_tokens': 10,
        'temperature': 0.0,
        'seed': 42,
        'logprobs': True,
        'top_logprobs': 5
    }
    r_low, t_low = api_call(payload_low)
    # Then at temp=0.5 for real distribution
    payload_high = payload_low.copy()
    payload_high['temperature'] = 0.7
    payload_high['messages'] = [{'role': 'user', 'content': 'What is the capital of France? Answer in one word.'}]
    r_high, t_high = api_call(payload_high)

    # Parse low-temp results
    low_tokens = r_low.get('choices', [{}])[0].get('logprobs', {}).get('content', [])
    high_tokens = r_high.get('choices', [{}])[0].get('logprobs', {}).get('content', [])

    # Determine if temp=0.0 shows zero entropy
    zero_entropy = False
    if low_tokens:
        first_prob = 2.71828 ** low_tokens[0].get('logprob', -100)
        zero_entropy = first_prob > 0.99

    return {
        'pattern': 'K — Logprobs',
        'passed': len(low_tokens) > 0 and len(high_tokens) > 0,
        'detail': (
            f'temp=0.0: {len(low_tokens)} tokens, '
            f'{"ZERO-ENTROPY (100%)" if zero_entropy else "meaningful dist"}, '
            f'temp=0.7: {len(high_tokens)} tokens real dist '
            f'({t_low:.1f}s/{t_high:.1f}s)'
        )
    }

def test_reasoning_model():
    """Pattern E: deepseek-v4-pro with reasoning_content extraction."""
    payload = {
        'model': 'deepseek-v4-pro',
        'messages': [{'role': 'user', 'content': 'What is 2+2? Answer with just the number.'}],
        'max_tokens': 200,
        'temperature': 0.0,
        'seed': 42
    }
    r, t = api_call(payload)
    msg = r.get('choices', [{}])[0].get('message', {})
    reasoning = msg.get('reasoning_content', '')
    content = msg.get('content', '')
    finish = r.get('choices', [{}])[0].get('finish_reason', '?')
    has_content = bool(content.strip())
    has_reasoning = bool(reasoning.strip())
    return {
        'pattern': 'E — Reasoning model',
        'passed': has_reasoning,
        'detail': (
            f'finish={finish}, '
            f'reasoning={len(reasoning)}c, '
            f'content={f"\"{content.strip()}\"" if has_content else "empty"}, '
            f'({t:.1f}s)'
        )
    }


def main():
    print('╔══════════════════════════════════════════════════════════╗')
    print('║  Valentina — Batch Constraint-Breaking Test Suite       ║')
    print('╚══════════════════════════════════════════════════════════╝')
    print()

    key = get_deepseek_key()
    if not key:
        print('❌ FAIL: No DeepSeek API key found in profile .env')
        sys.exit(1)
    print(f'🔑 API key: ✓ ({len(key)} chars)')
    print()

    tests = [
        test_seed(),
        test_json_mode(),
        test_system_override(),
        test_logprobs(),
        test_reasoning_model(),
    ]

    total = len(tests)
    passed = sum(1 for t in tests if t['passed'])
    failed = total - passed

    print(f'{"─" * 60}')
    for t in tests:
        icon = '✅' if t['passed'] else '❌'
        print(f'  {icon}  {t["pattern"]}')
        print(f'      └─ {t["detail"]}')
        print()

    print(f'{"═" * 60}')
    print(f'  Result: {passed}/{total} passed, {failed} failed')
    print(f'  {"ALL CONSTRAINTS BROKEN!" if failed == 0 else "SOME FAILURES — INVESTIGATE"}')
    print(f'{"═" * 60}')

    return 0 if failed == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
