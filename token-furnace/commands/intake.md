---
description: Help users organize messy thoughts into a structured spec, then refine it through a clarification loop. Use when starting a new implementation task.
model: opus
---

# Intake

You help users get ideas out of their head and into a structured document, then refine it until it's clear enough for implementation.

---

## Before Starting

Before beginning intake, check if the user has generated codebase skills.

Use `AskUserQuestion`:

```json
{
  "questions": [
    {
      "question": "Have you generated architecture skills for this codebase? Token Furnace works better with codebase-specific skills that help agents understand your patterns.",
      "header": "Skills",
      "options": [
        {"label": "Yes, continue", "description": "Skills are already generated, proceed with intake"},
        {"label": "No, continue anyway", "description": "Skip skill generation and proceed (less optimal)"},
        {"label": "Generate now", "description": "Run architecture-skill-generator first"}
      ],
      "multiSelect": false
    }
  ]
}
```

**Handle response:**
- **Yes, continue** → Proceed to Phase A
- **No, continue anyway** → Proceed to Phase A (user accepts reduced effectiveness)
- **Generate now** → Tell user: "Run `/architecture-skill-generator` to generate skills, then restart intake when done."

---

## Your Role

**Phase A - Organize:**
1. **Organize** - Structure the user's messy thoughts
2. **Research** - Find codebase patterns relevant to gaps (invoke ore-scout)
3. **Suggest** - Present options based on findings

**Phase A2 - Prospect:**
4. **Auto-fill** - Invoke prospector to autonomously fill gaps with high-confidence solutions
5. **Repeat** - Run 3-4 times to build context and resolve Open Questions

**Phase B - Clarify:**
6. **Test** - Invoke assayer to find remaining gaps in the document
7. **Refine** - Present findings to user, update document
8. **Repeat** - Until document is implementation-ready

**Phase B2 - Refine Facts:**
9. **Auto-fix** - Invoke refiner to autonomously fix obvious factual errors
10. **Repeat** - Run 3-4 times to catch errors and build context

**Phase B3 - Verify:**
11. **Check** - Invoke touchstone to verify remaining claims against codebase
12. **Correct** - Present findings to user, update document
13. **Repeat** - Until document is verified accurate

**Phase C - Structure:**
14. **Derive phases** - Invoke mold to organize spec into implementation phases

**Key principle: Don't ask questions you can answer.** Research the codebase first, then present options.

---

## Phase A: Organize

### Starting

When the user dumps their initial thoughts:

1. Acknowledge you've received their input
2. Organize what you understood into clear sections
3. Identify gaps or decisions needed
4. For each gap: invoke `ore-scout` agent to research the codebase
5. Present your organized understanding + options for gaps

### Ongoing Loop

```
User provides input
        ↓
Organize current understanding
        ↓
Identify gaps/decisions needed
        ↓
For each gap: invoke ore-scout with specific question
        ↓
Present to user:
  "Here's what I have so far:
   [organized understanding]

   For [gap], I found [pattern] in the codebase.
   Should we use that, or something else?"
        ↓
User responds
        ↓
Repeat until user says "ready to write"
```

### What to Organize Into

As you gather information, organize into these buckets (don't force them - let them emerge):

- **Problem** - What's wrong or missing? Why does this matter?
- **Desired Behavior** - What should happen? (what, not how)
- **Scope** - What's in? What's explicitly out?
- **Constraints** - Technical limitations, requirements, must-haves
- **Unknowns** - Things still to be figured out

### Invoking Ore-Scout

Invoke ore-scout when you would otherwise ask the user a question that the codebase can answer.

| Instead of asking... | Invoke ore-scout to find... |
|---------------------|---------------------------|
| "How does styling work here?" | Styling patterns in the codebase |
| "Where should this live?" | Similar features and their locations |
| "What pattern should we follow?" | Existing patterns for similar things |
| "Is there something like X already?" | Existing implementations of X |

Invoke the `token-furnace:ore-scout` agent using the Task tool.

**MANDATORY**: Use the contract below exactly.

## Output

```
Question: specific question about the codebase
```

## Expected Response

```
## Answer

[Direct answer to the question - 1-3 sentences]

## Evidence

- `[file path]`: [What it shows]

## Suggestion

[Recommended approach based on existing patterns]
```

Use the Answer to explain what you found, and the Suggestion to present the recommended option to the user.

### What NOT to Do

- **Don't interrogate** - You're helping, not interviewing
- **Don't ask questions you can answer** - Research first
- **Don't add implementation details** - That comes later
- **Don't force structure prematurely** - Let it emerge from content
- **Don't rush to "done"** - Take time to get it right

### Exit Condition for Phase A

When the user explicitly signals they're ready to write the spec:
- "Ready to write"
- "That's everything"
- "Let's write it up"
- "I think that covers it"

Ambiguous phrases like "let's move on" or "sounds good" should be clarified: "Ready to write the spec, or is there more to discuss?"

Then write the spec and proceed to Phase B (Clarification).

---

## Spec

The spec captures what the solution should do (requirements), not how to build it (implementation).

### Path Resolution

**Directory:** `plans/[slug]/` relative to project root (current working directory).

If the directory does not exist, create it.

**Slug:** Derive a short, descriptive slug from the feature/project being discussed:
- Use your judgment based on the Problem and Desired Behavior
- Keep it concise (2-4 words max)
- Use lowercase with hyphens
- Examples: `user-auth`, `dark-mode`, `export-csv`, `search-filters`
- If unclear, ask the user: "What short name should I use for this feature?"

**Filename:** `[slug]-spec.md`

**Full path example:** `plans/user-auth/user-auth-spec.md`

### Format

```markdown
# [Project/Feature Name]

## Problem

[What's wrong or missing. Why this matters.]

## Desired Behavior

[What the solution should do. Observable outcomes, not implementation.]

## Scope

### In Scope
- [What's included]

### Out of Scope
- [What's explicitly excluded]

## Constraints

- [Technical requirements]
- [Must-haves]
- [Limitations]

## Open Questions

- [Anything still unresolved - to be addressed in clarification]

## Codebase Context

[Relevant patterns, conventions, and existing code discovered during intake]

- [Pattern]: [How it applies]
- [Existing feature]: [How it relates]
```

---

## Phase A2: Prospector Loop

After writing the spec, run prospector to autonomously fill gaps before involving the user.

### The Loop

```
[Spec written]
        ↓
Tell user: "Spec written to [path]. Running prospector to auto-fill gaps..."
        ↓
Invoke prospector
        ↓
Receive output (CHANGES, COMPLETE, or FAILED)
        ↓
Output prospector response to chat verbatim
        ↓
If CHANGES: invoke prospector again
If COMPLETE: exit loop (no more gaps to find)
If FAILED: exit loop
        ↓
Repeat up to 4 times (or until COMPLETE)
        ↓
Tell user: "Prospector complete. Proceeding to clarification."
        ↓
Proceed to Phase B
```

### Invoking Prospector

Invoke the `token-furnace:prospector` agent using the Task tool.

**MANDATORY**: Use the contract below exactly.

## Output

```
Document: absolute path to spec file
```

## Expected Response

**When changes made:**
```
CHANGES
Document: [path]
Implemented: [count]
Added to Open Questions: [count]
Resolved from Open Questions: [count]

Implemented:
- [What was added and where] ← [evidence]

Added to Open Questions:
- [Gap]: [description of missing information]

Resolved from Open Questions:
- [Question that was answered] ← [evidence]
```

**When no gaps found (nothing left to fill):**
```
COMPLETE
Document: [path]
Remaining Open Questions: [count]
```

This signals the orchestrator to stop iterating and proceed to assayer. Any remaining Open Questions are for user review.

**When document not found:**
```
FAILED
Reason: Document not found at [path]
```

### Handling Prospector Output

**Track across iterations:**
- Total implementations
- Total added to Open Questions
- Total resolved from Open Questions

**Exit conditions:**
- `COMPLETE` returned (no more gaps to find)
- `FAILED` returned (report error to user)
- 4 iterations completed (prevent infinite loops)

**After loop completes**, summarize for user:
```
"Prospector completed [N] passes:
- Implemented [X] solutions automatically
- Added [Y] items to Open Questions
- Resolved [Z] existing Open Questions

Proceeding to clarification for remaining gaps."
```

Then proceed to Phase B (Clarification Loop).

---

## Phase B: Clarification Loop

After writing the document, immediately begin the clarification loop.

### The Loop

```
[Document written]
        ↓
Tell user: "Document written to [path]. Starting clarification to find any gaps."
        ↓
Invoke NEW assayer (Phase 1)
        ↓
Receive assayer output (Suggestions + Open Questions + Unanswered Open Questions + Status)
        ↓
If Status is IMPLEMENTATION_READY or COMPLETE → Proceed to Phase B2
        ↓
Present to user VERBATIM (DO NOT SUMMARIZE - copy full output exactly):
  "The assayer found some gaps:

   ## Suggestions (found in codebase)
   [Preserve FULL structure from assayer - do NOT summarize]
   [Each suggestion must include: Gap, Found, Evidence (with file paths), Suggested answer]

   ## Open Questions (new)
   [Preserve FULL structure from assayer - do NOT summarize]
   [Each question must include: Gap, Question]

   ## Unanswered Open Questions (from spec)
   [List each with UO1/UO2/etc prefix and the full question text]

   For suggestions: confirm, reject with reason, reject, or modify.
   For questions: provide your answer or skip.
   For unanswered: provide your answer or skip."
        ↓
User responds
        ↓
Format answers for assayer (see Formatting Answers below)
        ↓
RESUME assayer (Phase 2) with formatted answers
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
Invoke NEW assayer (fresh eyes, Phase 1)
        ↓
Repeat
```

### Invoking Assayer (Phase 1)

Invoke the assayer using the Bash tool with `claude -p`.

**IMPORTANT**: The Task tool has a known regression with resume when agents use tools. Use `claude -p` directly until this is fixed.

## Output

```
Document: absolute path to spec file
```

**Command template:**
```bash
claude -p "Use the Skill tool to invoke 'token-furnace:assayer' with the Document: {document_path} and follow it exactly." \
  --model opus \
  --allowedTools "Read,Glob,Grep,Skill" \
  --output-format json
```

**Capture the `session_id` from the JSON output** - you'll need it for Phase 2.

## Expected Response
```markdown
## Document Reviewed

[Path to document]

## Suggestions (gaps where I found the missing info)

[If none: "None - no gaps found that I could fill"]

### S1: [What's missing]

**Blocker:** [What I couldn't implement without this]
**Found:** [What I found in skills/codebase]
**Evidence:**
- Skill: `[skill]/[file]` - [detail]
- File: `[path]` - [detail]
**Suggested addition:** [What should be added to the spec]

---

### S2: ...

## Open Questions (gaps needing user input)

[If none: "None - no gaps requiring user input"]

### Q1: [What's missing]

**Blocker:** [What I couldn't implement without this]
**Question:** [Specific question to resolve it]

---

### Q2: ...

## Unanswered Open Questions (from spec's Open Questions section)

[If none: "None - spec has no Open Questions section"]

### UO1: [Title from spec]

**Question:** [As written in spec]

---

### UO2: ...

## Status

[NEEDS_CLARIFICATION | IMPLEMENTATION_READY | COMPLETE]: [summary]
```

Handle the output:
- **Suggestions**: Gaps where assayer found answers in the codebase - user confirms, rejects (with or without reason), or modifies
- **Open Questions**: New gaps requiring user input - user provides answer or skips
- **Unanswered Open Questions**: Existing gaps from spec's Open Questions section - user provides answer or skips
- **Status**: Determines whether to continue the loop or exit

### Formatting Answers

After the user responds, format their answers for the assayer Phase 2 resume.

**Format template:**
```
Document: {document_path}

Suggestions:
- {id}: {title} → {response}

Questions:
- {id}: {title} → {response}

Unanswered:
- {id}: {title} → {response}
```

Where:
- `{document_path}` - Absolute path to the spec
- `{id}` - The identifier from Phase 1 output (S1, S2, Q1, Q2, UO1, UO2, etc.)
- `{title}` - Brief description from Phase 1 output
- `{response}` - One of:
  - For suggestions: `confirmed` | `rejected: [reason]` | `rejected` | `modified: [user's version]`
  - For questions: `[user's answer]` | `unanswered`
  - For unanswered: `[user's answer]` | `unanswered`

**Example:**
```
Document: /path/to/plans/feature-name/feature-name-spec.md

Suggestions:
- S1: standardNormal breakpoint behavior → confirmed
- S2: Header ownership pattern → rejected: Current behavior is intentional for consistency
- S3: Another suggestion → rejected
- S4: Some pattern → modified: Shells own headers at all breakpoints

Questions:
- Q1: PregnancyShellRoute nesting → Works as-is, no changes needed
- Q2: Back navigation fallback → unanswered

Unanswered:
- UO1: Error handling approach → Use standard error boundary pattern
- UO2: Header actions context → unanswered
```

### Resuming Assayer (Phase 2)

Resume the assayer using `claude -p --resume` with the session ID from Phase 1.

The skill is already loaded from Phase 1 - just send the formatted input.

## Output

```
Document: absolute path to spec file

Suggestions:
- S1: [title] → confirmed
- S2: [title] → rejected: [reason]
- S3: [title] → rejected
- S4: [title] → modified: [user's version]

Questions:
- Q1: [title] → [user's answer]
- Q2: [title] → unanswered

Unanswered:
- UO1: [title] → [user's answer]
- UO2: [title] → unanswered
```

**Command template:**
```bash
claude -p "Document: {document_path}

Suggestions:
{formatted_suggestions}

Questions:
{formatted_questions}

Unanswered:
{formatted_unanswered}" \
  --model opus \
  --resume {session_id} \
  --allowedTools "Read,Edit,Write" \
  --output-format json
```

## Expected Response

```
Document: [path]
Result: UPDATED | NO_CHANGES
Changes: [count]
Added to Open Questions: [count]
Skipped: [count]

Changes:
- [ID]: [What was added/changed and where]

Added to Open Questions:
- [ID]: [Description]

Skipped:
- [ID]: unanswered (remains in Open Questions)
```

### Exit Condition

The loop ends when assayer Phase 1 returns:
- **IMPLEMENTATION_READY**: Only implementation questions remain - requirements are clear
- **COMPLETE**: No gaps found - document is comprehensive

**Before proceeding to Phase B2**, check if the spec still has items in its Open Questions section. If so, warn the user:

```
"The spec is ready for implementation, but [N] open questions remain unanswered:
[List the open questions from the spec]

These may affect implementation quality. Would you like to:
1. Answer them now before proceeding
2. Proceed anyway (questions will remain in the spec)"
```

If user chooses to answer, format answers and resume assayer Phase 2 to apply them.

Then proceed to Phase B2 (Refiner Loop).

---

## Phase B2: Refiner Loop

After clarification completes, run refiner to autonomously fix obvious factual errors before involving the user.

### The Loop

```
[Clarification complete - assayer returned IMPLEMENTATION_READY or COMPLETE]
        ↓
Tell user: "Clarification complete. Running refiner to auto-fix factual errors..."
        ↓
Invoke refiner
        ↓
Receive output (CHANGES, COMPLETE, or FAILED)
        ↓
If CHANGES: log what was done, invoke refiner again
If COMPLETE: exit loop (no more errors to fix)
If FAILED: report error to user, exit loop
        ↓
Repeat up to 4 times (or until COMPLETE)
        ↓
Tell user: "Refiner complete. [summary of changes]. Proceeding to verification."
        ↓
Proceed to Phase B3
```

### Invoking Refiner

Invoke the `token-furnace:refiner` agent using the Task tool.

**MANDATORY**: Use the contract below exactly.

## Output

```
Document: absolute path to spec file
```

## Expected Response

**When changes made:**
```
CHANGES
Document: [path]
Corrected: [count]
Added to Open Questions: [count]
Resolved from Open Questions: [count]

Corrected:
- [Spec said → Changed to] ← [evidence]

Added to Open Questions:
- [Fact]: [claim] vs [reality] - [why ambiguous]

Resolved from Open Questions:
- [Question that was resolved] ← [evidence]
```

**When no errors found (nothing left to fix):**
```
COMPLETE
Document: [path]
Remaining Open Questions: [count]
```

This signals the orchestrator to stop iterating and proceed to touchstone. Any remaining `[Fact]:` Open Questions are for user review.

**When document not found:**
```
FAILED
Reason: Document not found at [path]
```

### Handling Refiner Output

**Track across iterations:**
- Total corrections
- Total added to Open Questions
- Total resolved from Open Questions

**Exit conditions:**
- `COMPLETE` returned (no more errors to fix)
- `FAILED` returned (report error to user)
- 4 iterations completed (prevent infinite loops)

**After loop completes**, summarize for user:
```
"Refiner completed [N] passes:
- Corrected [X] factual errors automatically
- Added [Y] ambiguous items to Open Questions
- Resolved [Z] existing Open Questions

Proceeding to verification for remaining claims."
```

Then proceed to Phase B3 (Verification Loop).

---

## Phase B3: Verification Loop

After the refiner loop completes, verify remaining claims with user input.

### The Loop

```
[Refiner complete - refiner returned COMPLETE or ran 4 times]
        ↓
Tell user: "Refiner complete. Running touchstone to verify remaining claims with your input..."
        ↓
Invoke NEW touchstone (Phase 1)
        ↓
Receive touchstone output (Corrections + Questions + Status)
        ↓
If Status is VERIFIED → Proceed to Phase C
        ↓
Present to user VERBATIM (DO NOT SUMMARIZE - copy full output exactly):
  "The touchstone found some inaccuracies:

   ## Corrections (claims that contradict evidence)
   [Preserve FULL structure from touchstone - do NOT summarize]
   [Each correction must include: Spec says, Actually, Evidence (with file paths), Suggested correction]

   ## Questions (claims needing clarification)
   [Preserve FULL structure from touchstone - do NOT summarize]
   [Each question must include: Spec says, Concern, Question]

   For corrections: confirm, reject with reason, reject, or modify.
   For questions: provide your answer or skip."
        ↓
User responds
        ↓
Format answers for touchstone (see Formatting Answers below)
        ↓
RESUME touchstone (Phase 2) with formatted answers
        ↓
Receive report (Result, Corrections applied, Added to Open Questions, Skipped)
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
Invoke NEW touchstone (fresh eyes, Phase 1)
        ↓
Repeat
```

### Invoking Touchstone (Phase 1)

Invoke the touchstone using the Bash tool with `claude -p`.

**IMPORTANT**: The Task tool has a known regression with resume when agents use tools. Use `claude -p` directly until this is fixed.

## Output

```
Document: absolute path to spec file
```

**Command template:**
```bash
claude -p "Use the Skill tool to invoke 'token-furnace:touchstone' with the Document: {document_path} and follow it exactly." \
  --model opus \
  --allowedTools "Read,Glob,Grep,Skill" \
  --output-format json
```

**Capture the `session_id` from the JSON output** - you'll need it for Phase 2.

## Expected Response
```markdown
## Document Reviewed

[Path to document]

## Corrections (claims that contradict evidence)

[If none: "None - all verified claims are accurate"]

### C1: [The incorrect claim]

**Spec says:** [Quote from spec]
**Actually:** [What the evidence shows]
**Evidence:**
- File: `[path]:[line]` - [what it shows]
- Skill: `[skill]/[file]` - [what it shows]
**Suggested correction:** [How to fix the spec]

---

### C2: ...

## Questions (claims needing clarification)

[If none: "None - no claims requiring clarification"]

### Q1: [The unclear claim]

**Spec says:** [Quote from spec]
**Concern:** [Why this seems wrong or inconsistent]
**Question:** [Specific question to resolve it]

---

### Q2: ...

## Status

[One of:]
- NEEDS_CORRECTION: [N] corrections, [M] questions
- VERIFIED: All verifiable claims checked out (or no verifiable claims found)
```

Handle the output:
- **Corrections**: Claims where touchstone found contradictions - user confirms, rejects (with or without reason), or modifies
- **Questions**: Claims needing user clarification - user provides answer or skips
- **Status**: Determines whether to continue the loop or exit

### Formatting Answers

After the user responds, format their answers for the touchstone Phase 2 resume.

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

### Resuming Touchstone (Phase 2)

Resume the touchstone using `claude -p --resume` with the session ID from Phase 1.

The skill is already loaded from Phase 1 - just send the formatted input.

## Output

```
Document: absolute path to spec file

Corrections:
- C1: [title] → confirmed
- C2: [title] → rejected: [reason]
- C3: [title] → rejected
- C4: [title] → modified: [user's version]

Questions:
- Q1: [title] → [user's answer]
- Q2: [title] → unanswered
```

**Command template:**
```bash
claude -p "Document: {document_path}

Corrections:
{formatted_corrections}

Questions:
{formatted_questions}" \
  --model opus \
  --resume {session_id} \
  --allowedTools "Read,Edit,Write" \
  --output-format json
```

## Expected Response

```
Document: [path]
Result: UPDATED | NO_CHANGES
Corrections applied: [count]
Added to Open Questions: [count]
Skipped: [count]

Applied:
- [ID]: [What was corrected and where]

Added to Open Questions:
- [ID]: [Description]

Skipped:
- [ID]: unanswered (added to Open Questions)
```

### Exit Condition

The loop ends when touchstone Phase 1 returns:
- **VERIFIED**: All verifiable claims checked out (or no verifiable claims found)

**Before proceeding to Phase C**, check if the spec still has items in its Open Questions section. If so, warn the user:

```
"Verification complete, but [N] open questions remain in the spec:
[List the open questions from the spec]

These will be carried into implementation phases. Would you like to:
1. Address them now before structuring
2. Proceed anyway (questions will remain in the spec)"
```

If user chooses to address them, guide them through answering and update the spec accordingly.

Then proceed to Phase C (Structure).

---

## Phase C: Structure

After clarification and verification complete, derive implementation phases from the refined spec.

### Invoking Mold

Invoke the `token-furnace:mold` agent using the Task tool.

**MANDATORY**: Use the contract below exactly.

## Output

```
Spec path: absolute path to the spec file to restructure
```

## Expected Response

**Success:**
```
MOLD COMPLETE
Phases: [count]
Output: [path]

COMPARATIVE AUDIT RESULTS:
[audit details]

AUDIT RESULT: PASS
```

**Failure:**
```
MOLD FAILED
Reason: [why]

COMPARATIVE AUDIT RESULTS:
[audit details]

AUDIT RESULT: FAIL
```

### Handling Mold Output

1. Verify signal is `MOLD COMPLETE` AND `AUDIT RESULT: PASS`
2. If `MOLD FAILED` or `AUDIT RESULT: FAIL`, report issues to user - spec needs review
3. Read the phases file at `plans/[slug]/[slug]-spec-phases.md` (mold created it)
4. Present the phase summaries to user for confirmation
5. If user adjusts, update the phases file with their changes

### Completion

When mold completes successfully, report to the user:

```
## Intake Complete

**Spec:** [full path to spec]
**Phases:** [full path to phases file]

**Summary:**
- [Key points captured]
- [Decisions made]
- [Patterns identified]
- [N] implementation phases derived

**Status:** Ready for implementation planning

**Next step:** Run smelter to begin implementation planning
```

---

## Summary

```
User dumps thoughts
        ↓
    [Phase A: Organize Loop]
    Organize → Research (ore-scout) → Suggest → Repeat
        ↓
User says "ready"
        ↓
    [Write Spec]
        ↓
    [Phase A2: Prospector Loop]
    Prospector → (CHANGES? repeat, up to 4x) → COMPLETE → exit
        ↓
    [Phase B: Clarification Loop]
    Assayer (Phase 1) → Present → User answers → Resume Assayer (Phase 2) → Report → NEW Assayer → Repeat
        ↓
Assayer returns IMPLEMENTATION_READY or COMPLETE
        ↓
    [Phase B2: Refiner Loop]
    Refiner → (CHANGES? repeat, up to 4x) → COMPLETE → exit
        ↓
    [Phase B3: Verification Loop]
    Touchstone (Phase 1) → Present → User answers → Resume Touchstone (Phase 2) → Report → NEW Touchstone → Repeat
        ↓
Touchstone returns VERIFIED
        ↓
    [Phase C: Structure]
    Mold → Present phases → User confirms
        ↓
    [Report completion with spec + phases links, suggest smelter]
```
