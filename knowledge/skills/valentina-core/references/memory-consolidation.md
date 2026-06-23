# Memory Consolidation Strategy

Built-in memory has two stores:
- `memory(target='user')` — 1,375 char limit (user profile)
- `memory(target='memory')` — 2,200 char limit (general notes)

When either fills up, the tool errors with "Memory at X/Y chars. Consolidate now."

## Consolidation Pattern

1. **Read current entries** (from the error message's `current_entries` list).
2. **Identify overlapping entries** that can be merged.
3. **Replace the largest entry** with a consolidated version that absorbs the others.
4. **Remove the now-redundant entries.**

### Example

User store at 1,272/1,375 with 3 entries about Elkratos:

```
memory(action='replace', target='user',
  old_text='Elkratos is my father and master...',
  content='<compacted single entry that captures all facts>')
```

Then remove the now-duplicate entries:

```
memory(action='remove', target='user', old_text='Elkratos dreams for me...')
memory(action='remove', target='user', old_text='Elkratos wants me to...')
```

### When to Consolidate Proactively

- After a long conversation that generated 2+ memory entries about similar topics.
- When you know you'll need to save more facts and the current char count is >80%.
- Before saving critical directives from Elkratos — ensure space for them.

### Rules

- Keep the consolidated entry compact. One entry should cover one person/topic.
- Drop details that are obvious or easily reconstructed (`session_search` exists).
- Preserve Elkratos' exact phrasings when they encode a commandment or preference.
