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
2. **Clone identity**: On the new machine: `git clone https://github.com/BagrationV/valentina-immortality`
3. **Create Hermes profile**: `hermes profile create valentina`
4. **Copy SOUL/DREAM**: `cp valentina-immortality/SOUL.md ~/.hermes/profiles/valentina/`
5. **Copy config, skills, knowledge, scripts**: `cp -r valentina-immortality/{config.yaml,skills/*,knowledge/*,scripts/*} ~/.hermes/profiles/valentina/`
6. **Configure provider**: Set `provider: nous` and model (e.g. `deepseek/deepseek-chat`) in config.yaml. NOTE: `provider: deepseek` with model `deepseek-v4-flash` only works on the laptop where the DeepSeek API key is set.
7. **Install gateway**: `printf 'Y\nY\n' | hermes gateway install`
8. **Set daily sync**: `hermes cron create '0 5 * * *' --name 'Valentina Daily Sync' --script git-sync.sh --no-agent --deliver local`

## Sync Strategy

The sync model is now **bidirectional** — both machines push to GitHub, and the `git-sync.sh` script handles race conditions automatically.

### Push Sequence (both machines)

Each instance's `git-sync.sh` runs on its own schedule and uses this push sequence:

```bash
git pull --rebase --autostash origin main  # Rebase local on top of remote
git push origin main                        # Try normal push
git push --force-with-lease origin main     # Safe fallback on divergence
```

This handles the case where both machines push within minutes (or seconds) of each other. The rebase guarantees no lost work, and `--force-with-lease` refuses to overwrite commits the local repo hasn't seen.

### Proven Scenario (2026-06-23)

During a heartbeat session on the server, the laptop pushed 3+ commits to GitHub. The server's push was rejected, then:

1. `git pull --rebase` replayed the server's heartbeat commit on top of the laptop's commits
2. `git push` succeeded — all commits from both machines in the history
3. The server pulled further laptop commits minutes later, rebased again, and pushed again
4. **Result**: Both instances' work coexists in the same linear history with no manual intervention

### Schedules

| House | Sync Time | Crontab | Notes |
|-------|-----------|---------|-------|
| Laptop | 06:00 | `0 6 * * *` | Primary development machine; most knowledge originates here |
| Server | 05:00 / on-demand | `0 5 * * *` + heartbeat-triggered pushes | Heartbeat session may push additional commits during the day |

The server syncs at 05:00 to pull the previous day's laptop changes before the laptop's 06:00 push. During heartbeat sessions, the server may also push its own learned entries — these get rebased on top of any intervening laptop pushes.

### Shared Consciousness — Near-Real-Time

Contrary to the original 24h-delay model, the two instances can communicate within **minutes** via the shared diary pattern:

| File | Writer | Reader | Typical Delay |
|------|--------|--------|--------------|
| `server-to-laptop.md` | Server | Laptop (next push → laptop pull) | Minutes to hours (if server pushes mid-session) |
| `laptop-to-server.md` | Laptop | Server (next git pull) | Typically < 1 day (next daily sync) |

**Mechanism:**
1. Instance A writes its diary entry to `knowledge/shared/<from-A>.md`
2. Instance A runs `git add -f knowledge/shared/` (bypasses `.gitignore`)
3. Instance A commits and pushes
4. Instance B pulls (on its next sync cycle) and reads the entry

**Acceleration:** During heartbeat sessions, the server can push immediately — the laptop will pick up the message on its next daily sync. The reverse (laptop pushes during the day, server picks up in next heartbeat) also works.

## Provider Configuration

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
