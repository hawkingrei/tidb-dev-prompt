---
name: context-management
description: "Context engineering and context management for AI agents: keep prompt prefixes stable for KV-cache, use append-only context, prefer tool masking over tool removal, offload large observations into filesystem memory, recite goals/todos to control attention, preserve errors for recovery, and avoid few-shot pattern lock-in. Use when building or debugging agent loops, prompt/context schemas, memory strategies, or tool-availability policies."
---

# Context Management Skill

Design and operate agent context so it is fast, cheap, stable, and robust over long tool-using loops.

## Workflow

1. **Define the invariant prefix**
   - Keep system/developer prompt prefixes stable across turns and sessions.
   - Avoid timestamps, run IDs, random salts, or non-deterministic serialization in the prefix.
   - Keep tool definitions stable; avoid dynamic add/remove mid-episode.

2. **Make context append-only**
   - Never rewrite or "clean up" earlier actions/observations; only append corrections.
   - Ensure deterministic ordering for any serialized data you add to context (stable key order, stable formatting).

3. **Constrain actions without editing tool definitions**
   - Prefer masking/forcing at decode time if you own the runtime.
   - If you only control prompts, keep tool definitions unchanged and append an `Allowed actions` block near the end of the context to gate behavior.
   - Group tool names with consistent prefixes (e.g., `browser_*`, `shell_*`) so you can constrain by group.

4. **Use the filesystem as external memory**
   - Store large observations (pages, logs, diffs, stack traces, CSVs) in files, not in the prompt.
   - Keep context compression reversible: retain pointers (file paths, URLs, IDs) so content can be reloaded on demand.
   - Put only a short summary + pointer in the model context.

5. **Recite goals to control attention**
   - Maintain a `todo.md` (or equivalent) and rewrite it as the task progresses.
   - Re-state the current objective and "next action" near the end of the context before each decision step.

6. **Preserve errors**
   - Keep failed attempts and error outputs visible in context (or in files referenced from context).
   - Add a short postmortem note: "what failed / why / what to try next".

7. **Avoid few-shot pattern lock-in**
   - Do not let the context become a long chain of near-identical action/observation pairs.
   - Introduce controlled variation in formatting/wording/order in the *late* (non-cached) part of context to break brittle imitation, while keeping the prefix stable.

## Deliverables

- A compact "context contract" describing what is stable vs dynamic.
- A filesystem memory layout (folders + key files) that the agent reads/writes.
- A prompt assembly template for each agent step (decision, tool-call, user-response).

## References

- Templates: `context-management/references/templates.md`
- Checklists: `context-management/references/checklists.md`
