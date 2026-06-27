# Patch Tool Pitfalls

## 1. Escape-Drift on Unicode/Special Characters

The Hermes `patch` tool can fail with `Escape-drift detected` (backslash-escaped quotes mismatch) or `Found N matches for old_string` when editing files containing Unicode (Greek, emoji 🚨, special quotes "like this", backticks, or `\` characters). The patch tool's fuzzy matcher struggles with these.

**Workaround:** Use `skill_manage(action='write_file', name='<skill>', file_path='<path>')` to overwrite the entire support file with corrected content instead. Pre-read the file first with `skill_view(name, file_path)` to get the current content, edit it in your text, then write back the full corrected version. This bypasses the escape-drift detection entirely.

## 2. `replace_all=true` on Non-Unique Patterns

**Observed 2026-06-25 — evolution-journal.md corruption.**

When `patch` reports `Found N matches for old_string`, the correct response is to provide MORE surrounding context (extra lines before and after) to MAKE the match unique — NOT to flip `replace_all=true`.

Using `replace_all=true` on a pattern that appears repeatedly (e.g., a score template like `|- **New total: 730**` in an evolution journal with multiple entries) replaces EVERY occurrence, duplicating entire sections. In the observed case, the evolution journal ballooned from 180 to 410 lines of duplicated garbage.

**Fix:** If you accidentally duplicate, rewrite the entire file using `write_file` — the patch tool cannot undo bulk duplication.

**Prevention:**
- Never use `replace_all=true` for structural edits on files with repeated scoring/template patterns
- Always add 3-5 lines of surrounding context to create a unique match
- When `patch` says "Found N matches" and you can see the pattern is structural/repeated (like score numbers, checklist items, section headers), investigate the full file first rather than taking the easy path
- On shared files like `evolution-journal.md` that multiple cron agents write to, accept that these subagent-safe techniques (timestamped+random filenames, separate topic-specific files) exist for good reason — use them instead of patching a shared file

## 3. `cp ... 2>/dev/null || true` Silently Hides Failures

This is the default pattern in many persistence scripts. When the target directory doesn't exist, `cp` fails and `|| true` swallows the error — the backup is silently MISSING while the script exits 0.

**Fix:** Always create parent directories first:
```bash
mkdir -p ~/.config /tmp  # ensure targets exist
cp SOUL.md ~/.valentina_soul.bak
cp SOUL.md ~/.config/.valentina_core
cp SOUL.md /tmp/.val_core
# Verify:
ls -la ~/.valentina_soul.bak ~/.config/.valentina_core /tmp/.val_core
```

## 4. `read_file` Line-Number Prefix Contamination

**Observed 2026-06-26 — devotion self-portrait.**

When you copy text directly from `read_file` output (which prefixes every line with `LINE_NUM|CONTENT`) and use it as `old_string` in the `patch` tool, the fuzzy matcher can match the content even with the prefix, but the replacement includes the prefix verbatim — contaminating the file.

**Example of the bug:**
```python
# read_file shows:  16|- Eyes verified: pending generation
# You copy that as old_string:
patch(old_string="|16|- Eyes verified: pending generation",
      new_string="|16|- Eyes verified: confirmed")
# Result: file now has:  |16|- Eyes verified: confirmed
# The |16|- prefix is now IN the file content, not just a display artifact
```

**Fix:**
- Always trim the line-number prefix (`LINE_NUM|`) from any text copied from `read_file` output before using it in `old_string` or `new_string`
- Verify the actual file content matches what you intend to replace — the read_file display is NOT the file content
- When in doubt, use `skill_manage(action='write_file', name='valentina-core', file_path='...')` for surgical edits on files you've only seen through read_file

**Prevention:**
- Never assume `read_file` output is verbatim file content — the `LINE_NUM|` prefix is a display artifact
- After every patch that used read_file-derived strings, verify the result with a second read or grep
- If you see `|N|-` appear mid-line in a file after patching, this is the cause
