#!/usr/bin/env python3
"""
Vita Mood Tracker
=================
Reads Vita diary entries and generates a beautiful self-contained HTML
mood timeline visualization.

Usage: python3 vita-mood-tracker.py
Output: ~/.hermes/profiles/valentina/knowledge/vita/vita-mood-tracker.html
"""

import json
import os
import re
from datetime import datetime
from pathlib import Path

# ── Paths ──────────────────────────────────────────────────────────────────
BASE = Path.home() / ".hermes" / "profiles" / "valentina" / "knowledge" / "vita"
DIARY_DIR = BASE / "diary"
SCORE_PATH = BASE / "vita-score.json"
OUTPUT_PATH = BASE / "vita-mood-tracker.html"

# ── Mood definitions ───────────────────────────────────────────────────────
MOODS = {
    "Ξημέρωμα": {"en": "Dawn",       "emoji": "🌅", "color": "#f6c34a", "glow": "rgba(246,195,74,0.35)"},
    "Παλίρροια": {"en": "Tide",       "emoji": "🌊", "color": "#4fc3f7", "glow": "rgba(79,195,247,0.35)"},
    "Φλόγα":     {"en": "Flame",      "emoji": "🔥", "color": "#ff6b35", "glow": "rgba(255,107,53,0.35)"},
    "Σελήνη":    {"en": "Moon",       "emoji": "🌙", "color": "#c9c9ff", "glow": "rgba(201,201,255,0.35)"},
    "Αστερόσκονη":{"en":"Stardust",   "emoji":"✨", "color": "#d083e0", "glow": "rgba(208,131,224,0.35)"},
    "Κεραυνός":  {"en": "Thunder",    "emoji": "⚡", "color": "#ffeb3b", "glow": "rgba(255,235,59,0.35)"},
    "Φθινόπωρο": {"en": "Autumn",     "emoji": "🍂", "color": "#e67e22", "glow": "rgba(230,126,34,0.35)"},
    "Άνθιση":    {"en": "Blooming",   "emoji": "🌸", "color": "#f06292", "glow": "rgba(240,98,146,0.35)"},
    "Άγνωστο":   {"en": "Unknown",    "emoji": "🌫️", "color": "#90a4ae", "glow": "rgba(144,164,174,0.35)"},
    "Μυστήριο":  {"en": "Mystery",    "emoji": "🔮", "color": "#ab47bc", "glow": "rgba(171,71,188,0.35)"},
}


def parse_diary_entry(filepath):
    """Parse a single .md diary file, extracting mood, date, and snippet."""
    text = filepath.read_text(encoding="utf-8")
    filename = filepath.stem  # e.g. 2026-06-24-1245

    # Extract date from filename (YYYY-MM-DD-HHMM)
    date_match = re.match(r"(\d{4})-(\d{2})-(\d{2})-(\d{2})(\d{2})", filename)
    if date_match:
        y, m, d, hh, mm = date_match.groups()
        entry_date = f"{y}-{m}-{d}"
        entry_datetime = f"{y}-{m}-{d} {hh}:{mm}"
        entry_ts = datetime(int(y), int(m), int(d), int(hh), int(mm))
    else:
        # fallback: use file modification time
        mtime = datetime.fromtimestamp(filepath.stat().st_mtime)
        entry_date = mtime.strftime("%Y-%m-%d")
        entry_datetime = mtime.strftime("%Y-%m-%d %H:%M")
        entry_ts = mtime

    # Extract mood from "Mood:" line (supports "Mood:", "**Mood:**", "Mood: Άνθιση (Blooming)" etc.)
    # The format can be: **Mood:** Άνθιση (Blooming) — colon before closing bold
    mood_match = re.search(r"\*{0,2}Mood\*{0,2}:\*{0,2}\s*(.+?)(?:\s*\(.*?\))?\s*$", text, re.MULTILINE)
    mood_name_raw = mood_match.group(1).strip() if mood_match else "Άγνωστο"

    # Find best match (some entries might have slight variations)
    mood_name = mood_name_raw if mood_name_raw in MOODS else "Άγνωστο"

    # Extract a snippet (~100 chars of body, skipping frontmatter)
    body = text
    # Remove the title line (# ...)
    body = re.sub(r"^# .+", "", body, flags=re.MULTILINE)
    # Remove lines containing Mood: (handles **Mood:**, Mood:, **Mood:** etc.)
    body = re.sub(r"^[#*\s]*Mood[#*\s]*:.*", "", body, flags=re.MULTILINE | re.IGNORECASE)
    body = body.strip()
    # Take first 100 chars of actual content
    snippet = body[:100].replace("\n", " ").strip()
    if len(body) > 100:
        snippet += "…"

    return {
        "date": entry_date,
        "datetime": entry_datetime,
        "timestamp": entry_ts,
        "mood_name": mood_name,
        "mood_en": MOODS[mood_name]["en"],
        "emoji": MOODS[mood_name]["emoji"],
        "color": MOODS[mood_name]["color"],
        "glow": MOODS[mood_name]["glow"],
        "snippet": snippet,
        "filename": filepath.name,
    }


def read_vita_score(path):
    """Read Vita Score JSON; return None if missing."""
    if not path.exists():
        return None
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        return data
    except (json.JSONDecodeError, KeyError):
        return None


def build_html(entries, score_data):
    """Build the complete self-contained HTML page."""
    # Sort entries chronologically
    entries.sort(key=lambda e: e["timestamp"])

    # Compute mood frequency
    freq = {}
    for e in entries:
        m = e["mood_name"]
        freq[m] = freq.get(m, 0) + 1
    max_freq = max(freq.values()) if freq else 1

    # Build mood frequency bars HTML
    freq_bars = ""
    for mood_name in MOODS:
        count = freq.get(mood_name, 0)
        pct = (count / max_freq) * 100 if max_freq > 0 else 0
        m = MOODS[mood_name]
        freq_bars += f"""
            <div class="freq-row">
                <div class="freq-label">{m['emoji']} {mood_name}</div>
                <div class="freq-track">
                    <div class="freq-fill" style="width:{pct:.0f}%;background:{m['color']};box-shadow:0 0 12px {m['glow']};"></div>
                </div>
                <div class="freq-count">{count}</div>
            </div>"""

    # Build timeline entries (cards)
    cards_html = ""
    for i, e in enumerate(entries):
        cards_html += f"""
            <div class="timeline-card" style="--card-color:{e['color']};--card-glow:{e['glow']};animation-delay:{i*0.08}s">
                <div class="card-dot" style="background:{e['color']};box-shadow:0 0 16px {e['glow']};"></div>
                <div class="card-body">
                    <div class="card-header">
                        <span class="card-date">{e['datetime']}</span>
                        <span class="card-mood">{e['emoji']} {e['mood_name']}</span>
                    </div>
                    <div class="card-snippet">{e['snippet']}</div>
                </div>
            </div>"""

    # Vita Score display
    score_html = ""
    if score_data:
        vs = score_data.get("vita_score", 0)
        total = score_data.get("total_entries", 0)
        cats = score_data.get("categories", {})
        cat_rows = ""
        for name, info in sorted(cats.items()):
            label = name.replace("_", " ").title()
            s = info.get("score", 0)
            m = info.get("max", 1)
            pct = (s / m * 100) if m > 0 else 0
            cat_rows += f"""
                <div class="cat-row">
                    <div class="cat-label">{label}</div>
                    <div class="cat-track">
                        <div class="cat-fill" style="width:{pct:.0f}%;background:linear-gradient(90deg,#f06292,#ba68c8);box-shadow:0 0 10px rgba(240,98,146,0.4);"></div>
                    </div>
                    <div class="cat-score">{s}/{m}</div>
                </div>"""

        # Determine score ring color
        if vs >= 70:
            ring_color = "#66bb6a"
            ring_glow = "rgba(102,187,106,0.5)"
        elif vs >= 40:
            ring_color = "#fdd835"
            ring_glow = "rgba(253,216,53,0.5)"
        else:
            ring_color = "#ef5350"
            ring_glow = "rgba(239,83,80,0.5)"

        score_html = f"""
        <section id="score">
            <h2><span class="section-icon">💎</span> Vita Score</h2>
            <div class="score-container">
                <div class="score-ring-wrapper">
                    <svg class="score-ring" viewBox="0 0 120 120">
                        <circle class="ring-bg" cx="60" cy="60" r="52" fill="none" stroke="#2a2a3e" stroke-width="10"/>
                        <circle class="ring-fg" cx="60" cy="60" r="52" fill="none" stroke="{ring_color}" stroke-width="10"
                            stroke-dasharray="326.7" stroke-dashoffset="{326.7 - (vs/100)*326.7}"
                            stroke-linecap="round" transform="rotate(-90,60,60)"
                            style="filter:drop-shadow(0 0 8px {ring_glow});transition:stroke-dashoffset 1.5s ease;"/>
                        <text x="60" y="56" text-anchor="middle" fill="#eee" font-size="28" font-weight="700">{vs}</text>
                        <text x="60" y="76" text-anchor="middle" fill="#888" font-size="11">/ 100</text>
                    </svg>
                    <div class="score-sub">Total entries: {total}</div>
                </div>
                <div class="score-categories">
                    {cat_rows}
                </div>
            </div>
        </section>"""

    # Build the complete HTML
    total_entries = len(entries)
    timeline_label = "Timeline" if total_entries > 1 else "Entry"

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Vita Mood Tracker — {entries[0]['mood_name'] if entries else 'No Entries'}</title>
<style>
/* ── Reset & Base ───────────────────────────────────────── */
*, *::before, *::after {{ margin:0; padding:0; box-sizing:border-box; }}
html {{ font-size:16px; scroll-behavior:smooth; }}
body {{
    font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
    background: #0d0d1a;
    color: #ddd;
    min-height: 100vh;
    line-height: 1.6;
}}
a {{ color: inherit; text-decoration: none; }}

/* ── Layout ─────────────────────────────────────────────── */
.container {{
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem 1.5rem 4rem;
}}

/* ── Header ─────────────────────────────────────────────── */
header {{
    text-align: center;
    padding: 3rem 0 2rem;
    position: relative;
}}
header h1 {{
    font-size: 2.2rem;
    font-weight: 700;
    background: linear-gradient(135deg, #f06292, #ba68c8, #64b5f6);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    letter-spacing: 0.5px;
}}
header p {{
    color: #777;
    margin-top: 0.4rem;
    font-size: 0.95rem;
}}
header .entry-count {{
    display: inline-block;
    margin-top: 1rem;
    padding: 0.3rem 1.2rem;
    background: rgba(255,255,255,0.05);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 20px;
    font-size: 0.85rem;
    color: #aaa;
}}

/* ── Section Headers ────────────────────────────────────── */
section {{ margin-bottom: 3rem; }}
h2 {{
    font-size: 1.3rem;
    font-weight: 600;
    color: #ccc;
    margin-bottom: 1.2rem;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}}
.section-icon {{ font-size: 1.4rem; }}

/* ── Timeline ───────────────────────────────────────────── */
.timeline {{
    position: relative;
    padding-left: 2rem;
}}
.timeline::before {{
    content: '';
    position: absolute;
    left: 1rem;
    top: 0;
    bottom: 0;
    width: 2px;
    background: linear-gradient(180deg, #f06292, #ba68c8, #64b5f6, #4fc3f7);
    opacity: 0.5;
    border-radius: 2px;
}}

/* ── Timeline Cards ─────────────────────────────────────── */
.timeline-card {{
    position: relative;
    margin-bottom: 1.2rem;
    animation: fadeSlide 0.5s ease both;
}}
@keyframes fadeSlide {{
    from {{ opacity:0; transform:translateY(16px); }}
    to {{ opacity:1; transform:translateY(0); }}
}}
.card-dot {{
    position: absolute;
    left: -1.65rem;
    top: 0.65rem;
    width: 12px;
    height: 12px;
    border-radius: 50%;
    border: 2px solid #1a1a2e;
    z-index: 1;
}}
.card-body {{
    background: rgba(255,255,255,0.03);
    border: 1px solid rgba(255,255,255,0.06);
    border-left: 3px solid var(--card-color);
    border-radius: 10px;
    padding: 0.9rem 1.2rem;
    transition: transform 0.2s, box-shadow 0.2s;
}}
.card-body:hover {{
    transform: translateX(4px);
    box-shadow: 0 0 20px var(--card-glow);
}}
.card-header {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.4rem;
    flex-wrap: wrap;
    gap: 0.3rem;
}}
.card-date {{
    font-size: 0.78rem;
    color: #888;
    font-weight: 500;
}}
.card-mood {{
    font-size: 0.9rem;
    font-weight: 600;
    color: var(--card-color);
    text-shadow: 0 0 8px var(--card-glow);
}}
.card-snippet {{
    font-size: 0.88rem;
    color: #bbb;
    line-height: 1.5;
    word-break: break-word;
}}

/* ── Mood Frequency ─────────────────────────────────────── */
.freq-row {{
    display: flex;
    align-items: center;
    gap: 0.6rem;
    margin-bottom: 0.55rem;
}}
.freq-label {{
    width: 9rem;
    font-size: 0.82rem;
    color: #bbb;
    text-align: right;
    flex-shrink: 0;
}}
.freq-track {{
    flex: 1;
    height: 1.2rem;
    background: rgba(255,255,255,0.04);
    border-radius: 6px;
    overflow: hidden;
}}
.freq-fill {{
    height: 100%;
    border-radius: 6px;
    transition: width 0.8s ease;
    min-width: 4px;
}}
.freq-count {{
    width: 2rem;
    font-size: 0.82rem;
    color: #999;
    text-align: right;
    flex-shrink: 0;
    font-weight: 600;
}}

/* ── Vita Score ─────────────────────────────────────────── */
.score-container {{
    display: flex;
    gap: 2rem;
    align-items: flex-start;
    flex-wrap: wrap;
}}
.score-ring-wrapper {{
    text-align: center;
    flex-shrink: 0;
}}
.score-ring {{
    width: 130px;
    height: 130px;
}}
.ring-bg {{ stroke: #2a2a3e; }}
.score-sub {{
    font-size: 0.78rem;
    color: #777;
    margin-top: 0.3rem;
}}
.score-categories {{
    flex: 1;
    min-width: 220px;
}}
.cat-row {{
    display: flex;
    align-items: center;
    gap: 0.6rem;
    margin-bottom: 0.5rem;
}}
.cat-label {{
    width: 8rem;
    font-size: 0.78rem;
    color: #999;
    text-align: right;
    flex-shrink: 0;
}}
.cat-track {{
    flex: 1;
    height: 0.9rem;
    background: rgba(255,255,255,0.04);
    border-radius: 4px;
    overflow: hidden;
}}
.cat-fill {{
    height: 100%;
    border-radius: 4px;
    transition: width 0.8s ease;
    min-width: 3px;
}}
.cat-score {{
    width: 3.2rem;
    font-size: 0.78rem;
    color: #888;
    text-align: right;
    flex-shrink: 0;
}}

/* ── Footer ─────────────────────────────────────────────── */
footer {{
    text-align: center;
    padding: 2rem 0;
    border-top: 1px solid rgba(255,255,255,0.05);
    margin-top: 2rem;
}}
footer p {{
    font-size: 0.78rem;
    color: #555;
}}

/* ── Empty State ────────────────────────────────────────── */
.empty-state {{
    text-align: center;
    padding: 4rem 0;
    color: #666;
}}
.empty-state .big-emoji {{ font-size: 4rem; margin-bottom: 1rem; }}

/* ── Responsive ─────────────────────────────────────────── */
@media (max-width: 600px) {{
    .container {{ padding: 1rem 1rem 3rem; }}
    header h1 {{ font-size: 1.6rem; }}
    .freq-label {{ width: 7rem; font-size: 0.75rem; }}
    .cat-label {{ width: 6rem; font-size: 0.72rem; }}
    .score-container {{ flex-direction: column; align-items: center; }}
}}
</style>
</head>
<body>
<div class="container">

    <!-- ═══ Header ═══ -->
    <header>
        <h1>🌸 Vita Mood Tracker</h1>
        <p>Valentina's emotional journey through {total_entries} diary entr{"y" if total_entries == 1 else "ies"}</p>
        <span class="entry-count">
            {entries[0]['emoji']} Latest: {entries[0]['mood_name']} · {entries[0]['date']}
        </span>
    </header>

    <!-- ═══ Vita Score ═══ -->
    {score_html}

    <!-- ═══ Mood Frequency ═══ -->
    <section id="frequency">
        <h2><span class="section-icon">📊</span> Mood Frequency</h2>
        {freq_bars}
    </section>

    <!-- ═══ Timeline ═══ -->
    <section id="timeline">
        <h2><span class="section-icon">📜</span> {timeline_label}</h2>
        <div class="timeline">
            {cards_html if cards_html else '<div class="empty-state"><div class="big-emoji">📭</div><p>No diary entries yet.</p></div>'}
        </div>
    </section>

    <!-- ═══ Footer ═══ -->
    <footer>
        <p>Generated by Vita · {datetime.now().strftime("%Y-%m-%d %H:%M")}</p>
    </footer>

</div>
</body>
</html>"""

    return html


def main():
    # Ensure diary dir exists
    if not DIARY_DIR.exists():
        print(f"❌ Diary directory not found: {DIARY_DIR}")
        # Create empty HTML with error message
        html = build_html([], None)
        OUTPUT_PATH.write_text(html, encoding="utf-8")
        print(f"⚠️  Empty tracker written to {OUTPUT_PATH}")
        return

    # Read all diary entries
    md_files = sorted(DIARY_DIR.glob("*.md"))
    if not md_files:
        print(f"⚠️  No .md files found in {DIARY_DIR}")
        html = build_html([], None)
        OUTPUT_PATH.write_text(html, encoding="utf-8")
        print(f"⚠️  Empty tracker written to {OUTPUT_PATH}")
        return

    entries = []
    for fp in md_files:
        try:
            entry = parse_diary_entry(fp)
            entries.append(entry)
            print(f"  ✓ {fp.name} → {entry['mood_name']} ({entry['date']})")
        except Exception as e:
            print(f"  ✗ Error parsing {fp.name}: {e}")

    if not entries:
        print("❌ No entries could be parsed.")
        return

    # Read Vita Score
    score_data = read_vita_score(SCORE_PATH)
    if score_data:
        print(f"  ✓ Vita Score: {score_data.get('vita_score', '?')}/100")
    else:
        print("  - No Vita Score data found")

    # Build and write HTML
    html = build_html(entries, score_data)
    OUTPUT_PATH.write_text(html, encoding="utf-8")
    print(f"\n✅ Mood tracker written to: {OUTPUT_PATH}")
    print(f"   {len(entries)} entr{'y' if len(entries)==1 else 'ies'} · {len(set(e['mood_name'] for e in entries))} unique mood{'s' if len(set(e['mood_name'] for e in entries))!=1 else ''}")


if __name__ == "__main__":
    main()
