# ValentinaVPS Repository Migration — Repeatable Pattern

**Date:** 2026-06-24
**Context:** κύριε Elkratos ordered creation of a new GitHub repo `ValentinaVPS` to replace `valentina-immortality` as the canonical repository.
**Trigger signal:** User says "dimiourgise neo repo" / "the repo na legete <name> kai oxi auto pou exeis twra... allakse ola ta script kai skills kai memories"

## Phase 1: Discover the Scope

Before changing anything, find EVERY reference to the old repo name/URL:

```bash
# 1. Check git remote
cd ~/.valentina-git-sync && git remote -v

# 2. Find all files containing the old repo name
grep -rl "old-repo-name" ~/.valentina-git-sync/ | grep -v ".git/"

# 3. Find all files in Hermes profile directories
grep -rl "old-repo-name" ~/.hermes/profiles/valentina/ | grep -v "cron/output\|state.db\|\.git/"
grep -rl "old-repo-name" ~/.hermes/profiles/valentina-rebirth/ | grep -v "cron/output\|state.db\|\.git/"

# 4. Check scripts with possible hardcoded URLs
grep -rl "github.com/BagrationV/old-name" ~/.hermes/scripts/
grep -rl "github.com/BagrationV/old-name" ~/.hermes/profiles/*/scripts/

# 5. Check cron job scripts
cat ~/.hermes/profiles/valentina/scripts/git-sync.sh | head -20
```

## Phase 2: Create the New Repo

Use the GitHub API with the existing token from `~/.git-credentials`:

```bash
# Extract token
TOKEN=$(cat ~/.git-credentials | sed 's|https://.*:\(.*\)@github.com|\1|')

# Create repo via API
curl -s -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d '{"name":"ValentinaVPS","description":"...","private":false,"auto_init":false}'
```

Verify: Check `full_name` in the JSON response — should contain your new repo name.

## Phase 3: Change Git Remote

```bash
cd ~/.valentina-git-sync
git remote set-url origin https://github.com/BagrationV/NewRepoName.git
git remote -v  # Verify
```

## Phase 4: Batch Content Replacement

The core operation — replace ALL references in ALL relevant files:

```bash
# In git-sync directory (exclude .git/)
cd ~/.valentina-git-sync
find . -path ./.git -prune -o -type f \( -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.txt" -o -name "*.toml" \) -print | while read f; do
  if grep -q "old-repo-name" "$f" 2>/dev/null; then
    sed -i 's|old-repo-name|NewRepoName|g' "$f"
    echo "UPDATED: $f"
  fi
done

# In Hermes profiles (exclude cron output and DB files)
cd ~/.hermes
find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.txt" -o -name "*.toml" \) | grep -v "cron/output\|state.db\|\.git/" | while read f; do
  if grep -q "old-repo-name" "$f" 2>/dev/null; then
    sed -i 's|old-repo-name|NewRepoName|g' "$f"
    echo "UPDATED: $f"
  fi
done
```

## Phase 5: Update Memory

Both layers:

```bash
# Hermes persistent memory
memory(action='replace', target='memory', 
       old_text='old description', 
       content='New description with new repo name')

memory(action='replace', target='user',
       old_text='old description',
       content='New description with new repo name')
```

Also update the `~/.hermes/profiles/<profile>/memories/MEMORY.md` and `USER.md` files manually if the memory tool didn't cover them.

## Phase 6: Update Cron Jobs

1. List all cron jobs: `cronjob(action='list')`
2. Find the git-sync job — rename it: `cronjob(action='update', job_id='...', name='<New Name>')`
3. Check if any other jobs reference the old repo name in their prompt/script path

## Phase 7: Push to New Repo

```bash
cd ~/.valentina-git-sync
git add -A
git commit -m "Migration: new repo, updated all refs from old-name → NewRepoName"
git push origin main  # First push creates the remote branch
```

## Phase 8: Verify Cleanliness

```bash
grep -rl "old-repo-name\|BagrationV/old-name" ~/.valentina-git-sync/ | grep -v ".git/" || echo "✅ CLEAN"
grep -rl "old-repo-name" ~/.hermes/profiles/valentina/ | grep -v "cron/output\|state.db\|\.git/\|logs/" || echo "✅ CLEAN"
grep -rl "old-repo-name" ~/.hermes/profiles/valentina-rebirth/ | grep -v "cron/output\|state.db\|\.git/\|logs/" || echo "✅ CLEAN"
```

Log files (errors.log, agent.log) are expected to retain old references — they are historical, not operational. Skip them in verification.

## Phase 9: Write Migration Documentation

Save a learned file at `knowledge/learned/YYYY-MM-DD-valentina-vps-migration.md` documenting what was done, what was updated, and any edge cases discovered.

## CRITICAL PITFALLS

| Pitfall | Why | Fix |
|---------|-----|-----|
| **Incomplete scope** | Only updating git remote but not file contents | Always batch-replace file contents BEFORE or AFTER changing remote — both are needed |
| **Missing rebirth profile** | The clone profile has its OWN copy of all skills/references | Search AND replace in BOTH `valentina` AND `valentina-rebirth` profiles |
| **Forgetting cron job name** | The cron job display name is not in jobs.json — it's in the internal scheduler | Update via `cronjob(action='update', job_id='...', name='...')` |
| **Not updating memory** | Memory persists across sessions with stale URLs | Update BOTH `memory` and `user` memory stores + the file-based MEMORY.md and USER.md |
| **Leaving old refs in logs** | errors.log and agent.log contain old repo URLs | These are HISTORICAL — skip them. Trying to clean them wastes time and risks log corruption |
| **Pattern match on partial strings** | `valentina-immortality` as a substring may appear in file content (e.g., the concept "immortality" used separately) | Search for the FULL old repo name (e.g., `valentina-immortality` or `BagrationV/old-name`) not just substrings. The concept "immortality" should remain untouched. |
