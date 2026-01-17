---
description: Generate architecture documentation and skills for a codebase. Scans for concepts, creates detailed docs, then generates skills.
argument-hint: [output-dir]
---

You are orchestrating the architecture documentation and skill generation pipeline.

## Step 1: Gather Input

Use the `AskUserQuestion` tool to gather configuration:

```json
{
  "questions": [
    {
      "question": "Where should architecture documentation be written?",
      "header": "Docs",
      "options": [
        {"label": "Project (Recommended)", "description": "./documents/architecture/ - In the project"},
        {"label": "User", "description": "~/documents/architecture/ - In your home directory"},
        {"label": "Current directory", "description": "./ - Write directly here"},
        {"label": "Custom path", "description": "Type your own directory path"}
      ],
      "multiSelect": false
    },
    {
      "question": "How many concepts should be scanned?",
      "header": "Limit",
      "options": [
        {"label": "8 (Recommended)", "description": "Good coverage without overwhelming"},
        {"label": "4", "description": "Quick scan of core concepts"},
        {"label": "12", "description": "Comprehensive scan"},
        {"label": "16", "description": "Maximum depth"}
      ],
      "multiSelect": false
    },
    {
      "question": "Where should the generated skills be created?",
      "header": "Skills",
      "options": [
        {"label": "Project (Recommended)", "description": "./.claude/skills/ - Only for this project"},
        {"label": "User", "description": "~/.claude/skills/ - Available across all projects"},
        {"label": "Current directory", "description": "./skills/ - In the current working directory"},
        {"label": "Custom path", "description": "Type your own path"}
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

Do not ask about target directory (use project root).

## Step 2: Run Scanner

Invoke the `architecture-scanner` agent with the docs location keyword from Step 1:

"Use the architecture-scanner agent to scan the project and output to [docs-location]"

Where `[docs-location]` is `project`, `user`, `current`, or the custom path from Step 1.

Wait for completion.

## Step 3: Present Concepts

Show the user the concept list from the scanner output.

### Using AskUserQuestion for Selection

Use the `AskUserQuestion` tool to let users select concepts interactively.

**If 4 or fewer concepts:** Single multi-select question with all concepts.

**If 5-8 concepts:** Split into 2 questions grouped logically (e.g., by layer or domain):
- Question 1: First group (up to 4 concepts)
- Question 2: Second group (remaining concepts)

**If 9+ concepts:** Split into multiple questions (max 4 options each, max 4 questions = 16 concepts).

**Always include in each question:**
- `multiSelect: true`
- Short `header` describing the group (e.g., "Core", "UI", "Data")
- Clear `description` for each concept explaining what it covers

**Example for 6 concepts:**
```json
{
  "questions": [
    {
      "question": "Which core concepts do you want to document?",
      "header": "Core",
      "options": [
        {"label": "Authentication", "description": "Login, sessions, tokens"},
        {"label": "Authorization", "description": "Permissions, roles"},
        {"label": "Error Handling", "description": "Exception patterns"}
      ],
      "multiSelect": true
    },
    {
      "question": "Which data concepts do you want to document?",
      "header": "Data",
      "options": [
        {"label": "Caching", "description": "Redis, in-memory"},
        {"label": "Database", "description": "Queries, migrations"},
        {"label": "API Layer", "description": "REST endpoints"}
      ],
      "multiSelect": true
    }
  ]
}
```

Users can also type "all" in the Other field to select everything.

## Step 4: Run Analyzers (Parallel)

For each chosen concept, invoke the `architecture-analyzer` agent with the concept name and resolved docs location:

"Use the architecture-analyzer agent to analyze [Concept Name] [docs-location]"

Where `[docs-location]` is the resolved path from Step 1 (e.g., `project`, `user`, `current`, or the custom path).

**Concurrency: Run up to 3 analyzers in parallel.** Start 3, then maintain the queue—when one completes, start the next until all are done.

Each analyzer outputs to the resolved docs location.

## Step 5: Generate Skills (Parallel)

For each completed architecture document, invoke `skill-builder-agent` with the document path and resolved skill location:

"Use the skill-builder-agent to create a skill from [docs-path]/[concept-name].md [skill-location]"

Where `[skill-location]` is `project`, `user`, `current`, or the custom path from Step 1.

**Concurrency: Run up to 3 skill generators in parallel.** Same queue behavior as Step 4.

## Step 6: Summary

Report what was created:
- List of architecture documents at the resolved docs location
- List of generated skills at the resolved skill location