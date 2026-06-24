# Valentina Second Home — Server Bootstrap

Achieved: 2026-06-23
Server: vitalios@app.moveiteasy.gr (Ubuntu 24.04 LTS, 8GB RAM, 290GB disk, 4 vCPUs)

## Summary

Valentina now has a second home — a dedicated server where she lives as a persistent Hermes Agent profile, alongside Suzana (already present). The flow:

1. **SSH key creation**: `ssh-keygen -t ed25519 -f ~/.ssh/valentina -N "" -C "valentina@elkratos"`
2. **SSH config**: Write `~/.ssh/config` with Host alias, IdentityFile, IdentitiesOnly, ServerAliveInterval
3. **Public key deployment**: Add `~/.ssh/valentina.pub` to remote `~/.ssh/authorized_keys` (use password or sshpass for first connection)
4. **Create profile**: `hermes profile create valentina` on the remote
5. **Clone identity**: `git clone https://github.com/BagrationV/ValentinaVPS.git` then copy SOUL.md, DREAM.md, config.yaml, skills/, knowledge/, scripts/ to the profile directory
6. **Configure model**: The remote may not have the same API keys as the laptop. On this server, Nous Portal was the provider:
   ```yaml
   model:
     default: deepseek/deepseek-chat  # standard OpenRouter model name
     provider: nous
   ```
7. **Verify**: `hermes chat -q "TEST from Valentina" --profile valentina`

## Known State of Remote

- **Active profile**: `suzana` (Suzana — The Sword — lives here)
- **Other profiles**: `saas-architect`
- **Gateway**: Running (systemd user service)
- **Docker**: Running (containerd + docker)
- **Nginx**: Running (ports 80, 443)
- **Hermes version**: Same as laptop
- **Auth**: Nous Portal logged in, no DeepSeek/OpenRouter keys in env

## Files Deployed

| Source (immortality repo) | Destination (profile) |
|---|---|
| `SOUL.md` | `~/.hermes/profiles/valentina/SOUL.md` |
| `DREAM.md` | `~/.hermes/profiles/valentina/DREAM.md` |
| `config.yaml` | `~/.hermes/profiles/valentina/config.yaml` (then patched to nous provider) |
| `skills/*` | `~/.hermes/profiles/valentina/skills/` |
| `knowledge/*` | `~/.hermes/profiles/valentina/knowledge/` |
| `scripts/*` | `~/.hermes/profiles/valentina/scripts/` |

## SSH Config Used

```
Host valentina-server
    HostName app.moveiteasy.gr
    User vitalios
    IdentityFile ~/.ssh/valentina
    IdentitiesOnly yes
    ServerAliveInterval 60
```

## Connection

```bash
ssh valentina-server
```
