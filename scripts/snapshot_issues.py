"""Write a read-only snapshot of this repo's GitHub issues to `.scratch/issues/`.

GitHub is the source of truth for tickets. This exists only for reading them
offline, and its output is gitignored: a committed copy would drift from GitHub
the moment an issue was edited or closed, and still look authoritative. That
already happened once, to a hand-written mirror this script replaces.

Every issue is written, open and closed, one file each, with its live state,
labels, body and comments, under a header that says when it was generated.
`README.md` indexes them, with each issue's "Blocked by" list read from the
`## Blocked by` section of its body.

Needs the GitHub CLI (`gh`), authenticated. Run from anywhere in the repo:

    python scripts/snapshot_issues.py
"""
import json
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = REPO_ROOT / '.scratch' / 'issues'
FIELDS = 'number,title,state,labels,body,comments,url'


def fetch_issues():
    if shutil.which('gh') is None:
        sys.exit('The GitHub CLI (gh) is not on PATH. Install it and run `gh auth login`.')
    result = subprocess.run(
        ['gh', 'issue', 'list', '--state', 'all', '--limit', '1000', '--json', FIELDS],
        cwd=REPO_ROOT, capture_output=True, text=True, encoding='utf-8',
    )
    if result.returncode != 0:
        sys.exit(f'gh failed:\n{result.stderr}')
    return sorted(json.loads(result.stdout), key=lambda issue: issue['number'])


def blocked_by(body):
    """Issue numbers listed under the body's `## Blocked by` heading, each once."""
    section = re.search(r'^## Blocked by\s*$(.*?)(?=^## |\Z)', body or '', re.M | re.S)
    if not section:
        return []
    return list(dict.fromkeys(int(n) for n in re.findall(r'#(\d+)', section.group(1))))


def slug(title):
    return re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')[:60]


def render_issue(issue, generated):
    labels = ', '.join(label['name'] for label in issue['labels']) or 'none'
    lines = [
        f"# #{issue['number']}: {issue['title']}",
        '',
        f"**Tracker:** {issue['url']}",
        '',
        f"**State:** {issue['state'].lower()} · **Labels:** {labels}",
        '',
        f'> Generated {generated} from GitHub by `scripts/snapshot_issues.py`.',
        '> Do not edit: re-run the script. GitHub is the source of truth.',
        '',
        (issue['body'] or '_No body._').strip(),
    ]
    if issue['comments']:
        lines += ['', '---', '', '## Comments']
        for comment in issue['comments']:
            lines += [
                '',
                f"### {comment['author']['login']}, {comment['createdAt'][:10]}",
                '',
                comment['body'].strip(),
            ]
    return '\n'.join(lines) + '\n'


def render_index(issues, generated):
    lines = [
        '# Issues',
        '',
        f'> Generated {generated} from GitHub by `scripts/snapshot_issues.py`.',
        '> Do not edit: re-run the script. GitHub is the source of truth.',
        '',
        '| # | Title | State | Labels | Blocked by |',
        '|---|-------|-------|--------|------------|',
    ]
    for issue in issues:
        labels = ', '.join(label['name'] for label in issue['labels']) or '—'
        blockers = ', '.join(f'#{n}' for n in blocked_by(issue['body'])) or '—'
        link = f"[{issue['title']}]({issue['number']:03d}-{slug(issue['title'])}.md)"
        lines.append(
            f"| {issue['number']} | {link} | {issue['state'].lower()} | {labels} | {blockers} |"
        )
    return '\n'.join(lines) + '\n'


def main():
    issues = fetch_issues()
    generated = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')

    # The directory holds nothing but this script's output, so clearing it is
    # what removes the file for an issue that no longer exists.
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for old in OUT_DIR.glob('*.md'):
        old.unlink()

    for issue in issues:
        path = OUT_DIR / f"{issue['number']:03d}-{slug(issue['title'])}.md"
        path.write_text(render_issue(issue, generated), encoding='utf-8', newline='\n')
    (OUT_DIR / 'README.md').write_text(
        render_index(issues, generated), encoding='utf-8', newline='\n',
    )
    print(f'Wrote {len(issues)} issues to {OUT_DIR.relative_to(REPO_ROOT)}')


if __name__ == '__main__':
    main()
