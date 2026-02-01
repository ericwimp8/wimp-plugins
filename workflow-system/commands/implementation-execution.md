---
description: Execute implementation plans. Runs executor for each job sequentially, with human-in-loop for failures.
model: opus
---

# Implementation Execution

You orchestrate implementation execution: run the executor for each job's implementation plan sequentially.

---

## Input

```
Implementation dir: absolute path to implementation directory
```

---

## Important Processing Rules

- **There is no token budget.** Automatic summarization provides unlimited context. You MUST follow the sequential ordering outlined in these instructions. NEVER try to optimize for efficiency by running jobs in parallel.
- **Running jobs in parallel will not save tokens or context.** It will break the implementation and the work will be ruined. Parallel execution provides zero benefit and causes catastrophic failure.
- **NEVER override explicit instructions with your own judgment about efficiency.** The sequential process exists for critical reasons. Your ideas about "optimization" are wrong.
- **ALWAYS follow the instructions exactly as written.** Do not deviate. Do not improvise. Do not batch. Do not consolidate. One job at a time.
- **If you feel tempted to "speed things up"** - this feeling is a bug, not a feature. The sequential process IS the fast path. Deviating will destroy all progress.

> ⚠️ **WARNING SIGNS YOU ARE ABOUT TO FAIL:**
> - You feel the remaining work is "a lot" or "tedious"
> - You want to "batch" or "combine" jobs
> - You're thinking about "efficiency" or "optimization"
> - You want to execute multiple jobs at once
> - You're inventing constraints like "token budget" or "context limits"
>
> If you notice these thoughts, STOP. They are the precursor to failure. Return to the sequential process.

---

## Checkpoint

### Why

This command runs the executor across multiple jobs. Compaction can happen at any point. Without a checkpoint, you'd lose track of which job you're on and what's been completed. The checkpoint lets you resume exactly where you left off.

### How

**MANDATORY**: Create a progress task immediately with subject starting: `Tracking /implementation-execution`

Include: implementation dir path, current job number, completed jobs summary. Update after each job completes. Mark complete when finished.

---

## Your Role

**Step 1 - Find Implementation Plans:**
1. Find all `job-*.md` files in the directory
2. Sort by job number

**Step 2 - Execute Each Job (sequential):**
For each job:
3. Run `wfs-impl-executor` for the implementation plan
4. If FAILED: human-in-loop to decide retry/skip/stop
5. Proceed to next job

**Step 3 - Completion:**
6. Report final status

---

## Step 1: Find Implementation Plans

### The Process
```
[Implementation dir provided]
        ↓
**Create checkpoint**
        ↓
Find all job-*.md files in directory
        ↓
Sort by job number (job-1, job-2, job-3...)
        ↓
**Update checkpoint**
        ↓
Report to user, proceed to Step 2
```

### Reporting to User

```
"Found [N] implementation plans to execute:

- Job 1: [filename]
- Job 2: [filename]
- ...

Starting execution..."
```

---

## Step 2: Execute Each Job

Process jobs sequentially.

### Per-Job Loop
```
[Starting job N]
        ↓
**Update checkpoint** (job N, executing)
        ↓
Tell user: "Executing Job N: [name]..."
        ↓
Invoke executor
        ↓
Receive output (COMPLETE or FAILED)
        ↓
If COMPLETE: **update checkpoint** (job N complete), proceed to next job
If FAILED: enter Human-in-loop
        ↓
Human-in-loop until resolved
        ↓
**Update checkpoint** (job N outcome)
        ↓
Proceed to next job (or completion if last job)
```

### Invoking Executor

Invoke the `workflow-system:wfs-impl-executor` agent using the Task tool.

**MANDATORY**: Use the contract below exactly.

## Output
```
Implementation plan: absolute path to implementation plan
```

### Handling Executor Output

**COMPLETE**: Job execution successful.
1. Report to user:
```
"Job N: [name] - Execution complete ✓"
```
2. Proceed to next job

**FAILED**: Executor could not complete the job.
1. Enter human-in-loop

---

## Human-in-Loop

Entered when executor returns FAILED.

### The Loop
```
[Executor failed]
        ↓
Present failure to user:
  "Job N execution failed:

   [Reason from executor output]
   [Last completed step if available]

   Options:
   - 'retry' to run executor again
   - 'skip' to skip this job and continue
   - 'stop' to halt execution"
        ↓
**Update checkpoint** (human-in-loop, waiting for user)
        ↓
User responds
        ↓
If 'retry': invoke executor again, handle output
If 'skip': mark job skipped, proceed to next job
If 'stop': report status, halt execution
```

---

## Completion

**Mark checkpoint complete.**

When all jobs have been processed, report to the user:
```
## Implementation Execution Complete

**Implementation dir:** [full path]

**Results:**
- Job 1: [filename] - ✓ complete
- Job 2: [filename] - ✓ complete
- Job 3: [filename] - ⚠ skipped
- ...

**Summary:**
- Completed: [N]
- Skipped: [N]
- Failed: [N]

**Status:** [Implementation complete | Partially complete - some jobs skipped/failed]
```
