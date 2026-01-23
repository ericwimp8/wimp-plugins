# Workflow System Plan

## Current State

### Spec Planning - DONE

Orchestration lives in `workflow-system/commands/`:
- `/spec-clarification` - Clarifier loop (auto-fill) → Finisher loop (human-in-loop)
- `/spec-verification` - Fact-checker loop (auto-fix) → Verifier loop (human-in-loop)

Agents in `workflow-system/agents/`:
- `wfs-spec-plan-clarifier` - Autonomous gap-filler
- `wfs-spec-plan-finisher` - Gap-finder with human-in-loop (Phase 1/2)
- `wfs-spec-plan-fact-checker` - Autonomous fact-fixer
- `wfs-spec-plan-verifier` - Fact-verifier with human-in-loop (Phase 1/2)

---

## Implementation Planning - IN PROGRESS

Agents in `workflow-system/agents/`:
- `wfs-job-spec-creator` - Creates job-spec from detailed spec
- `wfs-impl-worker` - Creates implementation plans via deep codebase research
- `wfs-impl-checker` - Audits plans against job requirements

TODO: Orchestrator command to run the loop

### Job Spec Creation

Agent: `wfs-job-spec-creator`

Takes a detailed spec and reorganizes it into a jobs document:
- Single file output: `plans/[feature-slug]/[feature-slug]-job-spec.md`
- Jobs organized by dependency chain
- Bias toward fewer jobs (implementation agents have compaction protection)
- Three inviolable rules: no new ideas, no data loss, no semantic diffusion
- Structural context allowed (references between jobs, scope boundaries)

### Implementation Planning Per Job

Agents:
- `wfs-impl-worker` - Creates implementation plans via deep codebase research
- `wfs-impl-checker` - Audits plans against job requirements

Loop: `wfs-impl-worker` → `wfs-impl-checker` → auto-retry → human-in-loop

Each worker invocation receives:
- The entire job-spec document (full view of all jobs)
- The implementation directory (access to all previous implementation plans)
- The specific job identifier it's planning for

Worker detects retry mode by checking if the implementation plan file exists with a `## Previous Implementation Feedback` section. If present, it reads the feedback and addresses the issues.

Checker audits for: SPEC_MISMATCH, TECHNICAL, INCOMPLETE, PATTERN_ERROR, SCOPE_CREEP. On issues, writes feedback to `## Previous Implementation Feedback` section in the plan file.

Output: `plans/[feature-slug]/implementation/[job-slug].md`

---

## Implementation Execution - TODO

### Execution Per Job

- One agent per job, run sequentially
- Agent reads the implementation plan
- If amendments section exists → previous attempt failed, use amendments as guidance
- If no amendments → work from scratch
- Output: actual code changes

### Audit Per Job

- Audits completed work against the implementation plan
- Writes amendments directly into the plan file
- Returns pass/fail signal to orchestrator

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


build plan generator
---
this takes the output