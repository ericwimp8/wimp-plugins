# Workflow System

User uses Claude plan mode to create a plan.

---

## Workflow Paths

The orchestrators are independent and composable. There are two paths:

| Path | Orchestrators | When to use |
|------|---------------|-------------|
| Easy | implementation-planner → implementation-execution | Outline is good enough, just needs organising and doing |
| Complex | spec-planner → implementation-planner → implementation-execution | Needs detailed spec work first |

Size (small/medium/large) falls out naturally from the sizing judgments in implementation-planner. It produces:
- 1 phase with 1 job (small work)
- 1 phase with multiple jobs (medium work)
- Multiple phases with multiple jobs (large work)

No size labels or signals needed - the structure reflects the actual work.

---

## Standard Feedback Loop Pattern

Used throughout the system: spec-planner loops, implementation planning, and implementation execution.

**Note:** Agent names referenced throughout (Prospector, Assayer, Deep-drill, Slag-check, etc.) are examples of similar functionality from existing systems. They will be rewritten with differences for this workflow system.

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

## Orchestrator: spec-planner

**Purpose:** Take a user's plan mode output and refine it into a highly detailed spec document.

**Deliverable:** A detailed spec document covering everything down to the smallest detail.

This isn't exactly what we need but it is a good example of how the loop works.

### Loops

Uses the standard feedback loop pattern (see below):
- Prospector → Assayer (auto-retry, then human-in-loop) *(example - will be rewritten)*
- Refiner → Touchstone (auto-retry, then human-in-loop) *(example - will be rewritten)*

---

## Orchestrator: implementation-planner

**Purpose:** Take a detailed spec and break it down into executable implementation plans organised by phase and job.

**Deliverables:**
- Phase-spec documents: `plans/[feature-slug]/phase-specs/[feature-slug]-[phase-slug]-spec.md`
- Job-spec documents: `plans/[feature-slug]/phase-job-specs/[feature-slug]-[phase-slug]-job-spec.md`
- Implementation plans: `plans/[feature-slug]/phase-implementation/[phase-slug]/[job-slug].md`

**Flexibility requirement:** This orchestrator needs to handle the full range - from a highly detailed spec covering a huge feature add, down to a plan mode spec that adds a button to a header. The sizing judgments at each step should make this work naturally without special handling.

At this point we have a highly detailed spec document detailing how everything should be done down to the smallest detail.

### Phase Separation

This is where our new functionality comes in. At this point we need to map the spec into phase-spec documents.

**Sizing judgment:** First the agent makes a judgment: is this trivial enough for one agent to handle in one go? Use criteria/validation rules/guidelines for this decision. If yes → create one phase-spec. If no → split into multiple.

We need an agent that will do this. Each phase-spec needs to be a vertical slice of the spec, a self contained unit of work with as little dependency on other phases as possible.

**Examples:**
- If there are data models to make they can be made first
- If there is a new service to be made that can be made in isolation without affecting anything else, make that first

Everything needs to be checked for its dependencies in implementation and those dependencies will dictate what goes in what phase.

**Output:** `plans/[feature-slug]/phase-specs/[feature-slug]-[phase-slug]-spec.md`

If there were 9 phases then the folder will have 9 documents. No data should be lost in this process and no ideas should be added in this process. We strictly want a reorganisation of the spec into workable phases.

### Job Breakdown

Now we need another agent that organises the phases into jobs. Jobs are a logical group of tasks that need to be completed for a smaller goal.

This is just organising work - first we broke it down into phases and now each phase needs to be broken down into jobs.

**Job sizing rules:**
- Jobs should be sized by rules and criteria
- Can have as many jobs as needed in a phase but bias against many small jobs
- For small work this naturally results in 1 phase with 1-2 jobs

No data should be lost in this process and no ideas should be added in this process. We strictly want a reorganisation of the spec into workable jobs.

**Output:** `plans/[feature-slug]/phase-job-specs/[feature-slug]-[phase-slug]-job-spec.md`

### Implementation Planning

Now each phase-job-spec needs to be processed into a detailed implementation plan that has its own document.

Uses the standard feedback loop pattern:
- Deep-drill → Slag-check (auto-retry, then human-in-loop) *(example - will be rewritten)*

**Deep-drill** *(example - will be rewritten)*
- Given a document path as argument
- If document is empty → start from scratch
- If document has feedback at bottom → another agent failed, use the feedback to do it properly
- Output needs to be job with tasks matching wf-job.md format

**Slag-check** *(example - will be rewritten)*
- Audits the plan
- Writes feedback directly into the document (not back to orchestrator)
- Returns pass/fail signal to orchestrator

**Output:** `plans/[feature-slug]/phase-implementation/[phase-slug]/[job-slug].md`

The deliverable here is going to be a folder with folders in it, each folder will have a file for each job of the phase.

At this point we now have a folder with a folder for each phase, in each folder is files, each file contains an implementation plan for a job.

---

## Orchestrator: implementation-execution

**Purpose:** Execute the implementation plans, doing the actual work for each job and auditing the results.

**Deliverable:** Completed implementation with audit reports/amendments appended to each job file.

Now we need to do implementation for each phase which is an orchestrator - it should launch an agent to do a job file.

Uses the standard feedback loop pattern:
- Implementation Agent → Audit Agent (auto-retry, then human-in-loop) *(example - will be rewritten)*

### Implementation Agent *(example - will be rewritten)*

- Reads the job file
- If no amendments section → do the work from scratch
- If amendments section exists → another agent already attempted, use the amendments as guidance to finish properly
- Executes the tasks in the job

### Audit Agent *(example - will be rewritten)*

- Audits the completed work against the job spec
- Writes amendments/audit report directly into the job file
- Returns pass/fail signal to orchestrator

---
