# Workflow System

User uses Claude plan mode to create a plan.

---

## Workflow Paths

The orchestrators are independent and composable. There are two paths:

| Path | Orchestrators | When to use |
|------|---------------|-------------|
| Easy | implementation-planner → implementation-execution | Outline is good enough, just needs organising and doing |
| Complex | spec-planner → implementation-planner → implementation-execution | Needs detailed spec work first |

---

## Standard Feedback Loop Pattern

Used throughout the system: spec-planner loops, implementation planning, and implementation execution.

```
Worker Agent → Checker Agent → [AUTO-RETRY × N] → HUMAN-IN-LOOP
```

**How it works:**
1. Worker agent creates/updates the document
2. Checker agent audits and writes feedback directly into the document
3. Checker returns pass/fail signal to orchestrator
4. On fail: orchestrator calls worker again with same document path
5. Worker reads document - sees feedback at bottom - uses it to fix issues
6. Repeat up to N times automatically
7. After N auto-retries with failures, human enters the loop to provide guidance

**Key principle:** Feedback lives in the document, not passed through the orchestrator. Worker detects retry by presence of feedback in the document.

---

## Orchestrator: spec-planner ✓ DONE

**Purpose:** Take a user's plan mode output and refine it into a highly detailed spec document.

**Deliverable:** A detailed spec document at `plans/[feature-slug]/[feature-slug]-spec.md`

**Implementation:** Two slash commands in `workflow-system/commands/`:

### /spec-clarification

Handles gap-filling:
1. **Auto-fill loop** - `wfs-spec-plan-clarifier` runs up to N times, auto-filling gaps
2. **Human-in-loop** - `wfs-spec-plan-finisher` finds remaining gaps, presents to user, applies answers

### /spec-verification

Handles fact-checking:
1. **Auto-fix loop** - `wfs-spec-plan-fact-checker` runs up to N times, fixing obvious errors
2. **Human-in-loop** - `wfs-spec-plan-verifier` finds remaining issues, presents to user, applies corrections

---

## Orchestrator: implementation-planner

**Purpose:** Take a detailed spec and produce executable implementation plans.

**Deliverables:**
- Job-spec document: `plans/[feature-slug]/[feature-slug]-job-spec.md`
- Implementation plans: `plans/[feature-slug]/implementation/[job-slug].md`

### Step 1: Job Spec Creation

Agent: `wfs-job-spec-creator`

Takes the detailed spec and reorganizes it into a jobs document:
- Single file output (not multiple phase files)
- Jobs organized by dependency chain
- Bias toward fewer jobs - implementation agents have compaction protection
- Three inviolable rules: no new ideas, no data loss, no semantic diffusion
- Structural context allowed (references between jobs, scope boundaries)

### Step 2: Implementation Planning Per Job

Sequential agent loops, one per job.

Agents:
- `wfs-impl-worker` - Creates implementation plans via deep codebase research
- `wfs-impl-checker` - Audits plans against job requirements

Each `wfs-impl-worker` invocation receives:
- **Full job-spec document** - sees all jobs, understands the whole picture
- **Implementation directory** - access to all previous implementation plans
- **Target job identifier** - knows which job to plan

This full-context approach means:
- Planners understand dependencies naturally
- Planners can reference previous plans
- No information is lost between jobs

Uses the standard feedback loop pattern:
- `wfs-impl-worker` → `wfs-impl-checker` (auto-retry, then human-in-loop)

Worker detects retry by presence of `## Previous Implementation Feedback` section in the plan file. Checker audits for: SPEC_MISMATCH, TECHNICAL, INCOMPLETE, PATTERN_ERROR, SCOPE_CREEP.

**Output:** `plans/[feature-slug]/implementation/[job-slug].md`

---

## Orchestrator: implementation-execution

**Purpose:** Execute the implementation plans, doing the actual work for each job and auditing the results.

**Deliverable:** Completed implementation with audit reports/amendments appended to each job file.

Sequential agent loops, one per job.

### Implementation Agent

- Reads the implementation plan file
- If no amendments section → do the work from scratch
- If amendments section exists → previous attempt failed, use amendments as guidance
- Executes the tasks in the plan

### Audit Agent

- Audits the completed work against the implementation plan
- Writes amendments/audit report directly into the plan file
- Returns pass/fail signal to orchestrator

Uses the standard feedback loop pattern:
- Implementation Agent → Audit Agent (auto-retry, then human-in-loop)

---

## File Structure

```
plans/[feature-slug]/
├── [feature-slug]-spec.md              # Detailed spec (from spec-planner)
├── [feature-slug]-job-spec.md          # Jobs document (from job-spec-creator)
└── implementation/
    ├── [job-1-slug].md                 # Implementation plan for job 1
    ├── [job-2-slug].md                 # Implementation plan for job 2
    └── ...
```

---

## Key Design Decisions

### No Phases, Just Jobs

Original design had specs → phases → jobs. Simplified to specs → jobs.

Phases added complexity without benefit. Jobs organized by dependency chain achieve the same goal with less overhead.

### Implementation Agents Have Compaction Protection

Don't worry about job size. Agents can work through large jobs without losing track. Over-fragmentation (too many small jobs) is worse than slightly-too-large jobs.

Bias toward fewer jobs. Only split when dependencies require it.

### Full Context for Implementation Planning

Each implementation planner sees:
- The entire job-spec (all jobs, not just theirs)
- All previous implementation plans

This prevents information loss and lets planners make informed decisions about their work.
