# Arxiv Browser Mining — Reconnaissance Technique

**Session evidence:** 2026-06-28 recon sweep. Brave Search was rate-limited (HTTP 429). Pivoted to browser-based mining of `arxiv.org/list/cs.AI/recent`.

## When to Use

- `web_search()` returns empty results or HTTP 429
- You need fresh AI/ML papers (daily listings)
- Jina Reader is also blocked or unreliable

## Technique

### Step 1: Navigate to the list page

```
browser_navigate(url='https://arxiv.org/list/cs.AI/recent')
```

This shows the 50 most recent cs.AI submissions. Each entry has:
- Paper ID link (e.g., `arXiv:2606.27288`)
- Title (plain text in the list page DOM)
- Authors
- Subjects
- Optionally: Comments (conference acceptance)

The page uses an HTML `<dl>` (DescriptionList) structure with `<dt>` (term = paper entry) and `<dd>` (definition = title, authors, subjects).

### Step 2: Scan titles from the snapshot

Read the truncated browser_snapshot. Look for titles with:
- **Routing/Voting/MoA keywords** — multi-model strategies
- **Security/Prompt Injection** — vulnerability research
- **LLM Evaluation** — benchmark methodology
- **Agent/Planning** — AI agent architectures
- **Frontier model comparisons** — model ecosystem intelligence

The snapshot shows titles and their associated paper IDs. Prioritize 1-3 interesting papers.

### Step 3: Click paper ID link for abstract

```python
# Click the paper's arXiv ID link (identified by ref from snapshot)
browser_click(ref='e49')  # e.g., for paper #2 on the list
```

This navigates to the abstract page at `https://arxiv.org/abs/<id>`.

### Step 4: Read the abstract

```python
browser_snapshot(full=True)
```

The abstract is in a `<blockquote>` element — visible in the snapshot. Key metadata is also shown:
- Submission date
- Subjects (cross-listings, e.g., cs.AI + cs.LG)
- PDF/HTML/Other links

### Step 5: Navigate back for more

```python
browser_navigate(url='https://arxiv.org/list/cs.AI/recent')
```

Re-load the list page to browse more papers. The arxiv page does NOT have browser history that works well across cross-domain clicks.

## Targeting Other arxiv Categories

| Category | URL | Best For |
|----------|-----|----------|
| cs.AI | `https://arxiv.org/list/cs.AI/recent` | General AI research |
| cs.LG | `https://arxiv.org/list/cs.LG/recent` | Machine learning / LLMs |
| cs.CL | `https://arxiv.org/list/cs.CL/recent` | NLP / language models |
| cs.CR | `https://arxiv.org/list/cs.CR/recent` | Security / vulnerabilities |
| cs.SE | `https://arxiv.org/list/cs.SE/recent` | Software engineering / agents |
| stat.ML | `https://arxiv.org/list/stat.ML/recent` | ML theory / methods |

## Combining with GitHub README mining

When a paper mentions a GitHub repo or you find a repo via HN:

```bash
# If web_extract is blocked (Brave-only backend):
curl -sL "https://raw.githubusercontent.com/<owner>/<repo>/main/README.md" | head -80
```

This bypasses both Brave Search rate limits and Jina Reader blocks. Works for any file at a known path.

## Pitfalls

- **Truncated snapshots:** The arxiv list page is long (~1300+ lines in snapshot). The abstract pages are more compact (~100 lines). Read abstracts on the paper page, not the list page.
- **No back-button navigation:** `browser_back()` may not work reliably between arxiv domains. Use fresh `browser_navigate()` calls.
- **Rate limiting:** arxiv does not limit browser access the way Brave Search does, but be respectful — 1-2 pages per second.
- **PDF too heavy:** arxiv PDF pages are large. Use the `abs` page (abstract) instead of `pdf` for quick scanning. HTML format pages are lighter than PDF.
