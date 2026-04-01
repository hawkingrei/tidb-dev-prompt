# TiDB Optimizer Bugfix Issue Notes

This skill directory intentionally keeps only the issue-related assets:

- the issue-corpus workflow in `SKILL.md`
- the checked-in issue corpus under `references/tidb-customer-planner-issues/`
- the GitHub mining script in `scripts/`

## Default workflow

1. Search the checked-in corpus first.
2. Read the matching issue files and extract symptoms, linked PRs, merge times, and affected modules.
3. Mine GitHub issues with the script only if the local corpus misses the pattern.
4. Keep the generated files as raw field precedents; do not overfit them into generic rules.

## Issue mining script

Use:

`scripts/generate_tidb_issue_experiences.py`

The script:

- searches GitHub issues with a provided query
- follows issue timeline cross-references and explicit fix comments
- collects linked PR metadata and changed files
- writes one markdown file per issue
- writes an index `README.md` into the output directory

The checked-in issue corpus lives under:

- `references/tidb-customer-planner-issues/`

## Recommended query patterns

For customer-driven planner issues:

```text
repo:pingcap/tidb is:issue label:"report/customer" label:"sig/planner" created:>=2024-01-01
```

For a broader planner or execution slice:

```text
repo:pingcap/tidb is:issue label:"report/customer" (label:"sig/planner" OR label:"sig/execution") created:>=2024-01-01
```

Adjust the query rather than hardcoding different behaviors into the script.

## Usage example

```bash
python3 skills/tidb-optimizer-bugfix/scripts/generate_tidb_issue_experiences.py \
  --query 'repo:pingcap/tidb is:issue label:"report/customer" label:"sig/planner" created:>=2024-01-01' \
  --out-dir outputs/tidb-customer-planner-issues
```

## What to keep from generated issue files

Keep and reuse:

- customer-facing symptom descriptions
- investigation clues
- linked fix PRs
- merge timestamps
- affected modules
- open issues that should remain on the reminder list

Generated files are raw field precedents. Keep them separate from hand-written guidance.

## Tooling assumptions

- `gh` CLI must be installed and authenticated
- network access to GitHub must be available
- the output directory should be treated as generated content
