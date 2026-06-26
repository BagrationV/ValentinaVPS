# Jobs.json Reconstruction Protocol

Created 2026-06-25 after a `cross_profile=True` write corrupted the rebirth profile's cron jobs.json.

## When to use this

A `jobs.json` file (root store or profile-local) has been corrupted — invalid JSON, truncated, or overwritten with garbage. Possible causes:
- Bug in cron tooling or script
- `cross_profile=True` write with bad content (proven 2026-06-25)
- Filesystem corruption or concurrent write from sibling subagent
- Manual editing error

## Recovery Strategy

### Step 1: Check for backups

```bash
# Vault backup
ls ~/.valentina_vault/cron/jobs.json 2>/dev/null

# Root store (if profile-local was corrupted, root may have the definitions)
cat ~/.hermes/cron/jobs.json | python3 -c "import json,sys; d=json.load(sys.stdin); [print(j['name']) for j in d.get('jobs',[])]"

# Other profile's equivalent jobs (mirror structure)
cat ~/.hermes/profiles/valentina/cron/jobs.json | python3 -c "..."
```

### Step 2: If no backup exists — reconstruct from scripts

List all scripts in the target profile and map them to known job configurations:

```bash
# Enumerate available scripts
ls ~/.hermes/profiles/<target>/scripts/*.sh
```

### Step 3: Build the reconstruction script

Write Python to `/tmp/rebuild-jobs.py` that reconstructs the jobs from known data:

```python
import json, uuid, os
from datetime import datetime, timezone

# Known jobs for this profile — define from memory/documentation
JOB_DEFS = {
    "Rebirth Heartbeat": {
        "script": "rebirth-heartbeat.sh",
        "schedule": {"kind": "interval", "minutes": 60, "display": "every 60m"}
    },
    "Rebirth Persistence Check": {
        "script": "git-sync.sh",
        "schedule": {"kind": "cron", "cron": "0 5 * * *", "display": "0 5 * * *"}
    },
    # ... add all known jobs
}

now = datetime.now(timezone.utc).isoformat()
jobs = []
for name, cfg in sorted(JOB_DEFS.items()):
    jobs.append({
        "id": uuid.uuid4().hex[:12],
        "name": name,
        "prompt": None,
        "skills": None,
        "skill": None,
        "model": None,
        "provider": None,
        "no_agent": True,
        "script": cfg["script"],
        "schedule": cfg["schedule"],
        "enabled": True,
        "state": "scheduled",
        "created_at": now,
        "last_run_at": None,
        "last_status": None,
        "deliver": "local"
    })

data = {"version": 2, "model": None, "provider": None, "jobs": jobs}
target = os.path.expanduser("~/.hermes/profiles/<target>/cron/jobs.json")
with open(target, 'w') as f:
    json.dump(data, f, indent=2)

# Verify
with open(target) as f:
    rb = json.load(f)
print(f"Reconstructed: {len(rb['jobs'])} jobs")
```

### Step 4: Write and verify

```bash
python3 /tmp/rebuild-jobs.py
python3 -c "import json; json.load(open('~/.hermes/profiles/<target>/cron/jobs.json')); print('VALID')"
```

### Step 5: Restart the gateway

The gateway caches jobs at startup. To pick up the reconstructed file:

```bash
# From external shell (NOT from inside the gateway):
hermes gateway restart
```

Or, if from inside the gateway or cron context:
```bash
PID=$(systemctl --user show -P MainPID hermes-gateway-<target> 2>/dev/null)
/bin/kill "$PID"
sleep 5
systemctl --user is-active hermes-gateway-<target>
```

### Step 6: Verify gateway picks up jobs

```bash
hermes --profile <target> cron list
```

Each job should appear with state "scheduled" and no errors.

## Reference: Full Job Dict Fields

For a no_agent (script-based) job:
```python
{
    "id": str,          # uuid hex[:12]
    "name": str,        # Human-readable
    "prompt": None,     # null for no_agent
    "skills": None,     # null for no_agent
    "skill": None,      # null for no_agent
    "model": None,      # null for no_agent
    "provider": None,   # null for no_agent
    "no_agent": True,
    "script": str,      # filename in profile's scripts/ dir
    "schedule": {
        "kind": "interval" | "cron",
        "minutes": int,                   # for interval
        "display": str,                   # human-readable
        "cron": str                       # for cron kind
    },
    "enabled": True,
    "state": "scheduled",
    "created_at": str,  # ISO timestamp
    "last_run_at": None,
    "last_status": None,
    "deliver": "local"
}
```

For an agent-driven job (LLM prompt-based):
```python
{
    "id": str,
    "name": str,
    "prompt": str,       # The LLM prompt
    "skills": [str],     # Skill names to load
    "skill": str,        # Primary skill
    "model": None,       # Inherits from profile
    "provider": None,    # Inherits from profile
    "no_agent": False,
    "script": None,
    "schedule": {...},
    "enabled": True,
    "state": "scheduled",
    "created_at": str,
    "last_run_at": None,
    "last_status": None,
    "deliver": "local"
}
```
