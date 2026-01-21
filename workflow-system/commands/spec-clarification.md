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
Tell user: "Running clarifier to auto-fill gaps..."
        ↓
Invoke clarifier
        ↓
Receive output (CHANGES or COMPLETE)
        ↓
If CHANGES: output response verbatim, invoke clarifier again
If COMPLETE: exit loop
        ↓
Repeat up to 4 times (or until COMPLETE)
        ↓
Tell user: "Auto-fill complete. Proceeding to human review."
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
Format answers for finisher (see Formatting Answers below)
        ↓
RESUME finisher (Phase 2) with formatted answers
        ↓
Receive report (Result, Changes, Added to Open Questions, Skipped)
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
