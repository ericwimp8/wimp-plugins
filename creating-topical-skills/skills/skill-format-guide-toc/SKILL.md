---
name: skill-format-guide-toc
description: Create Claude Code skills from architecture documents with TOC format. Use when generating a skill from a markdown file with table of contents and sections separated by ---.
allowed-tools: Read, Write, Glob, Bash(mkdir:*)
---

# Skill Format Guide (TOC)

Creates a Claude Code skill from a single markdown architecture document. Splits sections into logical files and formats for optimal agent discoverability.

## Input

- **Required:** Path to markdown reference file
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

1. Read the source markdown file
2. Determine skill location (from argument or user question, resolve per Location resolution above)
3. Extract skill name from the document heading (convert to kebab-case)
4. Create skill directory at the resolved location
5. Split content at `---` separators into logical files (max 6 files, each under 400 lines)
6. Format each file with problem/solution structure
7. Generate SKILL.md with section-level index

## Source File Format

The source file must have:
- A level-1 heading (`# Title`) as the document title
- A `## Table of Contents` section with linked entries and descriptions
- Sections separated by `---`

## File Organization

Each `---` separated section becomes a candidate for a separate file. Group related sections if needed to stay under 6 files. Each file should:
- Cover one coherent concept or component category
- Be independently useful without requiring other files
- Never reference other files
- Use the section heading as the basis for the filename (kebab-case)

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
   - ✓ "Display labeled data field"
   - ✗ "MdFieldDisplay Widget"

2. **Key reference immediately under header** — EVERY section MUST have an inline code line showing the primary identifier (class, method, pattern, path, or concept). No exceptions.

3. **Preserve important details** — parameters, properties, and usage patterns from the source

4. **No in-file index** — section index lives in SKILL.md

## SKILL.md Template

```markdown
---
name: [skill-name]
description: [What this skill covers. When Claude should use it. Max 1024 chars.]
---

# [Skill Title]

## File Index

Each file covers a concern. Format: What it is / When to use it.

- `[filename.md]` — What it covers / When to use it
  - Section name — when problem description
  - Section name — when problem description

## Usage

This index contains curated patterns that supersede general approaches. When writing code for any problem listed above, read the matching file first—do not rely on general knowledge.

**Before writing:** Scan this index. If your task matches an entry, read that file.
**While writing:** If you're about to write non-trivial logic, pause and check if a pattern exists here.
**After writing:** Verify your code matches the patterns in the relevant files, not just your training.
```

Note: The `name` field must match the skill folder name.

## Writing Descriptions

Both skill and file descriptions must answer:
- What does it cover?
- When should it be used/read?

Section descriptions must be problem-oriented:
- What problem does this section solve?
- When would an agent need this?

**Bad:** "Button widgets"
**Good:** "Button components — when implementing action buttons, icon buttons, or menu buttons"

**Bad:** "MdDialog section"
**Good:** "Show modal dialogs — when displaying alerts, confirmations, or custom dialog content"

## Constraints

- name: lowercase letters, numbers, hyphens only (max 64 chars)
- name must match folder name
- description: max 1024 characters
- Maximum 6 content files, each under 400 lines
- Files must not reference each other
