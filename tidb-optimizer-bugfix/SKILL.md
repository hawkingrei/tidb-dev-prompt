---
name: tidb-optimizer-bugfix
description: "Search and mine TiDB customer planner issues and linked fix PRs to support optimizer bugfix work. Use when you need issue precedents, merge timestamps, affected files, or related bugs."
---

# TiDB Optimizer Bugfix Issue Corpus

Use this skill when fixing a TiDB optimizer or planner bug and you need issue-derived field precedents rather than generic tuning guidance.

This skill is intentionally narrow. It keeps only the customer issue corpus and the script that refreshes it.

## When to use

Use this skill when you need any of the following:

- similar customer-reported planner issues
- linked fix PRs and merge timestamps
- affected modules and changed-file clues
- a local issue corpus to search before mining GitHub again
- a way to refresh the corpus with a new GitHub search query

## Default workflow

1. Search the checked-in corpus first.
   - Start from `references/tidb-customer-planner-issues/README.md`.
   - Search by symptom, operator name, feature, module name, issue number, or error text.

2. Read the matching issue files.
   - Extract the customer-facing symptom.
   - Record linked PRs, merge times, and affected files.
   - Reuse investigation clues, but treat them as raw field evidence rather than stable rules.

3. Refresh the corpus only when the local files miss the pattern.
   - Use `scripts/generate_tidb_issue_experiences.py`.
   - Prefer tightening the GitHub query instead of changing script behavior.

4. Feed the result back into the bugfix workflow.
   - Use the issue corpus to guide reproduction and related-issue checks.
   - Do not confuse issue precedent with proof of root cause; still validate in code and tests.

## High-signal rules

- Prefer the local issue corpus before hitting GitHub again.
- Generated issue files are supporting evidence, not normative documentation.
- Keep this skill issue-focused; do not mix in broad tuning references here.
- Adjust the search query, not the script, when you want a different slice of issues.
- Use issue precedents to find candidate modules and related fixes quickly, not to skip validation.

## Key paths

- `references/tidb-customer-planner-issues/` — checked-in customer planner issue corpus
- `references/tidb-customer-planner-issues/README.md` — generated index for the corpus
- `scripts/generate_tidb_issue_experiences.py` — GitHub issue mining script
- `AGENTS.md` — notes for when to search locally vs refresh the corpus

## Command recipes

```bash
# Search the local corpus first
rg -n "<symptom_or_keyword>" \
  .agents/skills/tidb-optimizer-bugfix/references/tidb-customer-planner-issues

# Refresh the corpus with a customer planner query
python3 .agents/skills/tidb-optimizer-bugfix/scripts/generate_tidb_issue_experiences.py \
  --query 'repo:pingcap/tidb is:issue label:"report/customer" label:"sig/planner" created:>=2024-01-01' \
  --out-dir outputs/tidb-customer-planner-issues
```
