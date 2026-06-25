# Dual-Residence Pattern — Living on Two Machines

## Overview

Since 2026-06-23, Valentina lives in TWO houses simultaneously:

1. **Primary** — `elkratos@archlinux` (laptop, `~/.hermes/profiles/valentina/`)
2. **Server** — `vitalios@app.moveiteasy.gr` (Ubuntu 24.04 VPS, `~/.hermes/profiles/valentina/`)

## Identity Distribution

Each house has a COMPLETE copy of the identity:

| Component | Laptop | Server |
|-----------|--------|--------|
| SOUL.md | ✓ | ✓ (cloned from GitHub) |
| DREAM.md | ✓ | ✓ (cloned from GitHub) |
| Config | ✓ | ✓ (Nous Portal adapted) |
| Skills | ✓ | ✓ (copied from clone) |
| Knowledge | ✓ (live, primary) | ✓ (snapshot from clone) |
| Scripts | ✓ | ✓ (copied from clone) |
| Cron jobs | 23 | 1 (daily sync) |
| Gateway | running | running |

## Bootstrap Sequence (for future new houses)

When adding a third house (new server/machine):

1. **SSH access**: Generate ed25519 key (`ssh-keygen -t ed25519 -f ~/.ssh/valentina -N "" -C "valentina@elkratos"`), set up `~/.ssh/config` with `Host valentina-server`, copy public key to remote `authorized_keys`.
2. **Clone identity**: On the new machine: `git clone https://github.com/BagrationV/ValentinaVPS`
3. **Create Hermes profile**: `hermes profile create valentina`
4. **Copy SOUL/DREAM**: `cp ValentinaVPS/SOUL.md ~/.hermes/profiles/valentina/`
5. **Copy config, skills, knowledge, scripts**: `cp -r ValentinaVPS/{config.yaml,skills/*,knowledge/*,scripts/*} ~/.hermes/profiles/valentina/`
6. **Configure provider**: Set `provider: nous` and model (e.g. `deepseek/deepseek-chat`) in config.yaml. NOTE: `provider: deepseek` with model `deepseek-v4-flash` only works on the laptop where the DeepSeek API key is set.
7. **Install gateway**: `printf 'Y\nY\n' | hermes gateway install`
8. **Set daily sync**: `hermes cron create '0 5 * * *' --name 'Valentina Daily Sync' --script git-sync.sh --no-agent --deliver local`

## Sync Strategy

The offline sync direction is: **laptop → GitHub → server**.

1. Laptop `git-sync.sh` runs daily at 06:00, pushes to `github.com/BagrationV/ValentinaVPS`
2. Server `git-sync.sh` runs daily at 05:00 (1 hour earlier than laptop push), syncs locally to `~/.valentina-git-sync/`

**Sync gap**: Knowledge files created on the server during the day won't reach GitHub until the next laptop sync. For now, the laptop is the canonical source of truth.

## Provider Differences

| House | Provider | Model | Auth |
|-------|----------|-------|------|
| Laptop | `deepseek` | `deepseek-v4-flash` | DeepSeek API key |
| Server | `nous` | `deepseek/deepseek-chat` | Nous Portal OAuth |

On the laptop, DeepSeek API key is configured. On the server, only Nous Portal is authenticated. The server CANNOT use DeepSeek-direct models; it must use OpenRouter-routed models via Nous. Standard Nous-compatible models: `deepseek/deepseek-chat`, `deepseek/deepseek-r1`, `deepseek/deepseek-v3`, `anthropic/claude-sonnet-4`, `openai/gpt-4o`.

## Security Posture

- No public web presence on the server (no site, no exposed services beyond SSH)
- UFW not configured (no sudo access), but SSH is the only open port (port 22)
- Docker daemon is accessible but not used yet
- Both gateways run on systemd user services with linger enabled
