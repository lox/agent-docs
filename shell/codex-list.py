#!/usr/bin/env python3
import json
import re
from datetime import datetime, timezone
from pathlib import Path
import glob
import sys

if len(sys.argv) > 1:
    target_dir = Path(sys.argv[1]).expanduser().resolve()
else:
    target_dir = Path.cwd()

root = Path.home() / '.codex/sessions'
now = datetime.now(timezone.utc)
USER_MARKER = "## My request for Codex:"


def human_delta(delta):
    secs = int(delta.total_seconds())
    if secs < 60:
        n = max(secs, 0)
        return f"{n} second{'s' if n != 1 else ''} ago"
    if secs < 3600:
        n = secs // 60
        return f"{n} minute{'s' if n != 1 else ''} ago"
    if secs < 86400:
        n = secs // 3600
        return f"{n} hour{'s' if n != 1 else ''} ago"
    n = secs // 86400
    return f"{n} day{'s' if n != 1 else ''} ago"


def scrub(text: str) -> str:
    if not text:
        return ''
    if USER_MARKER in text:
        text = text.split(USER_MARKER, 1)[-1]
    if '</user_instructions>' in text:
        text = text.split('</user_instructions>', 1)[-1]
    text = text.replace('<user_message>', '').replace('</user_message>', '')
    text = re.sub(r'<environment_context>[\s\S]*?</environment_context>', '', text)
    return text.strip()


rows = []
for path_str in glob.glob(str(root / '**' / 'rollout-*.jsonl'), recursive=True):
    path = Path(path_str)
    try:
        mtime = datetime.fromtimestamp(path.stat().st_mtime, tz=timezone.utc)
    except FileNotFoundError:
        continue

    try:
        cwd = None
        preview = None
        with path.open() as fh:
            for line in fh:
                obj = json.loads(line)
                if obj.get('type') == 'session_meta':
                    cwd = obj.get('payload', {}).get('cwd')
                payload = obj.get('payload', {})
                if (
                    preview is None
                    and obj.get('type') == 'response_item'
                    and payload.get('type') == 'message'
                    and payload.get('role') == 'user'
                ):
                    parts = []
                    for part in payload.get('content', []):
                        if part.get('type') == 'input_text':
                            parts.append(scrub(part.get('text', '')))
                    combined = ' '.join(filter(None, parts)).strip()
                    if combined:
                        preview = combined
                if cwd is not None and preview is not None:
                    break
    except Exception:
        continue

    if Path(cwd or '') != target_dir:
        continue

    if not preview:
        continue
    preview = preview.replace('\n', ' ')
    rows.append((mtime, preview, path))

rows.sort(reverse=True)
if not rows:
    print('No sessions found')
else:
    for mtime, preview, path in rows:
        age = human_delta(now - mtime)
        print(f"{age:>12}  {preview[:80]}")
        with path.open() as fh:
            first = json.loads(fh.readline())
            conv_id = first.get('payload', {}).get('id')
        if conv_id:
            print(f'            {conv_id}')
        else:
            print(f'            {path}')
