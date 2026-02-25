---
name: tidb-optimizer-bugfix
description: "Fix TiDB optimizer bugs with minimal diffs, hypothesis-driven validation, and regression tests aligned with tidb-test-guidelines. Use when reproducing, fixing, and validating planner/optimizer behavior bugs."
---

# TiDB Optimizer Bugfix Skill

Fix TiDB optimizer bugs with minimal, reviewable changes and strong regression protection.

## When to use

Use this skill when the task is any optimizer/planner correctness bug, including plan cacheability, logical/physical rewrite rules, cost-based selection regressions, and SQL compatibility edge cases.

## Non-negotiable rules

1. Keep the fix minimal.
   - Only change logic that is on the proven root-cause path.
   - Do not mix unrelated cleanup, refactor, or naming churn.

2. Cover language features impacted by the bug and lock behavior with tests.
   - Expand coverage across affected SQL constructs (for example: subquery, CTE, set operator, derived table, partition pruning mode, prepare vs non-prepare).
   - Prefer behavior-focused assertions over implementation details.

3. Test design MUST follow `tidb-test-guidelines`.
   - Read and apply `.agents/skills/tidb-test-guidelines/SKILL.md` in the TiDB repo.
   - Prefer appending to existing test suites/files.
   - Follow placement, naming, fixture reuse, and shard-count guidance from the guideline.
   - When adding new tests, MUST run `make bazel_prepare`.

4. Persist debugging knowledge for future bugfixes.
   - Summarize issues encountered, observed symptoms, validated root cause, and why the final fix is minimal.
   - Add or append a note under TiDB `docs/note` in the relevant subsystem path.
   - Include the key regression SQL/test shape and validation commands in the note.

## Required inputs

- A concrete bug case (issue link, failing SQL, or failing test).
- Target branch and module scope.

If either is missing, ask once, then proceed with explicit assumptions.

## Workflow

1. Reproduce and localize
   - Reproduce with the smallest SQL/test case.
   - Locate ownership paths with `rg` and existing tests before writing code.
   - Build 1-3 root-cause hypotheses and rank by likelihood.

2. Prove the hypothesis before fixing
   - Confirm the highest-probability hypothesis with targeted inspection and/or a minimal failing test.
   - If evidence rejects it, move to the next hypothesis.

3. Implement the smallest defensible fix
   - Change only the necessary branch/condition/state transition.
   - Keep intent explicit and avoid broad reordering unless required for correctness.

4. Mandatory self-check loop

```text
loop {
  ask: Is the fix minimal?
  answer: remove any code not required for the proven root cause.

  ask: Does every added line have meaning, and is it covered by a test case?
  answer: map each added line to one behavior assertion; if no mapping exists, remove it or add a test.

  verify:
    - reproduce failure before fix (or document why pre-fix replay is infeasible)
    - add/extend tests (prefer existing suites)
    - run targeted tests to prove the hypothesis

  if all checks pass: break
}
```

5. Validation and closure
   - Confirm old behavior is rejected and new behavior is accepted.
   - Keep validation scope minimal but sufficient to prove no regression in nearby semantics.

6. Write reusable notes
   - Record debugging pitfalls and verified behavior in `docs/note`.
   - Prefer appending an existing note file over creating a new top-level note file.

## Test strategy checklist

- Start from existing optimizer/planner tests; append cases first.
- Include regression case for the exact failing SQL shape.
- Add one nearby semantic variant to prevent trivial overfitting.
- If bug affects prepare path, verify both prepare and non-prepare semantics when relevant.
- Keep assertions stable and deterministic.

## Command recipes (TiDB repo)

Use targeted commands and keep evidence explicit.

```bash
# Locate code and nearby tests
rg -n "<keyword_or_symbol>" pkg/planner pkg/expression pkg/executor

# Typical targeted optimizer/planner tests
go test -run <TestName> -tags=intest,deadlock ./pkg/planner/...

# If package uses failpoints, decide via search first
rg -n "failpoint\\.Inject|failpoint\\.Enable" pkg/planner/<subpkg>

# MUST run bazel prepare after adding new tests (also run it for other repository-required cases)
make bazel_prepare
```

## Reporting contract

When finishing, report:

1. Files changed and why each change is necessary.
2. Risk check: correctness, compatibility, performance.
3. Exact verification commands used.
4. Note path added/updated under `docs/note` (or why note update was skipped).
5. What was not verified locally.
