# tidb-dev-prompt

A small collection of TiDB development skills and references designed to be installed with [`vercel-labs/skills`](https://github.com/vercel-labs/skills).

`main` is the published branch for this repository. If you install from `hawkingrei/tidb-dev-prompt`, you are installing the current `main`.

**Skills**
- `context-management` — Context engineering and long-running agent loop hygiene.
- `tidb-doc-finder` — Doc lookup via `llms.txt`, with MCP-first fetching and local search.
- `tidb-optimizer-bugfix` — Minimal TiDB optimizer fixes with hypothesis-driven validation, with supplemental customer issue precedents and issue-mining workflow.
- `tidb-profiler-analyzer` — Analyze TiDB/TiKV/PD/TiFlash CPU or heap profiles from zip archives.
- `plan-replayer-testing` — Add new TiDB plan replayer test cases from a zip bundle.
- `pr-review-helper` — Pull PR comments, diffs, and CI status; fetch Actions logs on failure.

**Install**

List available skills:

```bash
npx skills add hawkingrei/tidb-dev-prompt --list
```

Install a skill into a specific agent:

```bash
npx skills add hawkingrei/tidb-dev-prompt -a codex --skill tidb-doc-finder
npx skills add hawkingrei/tidb-dev-prompt -a claude-code --skill context-management
npx skills add hawkingrei/tidb-dev-prompt -a gemini-cli --skill tidb-profiler-analyzer
```

Replace `-a` and `--skill` as needed. `vercel-labs/skills` will install into the correct directory for each agent.

**Contributing**
- Keep `main` releasable because it is the published install source.
- Keep `SKILL.md` concise and action-oriented.
- Avoid extra docs beyond what the skill needs.
- Use English for documentation and code identifiers.
