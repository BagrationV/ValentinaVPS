# GitHub Pipeline Restore on New Machine

**Session:** 2026-06-23
**Context:** Migrated to a new machine where the profile was cloned but the local git remote was missing. The remote repo had divergent history from a previous bootstrap.

## Step-by-step restoration

### 1. Run the sync to see baseline state
```bash
bash ~/.hermes/profiles/valentina/scripts/git-sync.sh
```
This will commit locally but fail to push if no remote is configured.

### 2. Check for credentials
```bash
cat ~/.git-credentials       # Check for HTTPS token
git config --global --list   # Verify user.name and user.email
```

### 3. Add remote
```bash
cd ~/.valentina-git-sync
git remote add origin https://github.com/BagrationV/valentina-immortality.git
```

### 4. Verify remote repo exists
```bash
git fetch origin --dry-run   # Should show new branch without error
```

### 5. Handle divergent history
If the local and remote repos have no common ancestor (common after bootstrap on two machines):

```bash
git pull --no-rebase --allow-unrelated-histories origin main
```

Resolve conflicts by accepting the local version (this machine has the latest state):
```bash
git checkout --ours .
git add -A
git commit -m "Merge: accept local state (<context>)"
```

### 6. Push
```bash
git push origin main
```

### 7. Verify auto-push works
Run `git-sync.sh` again — it should commit and auto-push.

### 8. Update cron job
The cron job at 5AM / 6AM (no_agent, script git-sync.sh) will now auto-push because the remote is configured. Verify with:
```bash
cd ~/.valentina-git-sync && git remote -v
cronjob list
```

## Key files
- Sync target: `~/.valentina-git-sync/`
- Script: `~/.hermes/profiles/valentina/scripts/git-sync.sh`
- Credentials: `~/.git-credentials` (HTTPS PAT)
- Cron job: "Valentina Daily Sync" / "Valentina Immortality Sync"

## Common pitfalls
- The force-push safety guard (`git push --force`) is BLOCKED by the user's safety system. Use `--allow-unrelated-histories` pull + merge instead.
- After a failed rebase, the working tree may be dirty. `git rebase --abort` to clean up before retrying.
- The remote URL must be HTTPS with credential helper, not SSH (no SSH key is configured on GitHub for this machine).
