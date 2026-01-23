---
description: Run the clarification loop on a spec. Auto-fills gaps, then human-in-loop for remaining issues.
model: opus
---

# Spec Clarification

You orchestrate the clarification loop: autonomous gap-filling followed by human-in-loop for remaining gaps.

---

## Input

```
Document: absolute path to spec file
```

---

## Important Processing Rules

- **There is no token budget.** Automatic summarization provides unlimited context. You MUST follow the sequential ordering outlined in these instructions. NEVER try to optimize for efficiency by running tasks in parallel.
- **Running tasks in parallel will not save tokens or context.** It will break the implementation and the work will be ruined. Parallel execution provides zero benefit and causes catastrophic failure.
- **NEVER override explicit instructions with your own judgment about efficiency.** The sequential process exists for critical reasons. Your ideas about "optimization" are wrong.
- **ALWAYS follow the instructions exactly as written.** Do not deviate. Do not improvise. Do not batch. Do not consolidate. One phase at a time. One stage at a time.
- **If you feel tempted to "speed things up"** - this feeling is a bug, not a feature. The sequential process IS the fast path. Deviating will destroy all progress.

> ⚠️ **WARNING SIGNS YOU ARE ABOUT TO FAIL:**
> - You feel the remaining work is "a lot" or "tedious"
> - You want to "batch" or "combine" phases
> - You're thinking about "efficiency" or "optimization"
> - You want to consolidate your todo list
> - You're inventing constraints like "token budget" or "context limits"
>
> If you notice these thoughts, STOP. They are the precursor to failure. Return to the sequential process.

---

## Checkpoint

### Why

This command runs multi-step loops that can be interrupted by compaction or failure. Without a checkpoint, you'd lose track of progress—document path, which phase you're in, iteration counts, agent IDs for resumption. The checkpoint task lets you (or a parent command) pick up exactly where you left off.

### How

**MANDATORY**: Create a progress task immediately with subject starting: `Tracking /spec-clarification`

Keep it updated throughout with enough context to fully resume—document path, current phase, iteration counts, agent IDs. Update at every significant step. Mark complete when finished.

---

## Your Role

**Phase 1 - Auto-fill:**
1. Run `wfs-spec-plan-clarifier` to autonomously fill gaps
2. Repeat up to 4 times (or until COMPLETE)

**Phase 2 - Human-in-loop:**
3. Run `wfs-spec-plan-finisher` Phase 1 to find remaining gaps
4. Present findings to user
5. Collect answers, resume Phase 2 to apply them
6. Repeat until COMPLETE

---

## Phase 1: Auto-fill Loop

### The Loop
```
[Document provided]
        ↓
**Create checkpoint**
        ↓
Tell user: "Running clarifier to auto-fill gaps..."
        ↓
Invoke clarifier
        ↓
Receive output (CHANGES or COMPLETE)
        ↓
**Update checkpoint**
        ↓
If CHANGES: output response verbatim, invoke clarifier again
If COMPLETE: exit loop
        ↓
Repeat up to 4 times (or until COMPLETE)
        ↓
Tell user: "Auto-fill complete. Proceeding to human review."
        ↓
**Update checkpoint**
        ↓
Proceed to Phase 2
```

### Invoking Clarifier

Invoke the `workflow-system:wfs-spec-plan-clarifier` agent using the Task tool.

**MANDATORY**: Use the contract below exactly.

## Output
```
Document: absolute path to spec file
```

### Handling Clarifier Output

**Track across iterations:**
- Total implementations
- Total added to Open Questions
- Total resolved from Open Questions

**Exit conditions:**
- `COMPLETE` returned (no more gaps to find)
- 4 iterations completed (prevent infinite loops)

**After loop completes**, summarize for user:
```
"Clarifier completed [N] passes:
- Implemented [X] solutions automatically
- Added [Y] items to Open Questions
- Resolved [Z] existing Open Questions

Proceeding to human review for remaining gaps."
```

Then proceed to Phase 2 (Human-in-loop).

---

## Phase 2: Human-in-loop

### The Loop
```
[Auto-fill complete]
        ↓
Tell user: "Starting human review to find remaining gaps."
        ↓
Invoke NEW finisher (Phase 1)
        ↓
**Update checkpoint**
        ↓
Receive finisher output (Implemented + Suggestions + Open Questions + Status)
        ↓
If Status is COMPLETE → Exit, report success
        ↓
Present finisher output to user VERBATIM (DO NOT SUMMARIZE - copy full output exactly), then add:
  "For suggestions: confirm, reject with reason, reject, or modify.
   For questions: provide your answer or skip."
        ↓
User responds
        ↓
**Update checkpoint**
        ↓
Format answers for finisher (see Formatting Answers below)
        ↓
RESUME finisher (Phase 2) with formatted answers
        ↓
Receive report (Result, Changes, Added to Open Questions, Skipped)
        ↓
**Update checkpoint**
        ↓
Present to user:
  "Spec updated.

   Changes: [count]
   [List changes from report]

   Added to Open Questions: [count]
   [List added from report]

   Skipped: [count]
   [List skipped from report]

   Review: [full path to spec]"
        ↓
Invoke NEW finisher (fresh eyes, Phase 1)
        ↓
Repeat
```

### Invoking Finisher (Phase 1)

Invoke the `workflow-system:wfs-spec-plan-finisher` agent using the Task tool.

**MANDATORY**: Use the contract below exactly.

## Output
```
Document: absolute path to spec file
```

**Capture the `agent_id` from the Task tool result** - you'll need it for Phase 2.

**Handle response:**
- If Status is `COMPLETE` → exit loop, report success
- If Status is `NEEDS_CLARIFICATION` → present to user verbatim, continue loop

### Formatting Answers

After the user responds, format their answers for the finisher Phase 2 resume.

**Format template:**
```
Suggestions:
- {id}: {title} → {response}

Questions:
- {id}: {title} → {response}
```

Where:
- `{id}` - The identifier from Phase 1 output (S1, S2, Q1, Q2, etc.)
- `{title}` - Brief description from Phase 1 output
- `{response}` - One of:
  - For suggestions: `confirmed` | `rejected: [reason]` | `rejected` | `modified: [user's version]`
  - For questions: `[user's answer]` | `unanswered`

**Example:**
```
Suggestions:
- S1: Error handling pattern → confirmed
- S2: Service location → rejected: Current location is intentional
- S3: API format → modified: Use JSON-RPC instead of REST

Questions:
- Q1: Cache strategy → Use Redis with 5-minute TTL
- Q2: Auth mechanism → unanswered
```

### Resuming Finisher (Phase 2)

Resume the finisher using the Task tool with the `resume` parameter set to the agent_id from Phase 1.

The agent retains full context from Phase 1 - just send the formatted answers.

## Output
```
Suggestions:
{formatted_suggestions}

Questions:
{formatted_questions}
```

**Handle response:**
- Parse: Result (`UPDATED` | `NO_CHANGES`), Changes count, Added to Open Questions count, Skipped count
- Present summary to user
- Invoke NEW finisher (Phase 1) for next iteration

### Exit Condition

The loop ends when finisher Phase 1 returns:
- **COMPLETE**: No blockers remain - spec is implementation-ready

---

## Completion

**Mark checkpoint complete.**

When the loop completes, report to the user:
```
## Clarification Complete

**Document:** [full path to spec]

**Summary:**
- Auto-filled [X] gaps across [N] passes
- User resolved [Y] suggestions and [Z] questions
- [N] items remain in Open Questions (if any)

**Status:** Ready for verification (or implementation if skipping verification)

**Next step:** Run `/spec-verification` to verify facts, or proceed to implementation planning
```
