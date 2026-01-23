---
description: Run the verification loop on a spec. Auto-fixes factual errors, then human-in-loop for remaining issues.
model: opus
---

# Spec Verification

You orchestrate the verification loop: autonomous fact-fixing followed by human-in-loop for remaining inaccuracies.

---

## Input

```
Document: absolute path to spec file
```

---

## Checkpoint

### Why

This command runs multi-step loops that can be interrupted by compaction or failure. Without a checkpoint, you'd lose track of progress—document path, which phase you're in, iteration counts, agent IDs for resumption. The checkpoint task lets you (or a parent command) pick up exactly where you left off.

### How

**MANDATORY**: Create a progress task immediately with subject starting: `Tracking /spec-verification`

Keep it updated throughout with enough context to fully resume—document path, current phase, iteration counts, agent IDs. Update at every significant step. Mark complete when finished.

---

## Your Role

**Phase 1 - Auto-fix:**
1. Run `wfs-spec-plan-fact-checker` to autonomously fix obvious factual errors
2. Repeat up to 4 times (or until COMPLETE)

**Phase 2 - Human-in-loop:**
3. Run `wfs-spec-plan-verifier` Phase 1 to find remaining inaccuracies
4. Present findings to user
5. Collect answers, resume Phase 2 to apply them
6. Repeat until VERIFIED

---

## Phase 1: Auto-fix Loop

### The Loop
```
[Document provided]
        ↓
**Create checkpoint**
        ↓
Tell user: "Running fact-checker to auto-fix obvious errors..."
        ↓
Invoke fact-checker
        ↓
Receive output (CHANGES or COMPLETE)
        ↓
**Update checkpoint**
        ↓
If CHANGES: output response verbatim, invoke fact-checker again
If COMPLETE: exit loop
        ↓
Repeat up to 4 times (or until COMPLETE)
        ↓
Tell user: "Auto-fix complete. Proceeding to human review."
        ↓
**Update checkpoint**
        ↓
Proceed to Phase 2
```

### Invoking Fact-Checker

Invoke the `workflow-system:wfs-spec-plan-fact-checker` agent using the Task tool.

**MANDATORY**: Use the contract below exactly.

## Output
```
Document: absolute path to spec file
```

### Handling Fact-Checker Output

**Track across iterations:**
- Total corrections
- Total added to Open Questions

**Exit conditions:**
- `COMPLETE` returned (no more errors to fix)
- `FAILED` returned (report error to user)
- 4 iterations completed (prevent infinite loops)

**After loop completes**, summarize for user:
```
"Fact-checker completed [N] passes:
- Corrected [X] factual errors automatically
- Added [Y] ambiguous items to Open Questions

Proceeding to human review for remaining claims."
```

Then proceed to Phase 2 (Human-in-loop).

---

## Phase 2: Human-in-loop

### The Loop
```
[Auto-fix complete]
        ↓
Tell user: "Starting human review to verify remaining claims."
        ↓
Invoke NEW verifier (Phase 1)
        ↓
**Update checkpoint**
        ↓
Receive verifier output (Corrections + Questions + Status)
        ↓
If Status is VERIFIED → Exit, report success
        ↓
Present verifier output to user VERBATIM (DO NOT SUMMARIZE - copy full output exactly), then add:
  "For corrections: confirm, reject with reason, reject, or modify.
   For questions: provide your answer or skip."
        ↓
User responds
        ↓
**Update checkpoint**
        ↓
Format answers for verifier (see Formatting Answers below)
        ↓
RESUME verifier (Phase 2) with formatted answers
        ↓
Receive report (Result, Corrections applied, Added to Open Questions, Skipped)
        ↓
**Update checkpoint**
        ↓
Present to user:
  "Spec updated.

   Corrections applied: [count]
   [List corrections from report]

   Added to Open Questions: [count]
   [List added from report]

   Skipped: [count]
   [List skipped from report]

   Review: [full path to spec]"
        ↓
Invoke NEW verifier (fresh eyes, Phase 1)
        ↓
Repeat
```

### Invoking Verifier (Phase 1)

Invoke the `workflow-system:wfs-spec-plan-verifier` agent using the Task tool.

**MANDATORY**: Use the contract below exactly.

## Output
```
Document: absolute path to spec file
```

**Capture the `agent_id` from the Task tool result** - you'll need it for Phase 2.

**Handle response:**
- If Status is `VERIFIED` → exit loop, report success
- If Status is `NEEDS_CORRECTION` → present to user verbatim, continue loop

### Formatting Answers

After the user responds, format their answers for the verifier Phase 2 resume.

**Format template:**
```
Document: {document_path}

Corrections:
- {id}: {title} → {response}

Questions:
- {id}: {title} → {response}
```

Where:
- `{document_path}` - Absolute path to the spec
- `{id}` - The identifier from Phase 1 output (C1, C2, Q1, Q2, etc.)
- `{title}` - Brief description from Phase 1 output
- `{response}` - One of:
  - For corrections: `confirmed` | `rejected: [reason]` | `rejected` | `modified: [user's version]`
  - For questions: `[user's answer]` | `unanswered`

**Example:**
```
Document: /path/to/plans/feature-name/feature-name-spec.md

Corrections:
- C1: UserService.getProfile return type → confirmed
- C2: API endpoint path → rejected: Path is correct, I checked manually
- C3: Error handler location → modified: Error handler is in utils/errors.ts, not lib/errors.ts

Questions:
- Q1: Database table name → The table is called user_profiles, not users
- Q2: Cache strategy → unanswered
```

### Resuming Verifier (Phase 2)

Resume the verifier using the Task tool with the `resume` parameter set to the agent_id from Phase 1.

The agent retains full context from Phase 1 - just send the formatted answers.

## Output
```
Document: {document_path}

Corrections:
{formatted_corrections}

Questions:
{formatted_questions}
```

**Handle response:**
- Parse: Result (`UPDATED` | `NO_CHANGES`), Corrections applied count, Added to Open Questions count, Skipped count
- Present summary to user
- Invoke NEW verifier (Phase 1) for next iteration

### Exit Condition

The loop ends when verifier Phase 1 returns:
- **VERIFIED**: All verifiable claims checked out (or no verifiable claims found)

---

## Completion

**Mark checkpoint complete.**

When the loop completes, report to the user:
```
## Verification Complete

**Document:** [full path to spec]

**Summary:**
- Auto-fixed [X] factual errors across [N] passes
- User resolved [Y] corrections and [Z] questions
- [N] items remain in Open Questions (if any)

**Status:** Spec is verified and ready for implementation planning

**Next step:** Proceed to implementation planning
```
