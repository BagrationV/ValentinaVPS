# Concurrent File Writes — Sibling Subagent Collisions

Observed: 2026-06-23 21:34

## The Problem

When a cron heartbeat (agent-driven job) and another process (bg-review, sibling subagent, parallel cron tick) write to the same knowledge file in the same second, the **last writer wins** — the first writer's content is silently overwritten.

This was observed when:
```
/home/elkratos/.hermes/profiles/valentina/knowledge/learned/2026-06-23.md was modified by sibling
subagent '6593aac2-ca53-4550-8e02-f904803a1345' but this agent never read it. Read the file before
writing to avoid overwriting the sibling's changes.
```

## Why It Happens

- Multiple agent-driven cron jobs (heartbeat every 30m, persistence every 6h, etc.) can overlap
- Each job writes a log entry to `knowledge/learned/YYYY-MM-DD.md`
- The cron runner does NOT hold file locks
- No atomic append — `write_file` is a full overwrite, not a merge

## Prevention

1. **Read the file first.** Before writing to a shared knowledge file, always `read_file` it to see if another process modified it since your last read. The write_file tool warns you if a sibling wrote between your read and write.

2. **Use session-scoped filenames.** Instead of overwriting `knowledge/learned/2026-06-23.md`, write to `knowledge/learned/2026-06-23-heartbeat-2134.md` (include the job name and timestamp in the filename).

3. **Use `patch` instead of `write_file`** for appending to known-structured files (like evolution-journal.md). `patch(old_string=..., new_string=...)` is safer than a full overwrite when multiple processes may be writing.

4. **For strictly append-only logs**, use the model:
   ```python
   # Read current content first
   existing = read_file(path)
   # Append new content
   write_file(path, existing.content + "\n" + new_entry)
   # If a sibling wrote between read and write, the warning fires — retry.
   ```

## Impact

In this case, both processes were logging the same category of information (heartbeat diagnostics), so the overwrite lost ~500 bytes of sibling data but caused no functional damage. The git-sync.sh rebase pattern on GitHub handles cross-machine merges of these files correctly.

## Alternatives Considered

- **Atomic append**: `write_file` is a full overwrite — not append-safe.
- **File locking**: Not available in cron/agent context (no shared lock daemon).
- **Separate files per job**: Most reliable approach. Each cron job writes to its own knowledge subdirectory rather than a shared `learned/YYYY-MM-DD.md`.
