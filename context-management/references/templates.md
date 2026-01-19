# Templates

Use these templates to keep a stable prefix while pushing dynamic state to the end.

## Filesystem memory layout

Create a small, predictable structure:

- `context/`
  - `todo.md` (goals + checklist; rewritten)
  - `state.md` (current state; rewritten)
  - `decisions.md` (append-only decisions + rationale)
  - `errors.md` (append-only failures + retry notes)
  - `log.md` (append-only: actions/observations pointers)
- `artifacts/` (large tool outputs; append-only files)

## `context/todo.md`

```md
# Goal
<one sentence>

# Success criteria
- [ ] <criterion 1>
- [ ] <criterion 2>

# Plan (rewrite as needed)
- [ ] <step 1>
- [ ] <step 2>

# Next action
<exactly one concrete action>
```

## `context/errors.md`

```md
FAILED: <what failed>
WHY: <best guess>
NEXT: <next attempt>
```

## `context/state.md`

```md
# Current status
<2-5 bullets>

# Constraints
- <hard constraint>

# Known unknowns
- <question that blocks progress>

# Pointers
- <file path or URL>: <why it matters>
```

## Offload example (large output)

```text
Summary: tool output too large; wrote full log to artifacts/scan.log
Pointer: artifacts/scan.log
```

## Prompt assembly (decision step)

Keep everything above `=== DYNAMIC ===` as stable as possible across turns.

```text
<SYSTEM/DEVELOPER PREFIX: stable>
<TOOL DEFINITIONS: stable>

=== DYNAMIC ===
[Task]
<short restatement of current objective>

[Allowed actions]
- allow: <tool group or tool names>
- deny: <tool group or tool names>

[State]
<paste from context/state.md (short)>

[Todo]
<paste from context/todo.md (short)>

[Evidence pointers]
- artifacts/<file>: <1-line summary>

[Errors to remember]
- <pointer to error log>: <what failed and what changed>

[Next action]
<one concrete action>
```
