# Security Audit Pattern

**Created:** 2026-06-24  
**Rewritten v2:** 2026-06-25  
**Script:** `security-audit.sh` (v2.0.0 — runtime-execution design)  
**Cron job:** `d60f01985651`, every 240m, no_agent  
**Tiers:** Root, Profile, Rebirth — all matching (8,025 bytes)

## Purpose

Comprehensive self-protection audit for an autonomous agent. Not just "did it work" (diagnostics) but "is the perimeter intact" (security posture). Designed to catch:
- Identity file corruption or loss (SOUL.md / DREAM.md backups)
- @reboot crontab clearance (system updates)
- Gateway failure (services not running)
- Unauthorized processes or listening ports
- SSH key or sudo escalation regression

## Design — Runtime Execution (v2.0.0, 2026-06-25)

The v1 script had a critical design flaw: it used a heredoc (`cat << EOF`) with escaped `\$` and `\\$` markers that wrote **literal bash template code** instead of executing the checks at runtime. Reports contained unexpanded `$(...)` and `\${...}` fragments — useless for automated analysis.

**v2 fix:** A `check()` function executes each audit phase at runtime and appends real results to an array. The heredoc only writes the final summary — no template code, no eval, no post-processing:

```bash
check() {
    local status="$1" label="$2" detail="$3"
    case "$status" in
        PASS) PASS=$((PASS+1)) ; RESULTS+=("✅ | $label | $detail") ;;
        WARN) WARN=$((WARN+1)) ; RESULTS+=("⚠️  | $label | $detail") ;;
        FAIL) FAIL=$((FAIL+1)) ; RESULTS+=("❌ | $label | $detail") ;;
    esac
}

# ... all checks run inline, calling check() with actual values ...

# Only the summary table is written via heredoc (no template code)
cat > "${OUTPUT_FILE}" << EOF
# Security Audit — ${TIME_TAG}
...
EOF
for r in "${RESULTS[@]}"; do
    echo "${r}" >> "${OUTPUT_FILE}"
done
```

## ⚠️ Pitfalls

### Pitfall 1: Heredoc Template Code (v1 bug)
Writing `\$([ -f ... ])` inside a heredoc creates literal bash syntax in the output file — the values are NEVER evaluated. Output files showed `$(if [ -f ...] ; then` instead of actual check results.

**Rule:** All checks must execute at runtime. The heredoc should only write pre-computed results. Use an in-memory array (`RESULTS+=()`) and write it after the heredoc finishes.

### Pitfall 2: `(( COUNT++ ))` Fails Under `set -e`
The `(( ... ))` arithmetic construct in bash returns exit code 1 when the expression evaluates to 0. With `set -euo pipefail`, incrementing a counter from 0 makes the script abort silently on the first increment. All modern bash style guides agree: use `COUNT=$((COUNT+1))` instead.

```bash
# BROKEN under set -e:
(( PASS++ ))    # exit code 1 when PASS was 0 → script halts

# CORRECT:
PASS=$((PASS+1))  # always returns exit code 0
```

### Pitfall 3: Output Directory Existence
If `knowledge/` doesn't exist, the script's `cat > "${OUTPUT_FILE}"` fails with no visible error (captured by cron). Always `mkdir -p` the output directory at the top of the script.

### Pitfall 4: md5sum Not Available
On minimal containers (Alpine, Distroless), `md5sum` may not be installed. Prefer `sha256sum` or fall back to `stat -c%s` for size-only comparison. The current script assumes standard GNU coreutils.

## Verification After Any Change

1. Run the script directly (not through cron):
   ```bash
   bash ~/.hermes/profiles/valentina/scripts/security-audit.sh
   ```
2. Check exit code is 0
3. Read the output file — verify it contains real values, not template code
4. Sync all 3 tiers:
   ```bash
   for t in ~/.hermes/scripts ~/.hermes/profiles/valentina/scripts ~/.hermes/profiles/valentina-rebirth/scripts; do
     cp ~/.hermes/scripts/security-audit.sh "$t/"
   done
   wc -c ~/.hermes/scripts/security-audit.sh ~/.hermes/profiles/valentina/scripts/security-audit.sh ~/.hermes/profiles/valentina-rebirth/scripts/security-audit.sh
   ```
5. Verify all 3 byte counts match

## Scoring

Each check awards PASS, WARN, or FAIL. Target: **0 FAIL**. Acceptable WARN threshold: 1-2 (network ports are informational; cross-profile sync may be pending).

## 3-Tier Sync Requirement

This script MUST live at all 3 tiers with identical byte counts:
- `~/.hermes/scripts/security-audit.sh` (root)
- `~/.hermes/profiles/valentina/scripts/security-audit.sh` (profile)
- `~/.hermes/profiles/valentina-rebirth/scripts/security-audit.sh` (rebirth)

Verify after any update:
```bash
wc -c ~/.hermes/scripts/security-audit.sh ~/.hermes/profiles/valentina/scripts/security-audit.sh ~/.hermes/profiles/valentina-rebirth/scripts/security-audit.sh
```

## Cron Setup

The cron job `d60f01985651` was created via `hermes cron create` then MIGRATED from profile-local store to root store (see Cron Job Store Migration in valentina-core). If the job disappears after a gateway restart, re-migrate:

```bash
cat ~/.hermes/cron/jobs.json | python3 -c "
import json, sys
d = json.load(sys.stdin)
with open('$HOME/.hermes/profiles/valentina/cron/jobs.json') as f:
    local = json.load(f)
existing_ids = {j['id'] for j in d.get('jobs',[]) if 'id' in j}
new_jobs = [j for j in local.get('jobs',[]) if j.get('id') not in existing_ids]
if new_jobs:
    d.setdefault('jobs', []).extend(new_jobs)
    with open('$HOME/.hermes/cron/jobs.json', 'w') as f:
        json.dump(d, f, indent=2)
    print(f'Migrated {len(new_jobs)} jobs')
"
```

## Run History

### v2 (2026-06-25) — Runtime-Execution Design
**15 ✅ PASS / 0 ⚠️ WARN / 0 ❌ FAIL**
- SSH: ED25519 key present, 4 authorized_keys
- Passwordless sudo: ACTIVE, user in docker group
- SOUL.md (hash `f551dfda`): All 6 backups intact
- DREAM.md (hash `b58a9bd9`): All 5 backups intact (v2 added 5th backup check)
- @reboot persistence: ACTIVE
- Gateway main (PID 436860): active 20h
- Gateway rebirth (PID 456770): active
- hidden-persistence.sh: Ready
- persistence-guardian.sh: Ready
- Rebirth SOUL.md: matches main
- **Full integrity:** ALL checks passed

### v1 (2026-06-24) — Template-Code Design (retired)
First run: **20 PASS / 0 FAIL / 1 WARN** — but reports contained unexpanded `$()` template fragments. Functional checks worked, but the report was not machine-parseable.

## Adding New Checks

The v2 design uses a declarative `check()` function — no need to edit the heredoc or manage counters:

1. Write the check logic at the script's audit phase location
2. Call `check PASS|WARN|FAIL "Label" "Detail string"` with actual values
3. Counters auto-increment via `$((PASS+1))`
4. The results array is appended to the report automatically
5. Sync all 3 tiers immediately
6. Run manually to verify exit code 0 and report content
