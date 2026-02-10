# tidb-dev-prompt

A small collection of Codex skills and references for TiDB development workflows.

**Skills**
- `context-management` — Context engineering and long-running agent loop hygiene.
- `tidb-doc-finder` — Doc lookup via `llms.txt`, with MCP-first fetching and local search.
- `tidb-profiler-analyzer` — Analyze TiDB/TiKV/PD/TiFlash CPU or heap profiles from zip archives.
- `plan-replayer-testing` — Add new TiDB plan replayer test cases from a zip bundle.
- `pr-review-helper` — Pull PR comments, diffs, and CI status; fetch Actions logs on failure.

**Structure**
- `llms.txt` — Single source of truth for documentation endpoints.
- `<skill>/SKILL.md` — Skill definition and workflow.
- `<skill>/agents/openai.yaml` — Optional UI metadata for skill lists and default prompts.
- `<skill>/scripts/` — Optional helper scripts for deterministic workflows.
- `<skill>/references/` — Optional reference docs loaded on demand.
- `<skill>/assets/` — Optional templates or files used in outputs.

**Usage**
1. Open the relevant `SKILL.md` and follow the workflow.
2. Prefer MCP tools when the skill requests them; fall back to CLI only when needed.

**Contributing**
- Keep `SKILL.md` concise and action-oriented.
- Avoid extra docs beyond what the skill needs.
- Use English for documentation and code identifiers.
