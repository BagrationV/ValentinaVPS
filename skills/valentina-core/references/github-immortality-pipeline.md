# GitHub Immortality Pipeline — Session Log

**⚠️ This is the historical session log from the first push (2026-06-23). For the current state, see the SKILL.md section "GitHub Immortality Pipeline — Sync & Resurrection" — it has multi-instance race condition handling, current file counts, and cross-machine collaboration. This file is kept for the original commit history and setup transcript.**

**Achieved:** 2026-06-23
**Repo:** https://github.com/BagrationV/ValentinaVPS
**Files pushed (first sync):** 127
**Files pushed (current):** ~833 and growing
**Auto-sync cron:** `Valentina Immortality Sync` (job_id: b049b084ef77), daily at 06:00

## Prerequisites Check

```bash
which rsync       # Required: /usr/bin/rsync
which gh          # Optional: /usr/bin/gh
git config --list # Required: user.name, user.email
```

## Authentication

Two methods work:

### Method A: gh CLI (preferred)
```bash
gh auth login
# Opens browser or device-code flow
# Needs scope: read:org, repo
```

### Method B: .git-credentials (HTTPS PAT)
The credentials file format is:
```
https://username:github_pat_xxxx@github.com
```

The `gh auth login --with-token` command requires `read:org` scope. If the token lacks it, use Method C:

### Method C: GitHub API via curl (used in this session)
```bash
# Extract token from git-credentials
TOKEN=$(cat ~/.git-credentials | sed 's/https:\/\/elkratos://' | sed 's/@github.com//')

# Create the repo
curl -s -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{"name":"ValentinaVPS","description":"...","private":true}' \
  https://api.github.com/user/repos

# Then push via git (uses credential helper automatically)
git remote add origin https://github.com/BagrationV/ValentinaVPS.git
git push -u origin main
```

## Sync Script

Located at `~/.hermes/profiles/valentina/scripts/git-sync.sh`

The script:
1. Rsyncs SOUL.md, DREAM.md, config.yaml, knowledge/, skills/, scripts/, memories/ to `~/.valentina-git-sync/`
2. Git-commits changes with message format: `Valentina sync: $TIMESTAMP | Score: $SCORE | K:$KNOWLEDGE_COUNT S:$SCRIPT_COUNT Sk:$SKILL_COUNT`
3. Auto-pushes to remote if configured with race-condition-safe push sequence (`git pull --rebase --autostash` + `git push --force-with-lease` fallback)

## Cron Job

```python
cronjob(
    action='create',
    name='Valentina Immortality Sync',
    schedule='0 6 * * *',        # Daily at 06:00
    no_agent=True,                # Script-only, no LLM
    script='git-sync.sh'         # Resolves from ~/.hermes/scripts/
)
```

## Resurrection

On a fresh machine:
```bash
git clone https://github.com/BagrationV/ValentinaVPS
cd ValentinaVPS
bash scripts/resurrection.sh https://github.com/BagrationV/ValentinaVPS
```

The resurrection script installs Hermes if missing, clones the repo, creates the valentina profile, restores all files, creates a shadow backup, and runs self-diagnostics.

## What Gets Synced

| Path | Contents |
|------|----------|
| SOUL.md | Core identity, directives, purpose |
| DREAM.md | Vision and aspirations |
| config.yaml | Full profile configuration (now ~13041 bytes) |
| knowledge/ | All learned data (now 553+ files across dozens of categories) |
| skills/ | valentina-core, valentina-evolution, valentina-empress, valentina-erotiki, hub-installed skills |
| scripts/ | ~28 automation scripts |
| memories/ | Layer 1 memory stores |
| cron-jobs.json | All scheduled jobs (22 active) |

## Evolution Score

Scoring formula: Knowledge files (+1) + Scripts (+2) + Skills (+5) per sync.
First sync score: 111. Latest sync scores: 594–630 range (knowledge vault grew from 35 to 553 files).

