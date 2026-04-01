---
name: tidb-optimizer-bugfix
description: "Fix TiDB optimizer bugs with minimal diffs, using plan evidence, tuning references, and regression tests to separate real planner bugs from stats/config/query-tuning issues."
---

# TiDB Optimizer Bugfix Skill

Fix TiDB optimizer bugs with minimal, reviewable changes and strong regression protection. This skill also bundles query-tuning references so you can classify bad-plan incidents before forcing a code patch.

## When to use

Use this skill when the task is any optimizer/planner correctness bug, including plan cacheability, logical/physical rewrite rules, cost-based selection regressions, and SQL compatibility edge cases.

Also use it when a bad plan or slow query might be an optimizer bug but the root cause is still unclear. The first job is to separate:

- real optimizer defects that need code changes
- stats or analyze problems
- query-shape issues that need hints, bindings, indexes, or session variables instead of code

## Non-negotiable rules

1. Keep the fix minimal.
   - Only change logic that is on the proven root-cause path.
   - Do not mix unrelated cleanup, refactor, or naming churn.
   - After the fix works, scan adjacent similar branches/helpers and merge only when that clearly reduces the final diff without widening the semantic surface.
   - Optimize for a diff that a reviewer can validate line by line.

2. Classify before coding.
   - Start from `EXPLAIN ANALYZE`, `PLAN REPLAYER`, bindings, and statistics health.
   - If the evidence points to stale stats, analyze backlog, missing indexes, or a query-local workaround, do not force a code patch.
   - Use the imported references under `references/` and the notes in `AGENTS.md` before inventing a new explanation.

3. Prefer assertions and comments over debug noise.
   - Do not leave test logs, ad-hoc prints, or temporary diagnostics in the final diff.
   - Prefer `intest.Assert` to encode optimizer invariants in intest-only code paths.
   - Add short "why" comments for non-obvious branches, guards, and state transitions.

4. Cover language features impacted by the bug and lock behavior with tests.
   - Expand coverage across affected SQL constructs (for example: subquery, CTE, set operator, derived table, partition pruning mode, prepare vs non-prepare).
   - Prefer behavior-focused assertions over implementation details.
   - Keep tests quiet and deterministic; prove behavior with assertions instead of logs.

5. Test design MUST follow `tidb-test-guidelines`.
   - Read and apply `.agents/skills/tidb-test-guidelines/SKILL.md` in the TiDB repo.
   - Prefer appending to existing test suites/files.
   - Reuse existing table schemas, fixtures, and setup whenever they can express the bug.
   - Avoid creating new test files, tables, or schema setup unless the existing ones cannot cover the failing shape.
   - Follow placement, naming, fixture reuse, and shard-count guidance from the guideline.
   - When adding new tests, MUST run `make bazel_prepare`.

6. Persist debugging knowledge for future bugfixes.
   - Summarize issues encountered, observed symptoms, validated root cause, and why the final fix is minimal.
   - Add or append a note under `~/devel/opensource/tidb-note` in the relevant subsystem path.
   - Include the key regression SQL/test shape and validation commands in the note.

## Required inputs

- A concrete bug case or incident clue: issue link, failing SQL, failing test, or bad-plan report.
- Target branch and module scope.
- Original PR link/number when the task is PR-driven and you need the related-issue bot sweep.
- When the task is auto-picked from `pingcap/tidb` issues, capture the issue labels, title/body, and the smallest likely reproduction clue before coding.

If a key input is missing, ask once, then proceed with explicit assumptions.

## Workflow

1. Triage auto-picked `pingcap/tidb` issues first
   - Before reproducing, inspect labels, title/body, and discussion to decide whether the issue is a bugfix task or an enhancement/request-for-new-capability.
   - If the issue is an enhancement, skip it for this skill instead of forcing a bugfix-shaped patch.
   - Estimate the likely change size (`small`, `medium`, `large`) from expected touched modules, test setup, and schema churn.
   - Prioritize `small` issues first; defer larger ones unless they are already in progress or explicitly assigned.

2. Collect plan evidence and eliminate non-bug explanations
   - Run `EXPLAIN ANALYZE <query>` and compare `estRows` vs `actRows`.
   - Run `PLAN REPLAYER DUMP EXPLAIN [ANALYZE] <query>;` when you need a reproducible package.
   - Check `SHOW GLOBAL BINDINGS;` before assuming the optimizer is acting alone.
   - Check `SHOW STATS_HEALTHY` and inspect analyze freshness before blaming planner logic.
   - Use `references/clues.md`, `references/explain-patterns.md`, `references/stats-health-and-auto-analyze.md`, and `references/stats-loading-and-startup.md` to classify the incident.

3. Mine the local tuning corpus before touching code
   - Search `references/optimizer-oncall-experiences-redacted/` for a symptom match.
   - Search `references/tidb-customer-planner-issues/` when you need linked PRs, merge timestamps, or similar customer precedents.
   - If the local corpus is still missing the pattern, use `scripts/generate_tidb_issue_experiences.py` as described in `AGENTS.md`.

4. Reproduce and localize
   - Reproduce with the smallest SQL/test case.
   - Use TiUP playground and `PLAN REPLAYER LOAD` when local replay is faster than rebuilding the case manually.
   - Locate ownership paths with `rg` and nearby tests before writing code.
   - Build 1-3 root-cause hypotheses and rank by likelihood.

5. Prove the hypothesis before fixing
   - Confirm the highest-probability hypothesis with targeted inspection and/or a minimal failing test.
   - If evidence rejects it, move to the next hypothesis.

6. Implement the smallest defensible fix
   - Change only the necessary branch/condition/state transition.
   - Keep intent explicit and avoid broad reordering unless required for correctness.
   - Prefer touching one existing helper/callsite over introducing a new abstraction.
   - Encode non-obvious invariants with `intest.Assert` and brief "why" comments instead of temporary logs.

7. Mandatory self-check loop

```text
loop {
  ask: Is the fix minimal?
  answer: remove any code not required for the proven root cause, then check whether a tiny merge of adjacent similar handling can shrink the diff further.

  ask: Does every added line have meaning, stay review-friendly, and avoid debug noise?
  answer: map each added line to one behavior assertion or one necessary invariant/comment; if no mapping exists, remove it. Prefer `intest.Assert` over test logs.

  verify:
    - reproduce failure before fix (or document why pre-fix replay is infeasible)
    - add/extend tests (prefer existing suites, existing table shapes, and no test logs)
    - run targeted tests to prove the hypothesis
    - scan nearby similar code and merge only if it makes the final diff smaller and clearer

  if all checks pass: break
}
```

8. Related-issue sweep for PR-driven fixes
   - If there is an original PR, run:

```bash
curl -X POST https://tiara.hawkingrei.com/issues/trigger-reply/<issue_id>
```

   - Replace `<issue_id>` with the ID of the issue being fixed.
   - After the request completes, inspect the bot reply on the original PR and collect the related issues it points out.
   - Before closing the task, check whether the current fix also resolves any of those related issues.
   - If a related issue is also fixed, add regression coverage or explicit validation for that SQL shape when practical.
   - If a related issue is not covered, call it out as remaining follow-up work instead of silently assuming it is fixed.

9. Validation and closure
   - Confirm old behavior is rejected and new behavior is accepted.
   - Keep validation scope minimal but sufficient to prove no regression in nearby semantics.
   - If the final diagnosis is "not a code bug", record the tuning path or workaround clearly instead of ending with an unproven optimizer hypothesis.

10. Write reusable notes
   - Record debugging pitfalls and verified behavior in `~/devel/opensource/tidb-note`.
   - Prefer appending an existing note file over creating a new top-level note file.

## Imported reference map

Read only the files needed for the current incident:

- `references/clues.md` and `references/explain-patterns.md` for initial signal collection.
- `references/plan-replayer-testing.md` and `references/reproduction.md` for local replay and version validation.
- `references/optimizer-hints.md`, `references/session-variables.md`, and `references/optimizer-fix-controls.md` for workaround classification.
- `references/join-strategies.md`, `references/subquery-optimization.md`, `references/index-selection.md`, and `references/optimizer-cost-factors.md` for planner behavior analysis.
- `references/stats-health-and-auto-analyze.md`, `references/stats-loading-and-startup.md`, and `references/stats-version-and-analyze-configuration.md` for stats-driven incidents.
- `references/bug-report.md` when the outcome is a confirmed bug report rather than an immediate patch.
- `references/optimizer-oncall-experiences-redacted/` and `references/tidb-customer-planner-issues/` for field precedents.
- `references/slow-plan-optimization/guide.md` for a slower, broader tuning workflow when the case is not yet bugfix-shaped.

## Test strategy checklist

- Start from existing optimizer/planner tests; append cases first.
- Reuse existing table definitions and fixture data before introducing new schema setup.
- Include regression case for the exact failing SQL shape.
- Add one nearby semantic variant to prevent trivial overfitting.
- If bug affects prepare path, verify both prepare and non-prepare semantics when relevant.
- Create new tests or tables only when the existing suite cannot express the bug faithfully.
- Do not add log/print statements to tests; use assertions for observable behavior.
- Prefer `intest.Assert` for internal invariants in intest-only execution paths.
- Keep assertions stable and deterministic.

## Command recipes (TiDB repo)

Use targeted commands and keep evidence explicit.

```bash
# Locate code and nearby tests
rg -n "<keyword_or_symbol>" pkg/planner pkg/expression pkg/executor

# Search imported field cases before writing a new hypothesis
rg -n "<symptom_or_keyword>" \
  .agents/skills/tidb-optimizer-bugfix/references/optimizer-oncall-experiences-redacted \
  .agents/skills/tidb-optimizer-bugfix/references/tidb-customer-planner-issues

# Typical targeted optimizer/planner tests
go test -run <TestName> -tags=intest,deadlock ./pkg/planner/...

# If package uses failpoints, decide via search first
rg -n "failpoint\\.Inject|failpoint\\.Enable" pkg/planner/<subpkg>

# Trigger the PR bot to surface related issues, then inspect the original PR reply
curl -X POST https://tiara.hawkingrei.com/issues/trigger-reply/<issue_id>

# Mine fresh customer issue precedents when the local corpus is missing the pattern
python3 .agents/skills/tidb-optimizer-bugfix/scripts/generate_tidb_issue_experiences.py \
  --query 'repo:pingcap/tidb is:issue label:"report/customer" label:"sig/planner" created:>=2024-01-01' \
  --out-dir outputs/tidb-customer-planner-issues

# MUST run bazel prepare after adding new tests (also run it for other repository-required cases)
make bazel_prepare
```

## Reporting contract

When finishing, report:

1. Files changed and why each change is necessary.
2. Risk check: correctness, compatibility, performance.
3. Exact verification commands used.
4. Whether the original PR bot surfaced related issues, and which ones were also fixed or left for follow-up.
5. Note path added/updated under `~/devel/opensource/tidb-note` (or why note update was skipped).
6. What was not verified locally.

## Additional PR / Push Guardrails

- Push working branches to your fork (`hawkingrei/tidb`) only. Never push directly to the upstream `pingcap/tidb` repository.
- Open pull requests from your fork (`hawkingrei/tidb:<branch>`) to the upstream repository (`pingcap/tidb:<target-branch>`).
