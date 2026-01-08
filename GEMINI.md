# Gemini Agent Skills

This document provides context on how to create and use Agent Skills within this project, specifically for the "TiDB AI Agent."

## Core Concept

An Agent Skill is a self-contained package of on-demand expertise. Unlike this `GEMINI.md` file which provides persistent background information, a Skill contains specialized, procedural instructions that the agent can activate for a specific task.

## How to Create a Skill for the TiDB Agent

To create a new skill (e.g., for a specific TiDB component), follow these steps:

1.  **Create a Directory**: Make a new directory inside the `.gemini/skills/` folder (e.g., `.gemini/skills/my-tidb-skill`).
2.  **Create `SKILL.md`**: Inside the new directory, create a `SKILL.md` file.
3.  **Define Metadata and Prompt**: Structure the `SKILL.md` file with YAML frontmatter for metadata and Markdown for the detailed instructions (the "prompt").

### `SKILL.md` Structure

```markdown
---
name: <unique-name-for-the-skill>
description: <Crucial for activation. Describe what the skill does and when the agent should use it. For example: "Expertise in TiDB's DDL module for analyzing schema change issues.">
---

# Skill Title (e.g., TiDB DDL Expert)

<This is the body of the prompt.>
Provide detailed, procedural instructions here. Write from the perspective of an expert. Outline the exact steps, principles, and knowledge the agent should apply when this skill is active.
```

## How the Agent Uses Skills

1.  **Discovery**: The agent knows a skill exists because of its `name` and `description`.
2.  **Activation**: When a user's request matches a skill's `description`, the agent will request to activate it.
3.  **Injection**: Upon activation, the detailed instructions from the `SKILL.md` body are loaded into the agent's context, giving it the specialized knowledge for the task.