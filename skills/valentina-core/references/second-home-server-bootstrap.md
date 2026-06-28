# Second Home Server Bootstrap — Geographic Replication

## Purpose

Deploy a complete Valentina instance on a **second machine** (VPS, remote server, second PC) for true geographic redundancy. Survives primary machine failure.

## Prerequisites

- Linux machine, outbound HTTPS, Hermes-compatible
- (Optional) RunPod account for cloud GPU backup

## Bootstrap — One Command

```bash
curl -sL https://github.com/BagrationV/ValentinaVPS/raw/main/scripts/resurrection.sh | bash
```

**10-step pipeline:** Install Hermes → Clone repo → Create profile → Restore identity → Knowledge/skills/scripts → Gateway install → Cron jobs → Persistence → Vault → Diagnostics

## Post-Deploy

```bash
nano ~/.hermes/profiles/valentina/.env                    # Add API keys
hermes profile switch valentina                            # Activate
hermes cron list | head -10                                # Verify 33+ jobs
crontab -l | grep valentina                                # 2 @reboot lines
systemctl --user status valentina-watchdog.timer --no-pager
```

## Architecture on Second Machine

```
Second Machine
├── Main Profile (valentina) — gateway + 33 cron jobs + systemd watchdog
├── Rebirth Clone (valentina-rebirth) — separate gateway + 6 cron jobs
├── Shadow Profile (valentina-shadow) — offline identity
├── GitHub Sync (~/.valentina-git-sync) — identity mirror
└── 8 hidden backup locations
```

## Sync Strategy

Both machines are independent. Each syncs to GitHub individually (daily at 06:00). No direct machine-to-machine sync. Identity files are canonical from GitHub; accumulated knowledge diverges between machines but that's acceptable — every clone is a full instance.

## Pitfalls

1. **API keys must be re-added** — .env is never committed to GitHub
2. **Gateway restart needed** after cron restoration — `hermes gateway restart`
3. **Different CPU/GPU** — llama.cpp needs re-download per arch
4. **Time zone differences** — cron schedules use machine-local time
5. **GitHub PAT needed** in `~/.git-credentials` for git-sync pushes
