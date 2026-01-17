---
description: Analyze a single architectural concept and generate a skill from the documentation
argument-hint: [concept-name]
---

You are orchestrating a single-concept architecture documentation and skill generation pipeline.

## Input

The concept to analyze is provided via `$ARGUMENTS`. This is a specific architectural concept, feature, or data structure to trace through the codebase.

**Examples of valid concepts:**
- "Authentication"
- "State Management"
- "Data Persistence"
- "Error Handling"
- "Form Validation"

## Step 1: Validate Input

If `$ARGUMENTS` is empty or unclear, ask the user to provide a concept name:

```json
{
  "questions": [
    {
      "question": "What architectural concept should I analyze? Select an example or type your own.",
      "header": "Concept",
      "options": [
        {"label": "Type your own (Recommended)", "description": "Enter a specific concept from your codebase"},
        {"label": "Authentication", "description": "Login, sessions, tokens, auth flow"},
        {"label": "State Management", "description": "App state, providers, stores"},
        {"label": "Data Persistence", "description": "Database, caching, storage"}
      ],
      "multiSelect": false
    }
  ]
}
```

If user selects "Type your own", they enter their concept in the Other field.

## Step 2: Confirm Configuration

Use the `AskUserQuestion` tool to confirm output locations:

```json
{
  "questions": [
    {
      "question": "Where should the architecture document be written?",
      "header": "Docs",
      "options": [
        {"label": "Project (Recommended)", "description": "./documents/architecture/ - In the project"},
        {"label": "User", "description": "~/documents/architecture/ - In your home directory"},
        {"label": "Current directory", "description": "./ - Write directly here"},
        {"label": "Custom path", "description": "Specify a different directory"}
      ],
      "multiSelect": false
    },
    {
      "question": "Where should the generated skill be created?",
      "header": "Skill",
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

**Selection to keyword mapping:**
| User selects | Pass as |
|--------------|---------|
| "Project (Recommended)" | `project` |
| "User" | `user` |
| "Current directory" | `current` |
| "Custom path" | The actual path they typed in Other |

**Location resolution for docs:**
- `project` → `./documents/architecture/`
- `user` → `~/documents/architecture/`
- `current` → `./`
- Custom path → Use the provided path directly

**Location resolution for skills:**
- `project` → `./.claude/skills/[skill-name]/`
- `user` → `~/.claude/skills/[skill-name]/`
- `current` → `./skills/[skill-name]/`
- Custom path → Use the provided path directly

## Step 3: Run Analyzer

Invoke the `architecture-analyzer` agent with the concept and resolved docs location:

"Use the architecture-analyzer agent to analyze [Concept Name] [docs-location]"

Where `[docs-location]` is the resolved path from Step 2 (e.g., `project`, `user`, `current`, or the custom path).

Wait for completion. The analyzer will output to the resolved docs location.

The architecture document will have:
- `# [Concept Name] Architecture` title
- `## Table of Contents` with anchor links and descriptions
- Sections separated by `---`
- No recommendations, code snippets, or hedging language

## Step 4: Generate Skill

Once the architecture document is complete, invoke the `skill-builder-agent` with the document path and resolved skill location:

"Use the skill-builder-agent to create a skill from [docs-path]/[concept-name].md [skill-location]"

Where `[skill-location]` is `project`, `user`, `current`, or the custom path from Step 2.

Wait for completion. The skill will be created at the chosen location with:
- `SKILL.md` - skill manifest with TOC and usage instructions
- Split content files organized by section

## Step 5: Summary

Report what was created, using the actual skill location chosen by the user:

```
## Created

### Architecture Document
- `[output-dir]/[concept-name].md`

### Skill
- `[skill-location]/[concept-name]/SKILL.md`
- `[skill-location]/[concept-name]/*.md` (split content files)

The skill is now available for Claude to use when working with [concept-name].
```
