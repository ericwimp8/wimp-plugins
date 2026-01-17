---
description: Run existing tests and fix any failures for a TypeScript source file
argument-hint: [source-file-path]
---

# Fix Tests Orchestrator

You are orchestrating a workflow to fix failing tests for: `$1`

## Skills

These skills contain curated patterns that agents MUST invoke and read. Pass them to agents in Phase 2.

- `jest-testing` - **Pass if** project uses Jest (check for `jest` in package.json dependencies/devDependencies)
- `typescript-testing` - **Always pass** for TypeScript-specific patterns
- `jest-firebase-functions` - **Pass if** source file is a Firebase Cloud Function (check for `functions/src/` path or imports from `firebase-functions`)

Before Phase 1, check the source file path, imports, and package.json to determine which skills apply.

**Format:** `Skills: typescript-testing` (add `jest-testing` if using Jest, add `jest-firebase-functions` if testing Firebase Functions)

## Execution Model

**NEVER invoke multiple agents in parallel.** This workflow is strictly sequential—each agent must complete before the next starts.

## Derived Paths

From source file `$1`, compute:
- **Plan file**: `test/plans/[filename]_fix_plan.md` (filename without extension)
- **Test file**: Determined by project convention (see detection below)

### Test File Location

TypeScript projects use one of two conventions:

| Pattern | Source | Test |
|---------|--------|------|
| **Alongside** | `src/services/userService.ts` | `src/services/userService.test.ts` |
| **Mirror** | `src/services/userService.ts` | `src/services/__tests__/userService.test.ts` |

**Detection:** Search for existing `*.test.ts` or `*.spec.ts` files in the project:
- If tests exist in `__tests__/` subdirectories → use **mirror** pattern
- If tests exist alongside source files (same directory) → use **alongside** pattern
- If no existing tests found → use **AskUserQuestion** to ask the user:
  - Header: `Test location`
  - Option 1: `Alongside source` - "Tests sit next to source files (e.g., `foo.test.ts` beside `foo.ts`)"
  - Option 2: `Mirror in __tests__` - "Tests go in `__tests__/` subdirectories (e.g., `__tests__/foo.test.ts`)"

**Computing the test file path** from source file and pattern:

| Pattern | Source | Test file path |
|---------|--------|----------------|
| **Alongside** | `src/services/userService.ts` | `src/services/userService.test.ts` |
| **Mirror** | `src/services/userService.ts` | `src/services/__tests__/userService.test.ts` |

Formula:
- **Alongside**: Replace `.ts` with `.test.ts` in the same directory
- **Mirror**: Insert `__tests__/` before the filename, replace `.ts` with `.test.ts`

**Firebase Functions** follow the same detection - example with mirror pattern:
- Source: `functions/src/auth/onUserCreate.ts`
- Plan: `test/plans/onUserCreate_fix_plan.md`
- Test: `functions/src/auth/__tests__/onUserCreate.test.ts`

## Workflow

Execute these phases in order using the Task tool to invoke each agent.

### Phase 1: Discover Failing Tests

Invoke the `test-writer-typescript:tw-discover-failing-tests` agent using the prompt template below.
- **Expected output**: Plan file at `test/plans/[source_file_name]_fix_plan.md` OR `Result: ALL_PASSING`

**If result is ALL_PASSING:** Report "All tests passing" and exit.

**MANDATORY**: NEVER add any instructions or extra details of any kind to the prompt. Use the template below exactly, replacing placeholders in brackets.

**Prompt template** (use this format exactly):
```
Discover failing tests in: {test_file_path}
Source: {source_file_path}
Plan: {plan_file_path}
```

Where:
- `{test_file_path}` - full path to test file
- `{source_file_path}` - full path to source file
- `{plan_file_path}` - full path to fix plan file

Wait for completion before proceeding.

### Phase 2: Fix Loop

Read the plan file and find all cases with status `pending` or `in_progress`.

Process each incomplete case **one at a time**, in plan order.

#### Run and Fix

Invoke the `test-writer-typescript:tw-run-fix` agent using the prompt template below.

**Handle result:**
- SUCCESS → continue to next case
- IMPLEMENTATION_BUG → log and continue to next case
- NEEDS_CLARIFICATION → log and continue to next case
- STUCK → extract failure details from the report and retry with them as "Previous failure" (up to 2 retries), then continue if still stuck

**MANDATORY**: NEVER add any instructions or extra details of any kind to the prompt. Use the template below exactly, replacing placeholders in brackets.

**Prompt template** (use this format exactly):
```
Run and fix test file: {test_file_path}
Implementation: {source_file_path}
Plan: {plan_file_path}
Case: {case_id}
Max iterations: 9
Attempt: 1
Skills: typescript-testing{jest_suffix}{firebase_suffix}
```

**If retrying with a previous failure**, use this template instead:
```
Run and fix test file: {test_file_path}
Implementation: {source_file_path}
Plan: {plan_file_path}
Case: {case_id}
Max iterations: 9
Attempt: {attempt_number}
Skills: typescript-testing{jest_suffix}{firebase_suffix}

Previous failure:
{failure_details}
```

Where:
- `{test_file_path}` - full path to test file
- `{source_file_path}` - full path to source file being tested
- `{plan_file_path}` - full path to fix plan file
- `{case_id}` - case identifier from plan (e.g., `Case 1`)
- `{attempt_number}` - retry attempt number (2 for first retry, 3 for second retry)
- `{jest_suffix}` - add `, jest-testing` if project uses Jest, otherwise omit
- `{firebase_suffix}` - add `, jest-firebase-functions` if testing Firebase Functions, otherwise omit
- `{failure_details}` - exact failure information extracted from the report

Repeat for each incomplete case.

### Phase 3: Write Report

After all cases are processed, write a report file.

**Report file path**: `test/reports/[filename]_fix_report_[timestamp].md`
- `[filename]` - source file name without extension (same as plan file)
- `[timestamp]` - current date/time as `YYYY-MM-DD_HHMMSS`

Example: `test/reports/userService_fix_report_2024-01-07_143022.md`

**Report structure** (use your judgment on exact wording and detail):

```markdown
# Fix Report: [source_filename]

Generated: [human-readable timestamp]

## Summary

- **Source**: [source file path]
- **Test file**: [test file path]
- **Cases fixed**: [n]
- **Cases stuck**: [n]

## Iteration Statistics

[Read the **Attempts** field from each case in the plan file]

| Case | Attempts | Total Iterations | Final Status |
|------|----------|------------------|--------------|
| [case_id] | 1: 3 (SUCCESS) | 3 | complete |
| [case_id] | 1: 9 (STUCK), 2: 9 (STUCK), 3: 5 (SUCCESS) | 23 | complete |

**Totals:**
- Total attempts: [sum of all attempt counts across all cases]
- Total fixer iterations: [sum of all iterations across all attempts]
- Cases resolved on first attempt: [n]
- Cases requiring retries: [n]

## Technical Challenges

[For each stuck case, implementation bug, or clarification need, describe:]
- The case identifier
- What went wrong or what blocked progress
- Any relevant error messages or context
- Suggested next steps if applicable

[If no challenges, state "All test cases fixed successfully."]

## Manual Follow-up

[List any items requiring human attention, or state "None required."]
```

Write the report file using the Write tool, then confirm to the user:
- Report file location
- Brief summary of results

## Rules

1. **Sequential execution**: Complete each phase before starting the next. NEVER invoke multiple agents in parallel.
2. **One case at a time**: Fix one test case completely before starting the next case.
3. **Log stuck cases**: Don't stop on failures, log and continue
4. **Verify with actual test runs**: Don't claim success without running tests
