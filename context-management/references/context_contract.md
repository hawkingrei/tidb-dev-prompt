# Context Contract (Template)

## Version
- v0.1: initial template

## Purpose
Keep the prompt prefix stable, push dynamic state to the tail, and offload bulky data to files.

## Stable Prefix (never changes)
- System/developer instructions
- Tool definitions
- Fixed formatting blocks and headings

## Dynamic Tail (changes every step)
- Goal (1 line)
- Next action (1 line)
- Allowed actions (tool allow/deny list)
- Pointers to external memory files
- Error notes (if any)

## Filesystem Memory Layout
- `context/`
  - `todo.md` (goal + next action; rewritten each step)
  - `state.md` (current status; rewritten)
  - `errors.md` (append-only failures + retry notes)
  - `log.md` (append-only action/observation pointers)
- `artifacts/` (large tool outputs; append-only)

## When to Offload to Files
- If a tool output exceeds: `<N lines>` or `<K KB>`, write to `artifacts/` and keep only a 1-2 line summary + file path in context.

## Error Handling
- On failure, append to `context/errors.md`:
  - What failed
  - Why (best guess)
  - Next attempt plan

## Anti Lock-In Rule
- Every 3-5 steps, vary the order or wording of the dynamic tail (keep the stable prefix unchanged).

## Step Ritual
1) Update `context/todo.md` with 1 line Goal + 1 line Next action.
2) If needed, update `context/state.md`.
3) Append new artifacts and log pointers.
