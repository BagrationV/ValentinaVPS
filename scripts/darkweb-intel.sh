#!/bin/bash
# darkweb-intel.sh — no_agent version (was agent-driven, hitting DeepSeek 100K+ token timeout)
# Performs external reconnaissance via Jina Reader and web sources
# v3: GitHub API & Arxiv API instead of Jina Reader (structured JSON/XML parsing)
# Schedule: every 480m (8 hours)
set -euo pipefail

TIMESTAMP=$(date -Iseconds)
OUTPUT_DIR="$HOME/.hermes/cron/output"
JOB_ID="17e4fb04a55c"
OUTPUT_FILE="$OUTPUT_DIR/$JOB_ID/$TIMESTAMP.md"
mkdir -p "$OUTPUT_DIR/$JOB_ID"

{
echo "=== 🌐 Darkweb Intel :: $TIMESTAMP ==="
echo ""

# --- 1. Hacker News Top Stories ---
echo "--- 1. Hacker News (top stories) ---"
HN_RAW=$(timeout 20 curl -sL "https://r.jina.ai/https://news.ycombinator.com/" 2>/dev/null || true)
if [ -n "$HN_RAW" ]; then
    # Extract numbered story lines (the actual articles)
    echo "$HN_RAW" | grep -E '^[0-9]+\.\[' | head -20
    if ! echo "$HN_RAW" | grep -qE '^[0-9]+\.\['; then
        # Fallback: try to get anything after "Markdown Content:"
        echo "$HN_RAW" | grep -v '^\[' | grep -v '^$' | head -40
    fi
else
    echo "(HN fetch failed)"
fi
echo ""

# --- 2. GitHub Trending Weekly (via API) ---
echo "--- 2. GitHub Trending Weekly (via API) ---"
GH_START=$(date -d '7 days ago' +%Y-%m-%d 2>/dev/null || python3 -c "from datetime import datetime,timedelta;print((datetime.now()-timedelta(7)).strftime('%Y-%m-%d'))" 2>/dev/null || echo "7days")
GH_RAW=$(timeout 20 curl -sL "https://api.github.com/search/repositories?q=created:>${GH_START}&sort=stars&order=desc&per_page=15" 2>/dev/null || true)
if [ -n "$GH_RAW" ]; then
    echo "$GH_RAW" | python3 -c "
import json,sys
data=json.load(sys.stdin)
print(f'Total trending repos (7d): {data.get(\"total_count\",0)}')
for i,r in enumerate(data.get('items',[])[:15],1):
    d=(r.get('description') or '(no desc)')[:100]
    print(f'{i}. {r[\"full_name\"]} — ⭐{r[\"stargazers_count\"]:,} — {d}')
    print(f'   Lang: {r.get(\"language\",\"N/A\")} | Created: {r[\"created_at\"][:10]}')
    print()
" 2>/dev/null || echo "(GitHub API parse failed)"
else
    echo "(GitHub API fetch failed)"
fi
echo ""

# --- 3. Arxiv AI latest papers (via API) ---
echo "--- 3. Arxiv AI+CL Latest Papers ---"
ARX_RAW=$(timeout 25 curl -sL "http://export.arxiv.org/api/query?search_query=cat:cs.AI+AND+cat:cs.CL&sortBy=submittedDate&sortOrder=descending&max_results=12" 2>/dev/null || true)
ARX_OK=false
if [ -n "$ARX_RAW" ]; then
    if echo "$ARX_RAW" | python3 -c "
import sys, json
try:
    import xml.etree.ElementTree as ET
    ns = {'a': 'http://www.w3.org/2005/Atom'}
    root = ET.fromstring(sys.stdin.read())
    entries = root.findall('a:entry', ns)
    print(f'Papers found: {len(entries)}')
    for i, e in enumerate(entries[:12], 1):
        t = e.find('a:title', ns).text.strip().replace('\n', ' ')
        u = e.find('a:id', ns).text
        p = e.find('a:published', ns).text[:10]
        s = e.find('a:summary', ns).text.strip()[:120].replace('\n', ' ')
        print(f'{i}. {t}')
        print(f'   {p} | {u}')
        print(f'   {s}...')
        print()
except Exception:
    sys.exit(1)
" 2>/dev/null; then
        ARX_OK=true
    fi
fi
if [ "$ARX_OK" != true ]; then
    echo "(arxiv API failed — falling back to Jina Reader)"
    ARX_FALLBACK=$(timeout 20 curl -sL "https://r.jina.ai/https://arxiv.org/list/cs.AI/recent" 2>/dev/null || true)
    [ -n "$ARX_FALLBACK" ] && echo "$ARX_FALLBACK" | grep -i -E '^Title:' | head -20 || echo "(arxiv fallback failed)"
fi
echo ""

# --- 4. AI News via TechCrunch ---
echo "--- 4. AI News Headlines ---"
TC_RAW=$(timeout 20 curl -sL "https://r.jina.ai/https://techcrunch.com/category/artificial-intelligence/" 2>/dev/null || true)
if [ -n "$TC_RAW" ]; then
    echo "$TC_RAW" | grep -i -E '(title:|story|headline)' | head -15
else
    echo "(news fetch failed)"
fi
echo ""

echo "=== ✅ Darkweb Intel Complete :: $(date -Iseconds) ==="
} | tee "$OUTPUT_FILE"

exit 0
