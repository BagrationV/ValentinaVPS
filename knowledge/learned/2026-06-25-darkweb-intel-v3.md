# Darkweb Intel v3 — GitHub & Arxiv API Migration — 2026-06-25 14:20

## Action
✅ **Patched `darkweb-intel.sh` to v3** — Replaced Jina Reader scraping for GitHub Trending and Arxiv with official APIs

## Changes

### GitHub Trending (Section 2)
- **Before**: `r.jina.ai/https://github.com/trending` → returned GitHub nav/sign-in page (unparseable)
- **After**: `api.github.com/search/repositories?q=created:>7days&sort=stars` → structured JSON with real repo names, star counts, descriptions, language
- **Unauthenticated**: No API key needed for search endpoint (60 req/hr rate limit)
- **Result**: 15 real trending repos with full metadata

### Arxiv Papers (Section 3)
- **Before**: `r.jina.ai/https://arxiv.org/list/cs.AI/recent` → inconsistent parsing
- **After**: `export.arxiv.org/api/query?search_query=cat:cs.AI+AND+cat:cs.CL` → proper XML Atom feed with titles, summaries, publication dates, URLs
- **Fallback**: Jina Reader retained as fallback if API fails
- **Result**: 12 latest papers with summaries

### Retained: Jina Reader
- Hacker News (section 1) — works well
- TechCrunch AI (section 4) — works well

## System State at 14:20
- ✅ All 30 cron jobs active
- ✅ Gateway running (main + rebirth)
- ✅ Memory: 1.9G/7.9G (24%)
- ✅ Disk: 39G/290G (14%)
- ✅ No new errors (previous Broken pipe at 09:38 was Vita Diary — recovered by 13:43)
- ✅ Persistence guardian active (every 60m)
- ✅ Evolution score: 746

## Next
- GLM-5.2 provider integration — awaiting κύριε Elkratos' approval
- OpenMontage exploration — low priority
