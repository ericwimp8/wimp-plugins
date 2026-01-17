---
description: Create a Claude Code skill from a research file
argument-hint: [research-file] [project|user|current|<path>]
allowed-tools: Read, Write, Glob, Bash(mkdir:*)
---

## Instructions

1. Invoke `Skill(skill-format-guide)` to load the full instructions
2. Follow the loaded skill instructions exactly
3. Research file: $ARGUMENTS (first argument)
4. Location: $ARGUMENTS (second argument: `project`, `user`, `current`, or a custom path - ask user if not provided)

## Signs You Are About to Fail

If you have any of these thoughts, STOP - you are skipping the skill:

| Thought | Why It's Wrong |
|---------|----------------|
| "Let me read the research file first" | The skill tells you HOW to read it. Invoke the skill first. |
| "I need to understand the task before loading instructions" | The instructions ARE the understanding. Load them. |
| "I'll create a todo list to track this" | The skill may have its own structure. Don't assume. |
| "Now let me create the skill file" | You don't know the format yet. The skill defines it. |
| "I know how to create skills" | This skill may have specific requirements. Load it. |