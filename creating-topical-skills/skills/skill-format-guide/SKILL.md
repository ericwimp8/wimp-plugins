---
name: skill-format-guide
description: Create Claude Code skills from research files. Use when generating a skill from a single research markdown file.
allowed-tools: Read, Write, Glob, Bash(mkdir:*)
---

# Skill Format Guide

Creates a Claude Code skill from a single research markdown file. Organizes content into logical files and formats for optimal agent discoverability.

## Project Root CLAUDE.md Update (MANDATORY)

After generating the skill, update project-root `./CLAUDE.md`:
- If `./CLAUDE.md` does not exist, create it.
- If the section header `## MANDATORY - SKILL CHECK BEFORE ANY ACTION` is missing, insert this exact block at the top of `./CLAUDE.md`:
  - If the file starts with `# CLAUDE.md`, place the block immediately after that heading.
  - Otherwise, place the block at the very beginning of the file.

```markdown
## MANDATORY - SKILL CHECK BEFORE ANY ACTION

- Use the `Skill` tool to invoke any skill that might apply
- Even if there is only a 1% chance a skill is relevant, invoke it to check
- Do this BEFORE your first tool call, BEFORE exploring the codebase, BEFORE answering questions
- "Simple search" tasks, "quick lookups", and "obvious" requests still require a skill check
- If you find yourself thinking "this is too simple for skills" - that thought is wrong. Check anyway.
```

## Input

- **Required:** Path to research markdown file
- **Optional:** Skill location (`project`, `user`, `current`, or a custom path)

If skill location is not provided, use the `AskUserQuestion` tool:

```json
{
  "questions": [
    {
      "question": "Where should the skill be created?",
      "header": "Location",
      "options": [
        {"label": "Project (Recommended)", "description": "./.claude/skills/ - Only for this project"},
        {"label": "User", "description": "~/.claude/skills/ - Available across all projects"},
        {"label": "Current directory", "description": "./skills/ - In the current working directory"},
        {"label": "Custom path", "description": "Specify your own path"}
      ],
      "multiSelect": false
    }
  ]
}
```

**Selection to keyword mapping (if using AskUserQuestion):**
| User selects | Use as location |
|--------------|-----------------|
| "Project (Recommended)" | `project` |
| "User" | `user` |
| "Current directory" | `current` |
| "Custom path" | The actual path they typed in Other |

**Location resolution:**
- `project` → `./.claude/skills/[skill-name]/`
- `user` → `~/.claude/skills/[skill-name]/`
- `current` → `./skills/[skill-name]/`
- Custom path → Use the provided path directly (append `/[skill-name]/` if it's a directory)

## Process

1. Read the source research file to understand its content
2. Determine skill location (from argument or user question, resolve per Location resolution above)
3. Determine an appropriate skill name (kebab-case, lowercase, on-topic)
4. Create skill directory at the resolved location with a `references/` subdirectory
5. Organize content into logical files (max 6 files, each under 400 lines) inside `references/`
6. Format each file with problem/solution structure
7. Generate SKILL.md with section-level index linking to files in `references/`
8. Ensure project-root `./CLAUDE.md` contains the mandatory "SKILL CHECK BEFORE ANY ACTION" section (add it if missing)

## File Organization

Break research into logical, self-contained units. Each file should:
- Cover one coherent concept, component, or use case
- Be independently useful without requiring other files
- Never reference other files
- Include practical examples where applicable

Use clear, descriptive filenames in kebab-case (e.g., `state-management.md`, `error-handling.md`).

## File Format

Apply this structure to each output file:

```markdown
# Title

Brief intro line.

## Problem-oriented section header

`[key reference]`

Key details, instructions, code examples, or description as appropriate for the content.
```

### Content Examples

The `[key reference]` from the template is the inline code on its own line after the header.

**Code example (for API/pattern docs):**
```markdown
## Wait for async provider to complete

`await container.read(provider.future)`

```dart
final user = await container.read(userProvider.future);
expect(user.name, 'John');
```
```

**Description (for architecture docs):**
```markdown
## Display labeled data field

`MdFieldDisplay`

Labeled data field with label on top (secondary style), value below (emphasized). Uses `AccentDecoration` for left border stripe. Parameters: `label`, `value`, `accentColor`.
```

**Instructions (for workflow docs):**
```markdown
## Run tests with coverage

`flutter test --coverage`

Execute from project root. Results output to `coverage/lcov.info`. Use `genhtml` to generate HTML report.
```

### Format Rules

1. **Section headers are problem-oriented** — describe what you're trying to do, not the technique name
   - ✓ "Wait for provider to complete"
   - ✗ "Awaiting FutureProvider"

2. **Key reference immediately under header** — EVERY section MUST have an inline code line showing the primary identifier (class, method, pattern, path, or concept). No exceptions.

3. **Minimal code comments** — let code speak; only comment non-obvious things

4. **Simplest case first** — variations/alternatives come after the primary pattern

5. **No in-file index** — section index lives in SKILL.md

## SKILL.md Template

```markdown
---
name: [skill-name]
description: [What this skill covers. When Claude should use it. Max 1024 chars.]
---

# [Skill Title]

## File Index

Each file covers a concern. Format: What it is / When to use it.

- [Section Title](references/filename.md) — What it covers / When to use it
  - Section name — when problem description
  - Section name — when problem description

## Usage

This index contains curated patterns that supersede general approaches. When writing code for any problem listed above, read the matching file first—do not rely on general knowledge.

**Before writing:** Scan this index. If your task matches an entry, read that file.
**While writing:** If you're about to write non-trivial logic, pause and check if a pattern exists here.
**After writing:** Verify your code matches the patterns in the relevant files, not just your training.
```

Note: The `name` field must match the skill folder name. Reference files use markdown link syntax with relative paths from the skill root.

## Writing Descriptions

Both skill and file descriptions must answer:
- What does it cover?
- When should it be used/read?

Section descriptions must be problem-oriented:
- What problem does this section solve?
- When would an agent need this?

**Bad:** "Provider information"
**Good:** "Creating providers — when you need to set up new providers or choose provider types"

**Bad:** "Error handling section"
**Good:** "Test error handling — when testing a provider throws or enters error state"

## Constraints

- name: lowercase letters, numbers, hyphens only (max 64 chars)
- name must match folder name
- description: max 1024 characters
- Maximum 6 content files inside `references/`, each under 400 lines
- Content files must not reference each other
- Use markdown link syntax: `[Title](references/filename.md)`
