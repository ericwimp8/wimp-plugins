# Failure Telemetry → Skill System: Overview

## The Problem
LLMs repeat the same mistakes. Skills help prevent known issues, but there are gaps - unanticipated recurring failures that block progress and require human intervention. Currently, turning these failures into skills is a manual human observation process.

## The Solution
Build a **failure telemetry system** that:
- Captures failures from any agent-based workflow
- Accumulates them in an organized way
- Processes patterns to generate targeted skills that close the gaps

## Key Constraints

### 1. Agnostic & Standalone
- Its own plugin with agents, skills, and commands
- Not embedded in test-writer or any specific domain
- Any domain-specific system (test-writer, Swift UI, etc.) can call into it

### 2. Semantic Isolation
- Each caller's failures are stored separately
- Failures from test-writer don't mix with failures from a Swift UI system
- But each caller can access their own failure history

### 3. Plugin Architecture
- Lives in its own plugin folder: `common-corrections/`
- Other plugins reference its agents/skills via component paths:

```json
{
  "name": "test-writer",
  "source": "./",
  "skills": ["./test-writer/skills/", "./common-corrections/skills/"],
  "agents": ["./test-writer/agents/", "./common-corrections/agents/"]
}
```

- No shared/ folder needed - plugins reference each other directly
- common-corrections remains a proper standalone plugin

---

## Automation vs Human Involvement

| Stage | Automated | Human Involvement |
|-------|-----------|-------------------|
| Capture | Caller invokes telemetry system | Caller decides what's worth capturing |
| Storage | Fully automated | None |
| Pattern Analysis | LLM clusters/identifies patterns | Review: is this real signal or noise? |
| Skill Drafting | LLM generates skill content | Review: is this correct/useful? |
| Integration | Automated - writes to user's skill location | Initial setup only |

---

## Skill Integration Approach

### Install Process (One-time Setup)
1. User runs install agent from failure-telemetry plugin
2. Agent uses AskUserQuestion: "What name for your common failures skill?"
3. Agent asks for location: personal (`~/.claude/skills/`) or project (`./.claude/skills/`)
4. Agent creates the skill with that name
5. User explicitly invokes the skill in their workflows (they know the name because they chose it)

### Skill Location
- Lives in user's `.claude/skills/` folder (not in a plugin folder)
- User chooses level: personal or project
- Skills can use index structure (SKILL.md references supporting files)

### Lifecycle
1. User collects telemetry over time during normal work
2. User triggers review process when ready
3. Review process either creates new skill OR expands existing one

---

## MVP Scope

Keep it simple:

**Two modes:**
1. **Add to existing skill** - User specifies which skill to expand
2. **Create new skill** - Agent uses AskUserQuestion to get name and location

No hierarchy decisions or multi-level complexity. Just: pick a skill to update, or name a new one.

---

## Failure Capture

### Mechanism
Three layers, all using the same underlying logic:

1. **Skill** - Core capture logic
2. **Agent wrapper** - For programmatic callers (other agents invoke this)
3. **Slash command** - For human use (`/record-failure`)

### Data Captured

| Field | Required | Description |
|-------|----------|-------------|
| Target skill | Yes | Which skill to store this under (acts as "domain" - keeps failures isolated) |
| Timestamp | Yes | When the failure occurred |
| Problem explanation | Yes | Freeform narrative describing the failure |
| Resolution | No | How it was solved (can be added later) |

### Two Capture Paths

**Path A: Failure only**
- Problem occurs, not yet solved
- Record failure with explanation
- Resolution added later via separate call

**Path B: Failure + resolution**
- Problem occurred and was solved
- Record both together in one call

---

## Storage

### Location
- **Project-level:** `.failures/<skill-name>.md` in project root
- **Personal-level:** `~/.failures/<skill-name>.md`

### Format
- Markdown file
- Failures appended as entries
- Each entry contains timestamp, problem explanation, and optional resolution

### After Processing
- User is asked: "Keep or delete the failures file?"
- No automatic archiving - user decides each time

---

## Pattern Analysis & Skill Generation

- **User-triggered**: User decides when to process failures
- **Single step**: Analysis and skill generation happen together
- **Interactive**: Uses AskUserQuestion to gather input during processing
- **Output**: Creates new skill or expands existing one
