---
description: Process accumulated failures into a skill
---

# Process Corrections

You are processing accumulated failures into a skill that will help prevent those failures in the future.

## Gather Input

Use the AskUserQuestion tool to gather the required information:

### Question 1: Failures File

Ask: "Which failures file do you want to process?"

Let user provide the path (e.g., `.failures/test-writing-failures.md`).

### Question 2: Mode

Ask: "Create a new skill or update an existing one?"

Options:
- **create** - Create a new skill from these failures
- **update** - Add to an existing skill

### Question 3: Skill Path

Ask: "Where should the skill be written?"

For create: Let user provide path for new skill (e.g., `.claude/skills/test-writing-pitfalls`)
For update: Let user provide path to existing skill

### Question 4: Skill Name (create mode only)

If mode is `create`, ask: "What should the skill be named?"

Let user provide the skill name (e.g., `test-writing-pitfalls`).

### Question 5: Skill Description (create mode only)

If mode is `create`, ask: "Describe what this skill is for:"

Let user provide a description (e.g., "Common test writing mistakes and how to avoid them").

## Invoke Agent

Once input is gathered, invoke the `cc-process` agent using the Task tool.

**Prompt template (create mode):**
```
Failures file: {failures_file_path}
Mode: create
Skill path: {skill_path}
Skill name: {skill_name}
Skill description: {skill_description}
```

**Prompt template (update mode):**
```
Failures file: {failures_file_path}
Mode: update
Skill path: {skill_path}
```

## Confirm Result

Report the agent's output to the user:
- Skill location
- Number of patterns processed
- Number of pending issues noted
- What happened to the failures file

## Rules

1. Gather all required inputs before invoking the agent
2. Only ask for name and description if mode is create
3. Do not assume or invent values - ask the user
4. Pass through the agent's output without modification
