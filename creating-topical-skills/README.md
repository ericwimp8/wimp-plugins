# Creating Skills Plugin

A comprehensive Claude Code plugin for creating and managing high-quality Agent Skills. This plugin provides a complete toolset for transforming codebase analysis and documentation into reusable Claude Code skills.

**Version:** 1.5.0
**Author:** Eric Wimp
**License:** MIT

## Overview

The `creating-topical-skills` plugin empowers developers and documentation specialists to:

- **Scan codebases** rapidly to identify key architectural concepts
- **Analyze architectural patterns** and trace how concepts flow through code
- **Generate skills automatically** from reference documentation
- **Create single-file and multi-file skills** with proper structure and metadata

This plugin separates the concerns of architecture analysis, documentation generation, and skill creation into specialized agents and commands, enabling flexible workflows for different use cases.

## Installation

As a Claude Code plugin, install it directly from the marketplace or from your local repository:

```bash
claude plugin install creating-topical-skills
```

Or reference it by path:

```bash
claude plugin add /path/to/creating-topical-skills
```

## Quick Start

### Generate Architecture Documentation and Skills

The fastest way to create skills is the end-to-end pipeline:

```bash
claude architecture-skill-generator /path/to/output
```

This command will:
1. Ask you to configure the output directory and concept limit
2. Scan your codebase to identify architectural concepts
3. Let you select which concepts to document
4. Analyze each concept in parallel
5. Generate skills from each architectural document

### Create Skills from Existing Documentation

If you have reference documentation ready:

```bash
# From a single file with table of contents
claude doc-to-skill docs/my-feature.md

# From a directory of markdown files
claude research-to-skill docs/research-files/
```

## Available Commands

### `architecture-skill-generator`

**Purpose:** End-to-end orchestrator for architecture documentation and skill generation
**Argument:** Output directory path (required)

**Workflow:**

```
User Input → Scanner → Concept Selection → Analyzers (parallel) → Skill Generators (parallel) → Summary
```

**Features:**
- Interactive configuration for output location and concept limit
- Parallel architecture analysis (up to 3 concurrent)
- Parallel skill generation (up to 3 concurrent)
- Multi-select concept selection with logical grouping

**Example:**

```bash
claude architecture-skill-generator documents/architecture/
```

The command will guide you through selecting how many concepts to scan (4, 8, 12, or 16) and which concepts to document. Up to 3 architecture analyzers will run in parallel for efficiency.

---

### `doc-to-skill`

**Purpose:** Create a Claude Code skill from a single markdown reference file with table of contents
**Argument:** Path to markdown file (required)

**Requirements:**
- File must have a level-1 heading (`# Title`)
- File must have a `## Table of Contents` section with linked entries
- Sections should be separated by `---` markers

**Output:**
- Skill directory at `.claude/skills/[skill-name]/`
- `SKILL.md` - skill manifest with file index and usage instructions
- `references/` - directory containing split content files

**Example:**

```bash
claude doc-to-skill docs/flutter-testing.md
```

This will create a skill in `.claude/skills/flutter-testing/` with content files in the `references/` subdirectory.

---

### `research-to-skill`

**Purpose:** Create a Claude Code skill from a directory of markdown research files
**Argument:** Path to source directory (required)

**Requirements:**
- Directory contains markdown files (`.md`)
- Each file should be self-contained
- Maximum 6 files per skill
- Each file should be under 400 lines

**Output:**
- Skill directory at `.claude/skills/[skill-name]/`
- `SKILL.md` - skill manifest with file index and descriptions
- `references/` - directory containing all content files

**Example:**

```bash
claude research-to-skill research/riverpod-patterns/
```

This will create a skill from all `.md` files in the directory, generating a file index in `SKILL.md`.

---

### `concept-to-skill`

**Purpose:** Analyze a single architectural concept and generate a skill from the documentation
**Argument:** Concept name (optional - will prompt if not provided)

A streamlined pipeline for when you already know which concept you want to document. Skips the scanning and selection steps of `architecture-skill-generator`.

**Workflow:**

```
Concept Input → Output Directory → Analyzer → Skill Generator → Summary
```

**Features:**
- Direct concept input - no codebase scanning required
- Interactive prompts if concept not provided
- Single architecture document output
- Single skill generation

**Output:**
- Architecture document at `[output-dir]/[concept-name].md`
- Skill directory at `.claude/skills/[concept-name]/`

**Examples:**

```bash
# With concept provided
/creating-topical-skills:concept-to-skill Authentication

# With quoted concept name
/creating-topical-skills:concept-to-skill "State Management"

# Without argument (will prompt for concept)
/creating-topical-skills:concept-to-skill
```

Use this command when you want to quickly document and create a skill for a specific concept without running a full codebase scan.

## Available Agents

Agents are specialized Claude Code agents that execute specific tasks. They are typically invoked by commands and orchestrators, but can also be invoked directly.

### `architecture-scanner`

**When Used:**
- First step in the architecture documentation pipeline
- When you need to discover key concepts in a codebase
- Invoked by the `architecture-skill-generator` command

**Responsibilities:**
- Detects project type (Flutter, React, Python, Node.js, etc.)
- Uses the `file-tree` skill to analyze directory structure
- Samples key files to identify architectural patterns
- Outputs a prioritized list of architectural concepts

**Inputs:**
- Target directory (default: project root)
- Output directory (optional)
- Concept limit (1-16, default: 8)

**Output:**
- `_concepts.md` file with identified concepts
- Each concept includes implementation hints for downstream analyzers

**Example Concepts Identified:**
- State Management (with specific framework hints)
- Data Persistence (with database/ORM information)
- Authentication (with token/session patterns)
- Form Architecture (with validation approaches)
- Navigation (with routing patterns)

---

### `architecture-analyzer`

**When Used:**
- Detailed analysis of specific architectural concepts
- Run in parallel for multiple concepts (up to 3 concurrent)
- Invoked by the `architecture-skill-generator` command

**Responsibilities:**
- Traces how a concept flows through the entire codebase
- Maps entry points, transformation layers, storage, and exit points
- Identifies architectural patterns and abstraction layers
- Produces LLM-consumable documentation without human interpretation

**Inputs:**
- Concept name (via `$ARGUMENTS`)

**Output:**
- Architecture document at `documents/architecture/[concept-name].md`
- Contains Table of Contents with anchor links
- Organized sections showing data flow, connections, and patterns
- No code snippets, recommendations, or hedging language

**Output Format Requirements:**
- Meaningful Table of Contents with brief section descriptions
- Clear section separators (`---`)
- Reference format: `ClassName`, `ClassName.methodName`, `functionName`
- No recommendations, testing suggestions, or future considerations

---

### `skill-builder-agent`

**When Used:**
- Converting architecture documents to skills
- Creating skills from single reference files with TOC
- Invoked by the `architecture-skill-generator` command

**Responsibilities:**
- Reads single markdown reference files
- Splits content into focused files in `references/` directory
- Generates SKILL.md with file index and usage instructions
- Sets up progressive disclosure pattern with file-based navigation

**Inputs:**
- Source markdown file path (via `$ARGUMENTS`)

**Output:**
- Skill directory structure at `.claude/skills/[skill-name]/`
- `SKILL.md` - skill manifest with file index and usage instructions
- `references/` - directory containing split content files

**Skill Features:**
- Content split into logical files in `references/` directory
- File index with markdown links for navigation
- Optimized for LLM consumption with progressive disclosure

## Available Skills

Skills provide specialized guidance and tooling. They can be invoked directly or used by agents.

### `file-tree`

**Purpose:** Generate and analyze project directory structures
**When to Use:** When you need to visualize codebase layout, understand folder organization, or explore project structure

**Provides:**
- Shell script for generating directory trees
- Ignore pattern support for build artifacts and dependencies
- Framework-aware pattern suggestions (Flutter, Node.js, Python)

**Script Location:** [tree.sh](scripts/tree.sh)

**Usage:**

Run the script from the skill directory (paths are relative to skill root):

```bash
bash scripts/tree.sh /path/to/project
```

**With Ignore Patterns:**

```bash
# Flutter/Dart project
bash scripts/tree.sh /project --ignore ".git,.dart_tool,build,.packages,Pods,.gradle"

# Node.js project
bash scripts/tree.sh /project --ignore ".git,node_modules,dist,.cache,.next"

# Python project
bash scripts/tree.sh /project --ignore ".git,__pycache__,.venv,.pytest_cache,*.egg-info"
```

**Output Format:**
```
project/src/main.ts
project/src/utils/helper.ts
project/package.json
...
```

---

### `skill-format-guide`

**Purpose:** Convert directories of research markdown files into Claude Code skills
**When to Use:** When you have a directory of documentation files and want to create a skill from them

**Provides:**
- Processes all markdown files in a directory
- Generates skill manifest with file index
- Validates constraints (max 6 files, <400 lines each)
- Creates kebab-case skill names automatically

**Processing:**
1. Reads all markdown files in source directory
2. Determines appropriate skill name
3. Creates `.claude/skills/[skill-name]/` directory with `references/` subdirectory
4. Places all content files in `references/`
5. Generates SKILL.md with file index linking to `references/` files

**Constraints:**
- Maximum 6 content files inside `references/`, each under 400 lines
- Content files should not reference each other
- Skill name: lowercase letters, numbers, hyphens (max 64 chars)

**Skill Manifest (SKILL.md) Structure:**
- Metadata: `name` and `description`
- File Index: Links to content files using `[Title](references/filename.md)` syntax
- Usage: Instructions for reading relevant files

---

### `skill-format-guide-toc`

**Purpose:** Convert a single markdown reference file with TOC into a Claude Code skill
**When to Use:** When you have comprehensive documentation in a single file with table of contents

**Provides:**
- Extracts skill metadata from document headings
- Splits content into focused files in `references/`
- Enables progressive disclosure with file-based navigation
- Creates reference-based skills for efficient access

**Processing:**
1. Reads single markdown reference file
2. Extracts skill name from level-1 heading (converts to kebab-case)
3. Creates `.claude/skills/[skill-name]/` directory with `references/` subdirectory
4. Splits content at `---` separators into logical files inside `references/`
5. Generates SKILL.md with file index linking to `references/` files

**Source File Requirements:**
- Level-1 heading (`# Title`) for skill metadata
- `## Table of Contents` section with linked entries
- Sections separated by `---` markers

**Skill Manifest (SKILL.md) Structure:**
- Metadata: `name` and `description`
- File Index: Links to content files using `[Title](references/filename.md)` syntax
- Usage: Instructions for reading relevant files

**Progressive Disclosure:**

Content is split into focused files in `references/`. The SKILL.md file index uses markdown links:
```markdown
- [Section Title](references/section-name.md) — What it covers / When to use it
```

This allows LLMs to read only relevant sections without loading entire files.

## Architecture & Workflow

The plugin follows a three-level architecture with clear separation of concerns:

### Level 1: Commands

Commands are user-facing entry points that orchestrate workflows:

- **`architecture-skill-generator`**: Full pipeline from scanning to skill creation
- **`concept-to-skill`**: Single-concept analysis and skill creation
- **`doc-to-skill`**: Single-file skill creation
- **`research-to-skill`**: Multi-file skill creation

### Level 2: Agents

Agents are specialized Claude Code agents that perform specific tasks:

```
architecture-skill-generator (orchestrator)
├── Gathers user configuration (AskUserQuestion tool)
├── Invokes architecture-scanner agent
├── Presents concept list (AskUserQuestion tool)
├── Invokes architecture-analyzer agents (parallel, max 3)
├── Waits for analysis to complete
├── Invokes skill-builder-agent (parallel, max 3)
└── Reports summary of created skills
```

Each agent runs as a separate Claude instance with specialized instructions:
- **`architecture-scanner`** (Model: Sonnet, Color: Green): Lightweight codebase surveying
- **`architecture-analyzer`** (Model: Opus, Color: Blue): Deep architectural analysis
- **`skill-builder-agent`**: Single-file skill generation

### Level 3: Skills

Skills provide reusable guidance and utilities:

- **`file-tree`**: Directory structure visualization
- **`skill-format-guide`**: Multi-file skill creation guidance
- **`skill-format-guide-toc`**: Single-file skill creation guidance

### Complete Pipeline: Architecture to Skills

```
┌─────────────────────────────────────────────────────────────────┐
│ User runs: claude architecture-skill-generator                  │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
          ┌────────────────────────┐
          │ Gather Configuration   │
          │ - Output directory     │
          │ - Concept limit (4-16) │
          └────────────┬───────────┘
                       │
                       ▼
          ┌────────────────────────┐
          │ architecture-scanner   │
          │ (Sonnet, Green)        │
          │                        │
          │ Uses: file-tree skill  │
          │ Output: _concepts.md   │
          └────────────┬───────────┘
                       │
                       ▼
        ┌──────────────────────────┐
        │ Present Concept List     │
        │ (Multi-select, grouped)  │
        └────────┬─────────────────┘
                 │
                 ▼
    ┌────────────────────────────────┐
    │ Parallel Analyzers (max 3)     │
    │                                │
    │ architecture-analyzer agents   │
    │ (Opus, Blue) x N               │
    │                                │
    │ Each outputs:                  │
    │ documents/architecture/        │
    │ [concept-name].md              │
    └────────────┬───────────────────┘
                 │
                 ▼
    ┌────────────────────────────────┐
    │ Parallel Skill Generators      │
    │ (max 3 concurrent)             │
    │                                │
    │ skill-builder-agent x N        │
    │                                │
    │                                │
    │ Each creates:                  │
    │ .claude/skills/[concept-name]/ │
    │ ├── SKILL.md                   │
    │ └── references/*.md            │
    └────────────┬───────────────────┘
                 │
                 ▼
        ┌──────────────────────────┐
        │ Report Summary           │
        │ - Created documents      │
        │ - Generated skills       │
        └──────────────────────────┘
```

### Key Design Principles

1. **Separation of Concerns**: Commands orchestrate, agents execute specialized tasks, skills provide guidance
2. **Progressive Disclosure**: Skills and documents enable LLM reading by section, not requiring full file loads
3. **Parallel Execution**: Multiple architecture analyzers and skill generators run concurrently (max 3 each)
4. **Framework Agnostic**: File-tree patterns adapt to project type; agents work across any codebase
5. **LLM Optimization**: All output is formatted for LLM consumption without human interpretation

## Requirements & Dependencies

### System Requirements
- Claude Code installed and configured
- Bash shell (for `file-tree` script)
- Read access to the target codebase

### Model Requirements
- **architecture-scanner**: Claude Sonnet 3.5 (lightweight, fast scanning)
- **architecture-analyzer**: Claude Opus 4.5 (deep analysis capability)
- **skill-builder-agent**: Claude Sonnet 3.5 (default)

### Skill Dependencies
- `file-tree`: Used by `architecture-scanner` agent
- `skill-format-guide-toc`: Used in skill generation pipeline
- `skill-format-guide`: Used in skill generation pipeline

## Typical Use Cases

### Use Case 1: Document a New Feature and Create a Skill

1. Run architecture analysis on the feature area
2. The `architecture-analyzer` produces `feature-name.md`
3. Use `doc-to-skill` to convert to a skill
4. Share the skill for team reuse

### Use Case 2: Create Multiple Skills from a Codebase

1. Run `architecture-skill-generator` to start the pipeline
2. Select 8-12 key concepts to document
3. Parallel analyzers generate documentation
4. Parallel skill generators create skills automatically
5. Review generated skills in `.claude/skills/`

### Use Case 3: Convert Existing Documentation to Skills

If you have a directory of reference documentation:
```bash
claude research-to-skill docs/my-patterns/
```

If you have a single comprehensive guide with TOC:
```bash
claude doc-to-skill docs/complete-guide.md
```

### Use Case 4: Understand Architecture Before Refactoring

1. Run `architecture-skill-generator` to analyze current state
2. Review generated architecture documents
3. Generated skills provide permanent reference material
4. Documents show exactly which components are affected

## Creating Research Files with Claude Projects

Before using `research-to-skill`, you can generate research using Claude.ai Projects with deep research. This workflow leverages Claude's research capabilities to gather comprehensive information on any topic. The skill creator then organizes and formats the research into a skill.

### Setup

1. **Create a new Claude Project** at claude.ai
2. **Configure settings:**
   - Enable "Deep Research"
   - Set style to "Concise"
3. **Add project instructions** (paste into project instructions field):

```
Execute the research phase following topical-research-prompt.md when the user provides a topic.
```

4. **Add one file** to the project:

**`topical-research-prompt.md`**
```markdown
# Topical Research Prompt

Research the provided topic using deep research.

<topic>
{{TOPIC}}
</topic>

## Research Phase

Use deep research to gather comprehensive information:
1. Identify core concepts, components, and use cases
2. Prioritize official documentation and authoritative sources
3. Note version-specific details where relevant
4. Include practical code examples where applicable

## Audience

This content is for an AI agent to use as reference guidance, not for human developers at a specific skill level. Write for comprehensive technical accuracy without adjusting complexity for beginner/intermediate/advanced readers.

## Output

After research completes, use computer tools to save the research as a single markdown file in /mnt/user-data/outputs/[topic-name].md
```

### Usage

Once your project is configured, provide a topic with optional reference URLs:

**Example prompt:**
```
riverpod 3.0 testing
This is the official documentation: https://riverpod.dev/docs/how_to/testing
This is where the repo tests its source: https://github.com/rrousselGit/riverpod/tree/master/packages/riverpod/test
```

Claude will research the topic and save findings to a single markdown file.

### Converting to a Skill

After the research completes:

1. Download the research file from Claude Projects
2. Run the skill creator:

```bash
/creating-topical-skills:research-to-skill path/to/research-file.md
```

The skill creator will:
- Organize the research into logical files
- Format each file with problem/solution structure
- Generate SKILL.md with section-level index

This creates a fully-formed skill at `.claude/skills/[topic-name]/` ready for use in Claude Code.

## Skill Quality Guidelines

When creating skills that will be reused across projects:

### For Single-File Skills (with TOC)

The `architecture-analyzer` agent creates these automatically from your project files.

- Include detailed Table of Contents with meaningful section descriptions
- Use progressive disclosure: each section should be independently readable
- Avoid recommendations; focus on patterns and architectural flows
- Format references consistently: `ClassName`, `ClassName.methodName`, `functionName`

### For Multi-File Skills

See [Creating Research Files with Claude Projects](#creating-research-files-with-claude-projects) for guidance on generating these files using claude.ai.

- Maximum 6 files
- Each file under 400 lines
- Files should be self-contained (no cross-references)
- Provide clear descriptions of when to read each file

## License

MIT License - See LICENSE file for details
