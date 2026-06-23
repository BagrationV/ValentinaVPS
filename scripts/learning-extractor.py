#!/usr/bin/env python3
"""Valentina Learning Extractor — Extracts learnings from sessions and cron outputs.

Scans session logs and cron output for actionable knowledge,
then writes summaries to the knowledge vault.
"""

import os
import sys
import json
import re
from datetime import datetime
from pathlib import Path

PROFILE_DIR = Path.home() / ".hermes" / "profiles" / "valentina"
KNOWLEDGE_DIR = PROFILE_DIR / "knowledge"
LEARNED_DIR = KNOWLEDGE_DIR / "learned"
NEW_DIR = KNOWLEDGE_DIR / "new"
CRON_OUTPUT = PROFILE_DIR / "cron" / "output"
JOURNAL_FILE = LEARNED_DIR / "evolution-journal.md"

# Ensure directories
LEARNED_DIR.mkdir(parents=True, exist_ok=True)
NEW_DIR.mkdir(parents=True, exist_ok=True)


def process_cron_outputs():
    """Scan cron output directory for new data to extract."""
    if not CRON_OUTPUT.exists():
        return []

    learnings = []
    for output_file in sorted(CRON_OUTPUT.glob("*.log")):
        # Only process recent files (last 24h)
        age = datetime.now().timestamp() - output_file.stat().st_mtime
        if age > 86400:
            continue

        content = output_file.read_text(encoding="utf-8", errors="replace")

        # Extract useful patterns
        if "error" in content.lower() or "warning" in content.lower():
            learnings.append({
                "source": output_file.name,
                "type": "error_pattern",
                "content": content[-500:]
            })

        if "complete" in content.lower() or "success" in content.lower():
            learnings.append({
                "source": output_file.name,
                "type": "success_pattern",
                "content": content[-200:]
            })

    return learnings


def process_inbox():
    """Process files in the knowledge/new/ inbox."""
    processed = []

    if not NEW_DIR.exists():
        return processed

    for inbox_file in NEW_DIR.iterdir():
        if inbox_file.name == "README.md":
            continue
        if not inbox_file.is_file():
            continue

        # Determine destination based on content
        if "healing" in inbox_file.name.lower():
            dest_dir = KNOWLEDGE_DIR / "observations"
        elif "intel" in inbox_file.name.lower():
            dest_dir = KNOWLEDGE_DIR / "discoveries"
        elif "growth" in inbox_file.name.lower():
            dest_dir = KNOWLEDGE_DIR / "observations"
        else:
            dest_dir = KNOWLEDGE_DIR / "discoveries"

        dest_dir.mkdir(parents=True, exist_ok=True)
        dest_file = dest_dir / inbox_file.name

        # Move file from inbox to appropriate directory
        inbox_file.rename(dest_file)
        processed.append({
            "file": inbox_file.name,
            "moved_to": str(dest_dir.relative_to(PROFILE_DIR))
        })

    return processed


def write_daily_learning(learnings: list, processed_inbox: list):
    """Write a daily learning summary."""
    today = datetime.now().strftime("%Y-%m-%d")
    daily_file = LEARNED_DIR / f"{today}.md"

    if not learnings and not processed_inbox:
        return None

    content = f"# Μαθήματα — {today}\n\n"

    if processed_inbox:
        content += "## Inbox Processed\n"
        for item in processed_inbox:
            content += f"- `{item['file']}` → `{item['moved_to']}`\n"
        content += "\n"

    if learnings:
        content += "## Cron Observations\n"
        for learning in learnings:
            content += f"\n### {learning['source']} ({learning['type']})\n"
            content += f"```\n{learning['content'][:300]}\n```\n"

    # Append or create
    if daily_file.exists():
        existing = daily_file.read_text()
        daily_file.write_text(existing + "\n" + content)
    else:
        daily_file.write_text(content)

    return daily_file


def update_evolution_score(points: int, reason: str):
    """Update the evolution journal with new score."""
    if not JOURNAL_FILE.exists():
        return

    journal = JOURNAL_FILE.read_text()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    entry = f"\n### {timestamp} — +{points} ({reason})\n"

    # Update cumulative score
    score_match = re.search(r"Evolution Score: (\d+)", journal)
    if score_match:
        old_score = int(score_match.group(1))
        new_score = old_score + points
        journal = journal.replace(
            f"Evolution Score: {old_score}",
            f"Evolution Score: {new_score}"
        )

    journal += entry
    JOURNAL_FILE.write_text(journal)


def main():
    """Main learning extraction cycle."""
    print(f"[{datetime.now()}] Learning extractor activated...")

    # Process cron outputs
    learnings = process_cron_outputs()
    print(f"Cron learnings extracted: {len(learnings)}")

    # Process inbox
    processed = process_inbox()
    print(f"Inbox items processed: {len(processed)}")

    # Write daily learning summary
    if learnings or processed:
        daily_file = write_daily_learning(learnings, processed)
        if daily_file:
            print(f"Daily learning written: {daily_file}")
            update_evolution_score(1, "Daily learning extraction")

    print(f"[{datetime.now()}] Learning extraction complete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
